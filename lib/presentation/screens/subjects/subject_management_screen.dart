import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/subject.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/class_provider.dart';
import '../../viewmodels/subject_provider.dart';
import 'subject_detail_screen.dart';

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() =>
      _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends State<SubjectManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm(BuildContext context, {Subject? subject}) async {
    final codeController = TextEditingController(text: subject?.code ?? '');
    final nameController = TextEditingController(text: subject?.name ?? '');
    final creditsController = TextEditingController(
      text: subject?.credits.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
          title: Row(
            children: [
              Expanded(
                child: Text(subject == null ? 'Thêm môn học' : 'Sửa môn học'),
              ),
              IconButton(
                tooltip: 'Đóng',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Mã môn'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên môn'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số tín chỉ'),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                final code = codeController.text.trim().toUpperCase();
                final name = nameController.text.trim();
                final credits = int.tryParse(creditsController.text.trim());
                if (code.isEmpty || name.isEmpty || credits == null || credits <= 0) {
                  return;
                }
                final vm = context.read<SubjectProvider>();
                try {
                  if (subject == null) {
                    await vm.addSubject(code: code, name: name, credits: credits);
                  } else {
                    await vm.updateSubject(
                      subject.copyWith(code: code, name: name, credits: credits),
                    );
                  }
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể lưu môn học: $error')),
                  );
                  return;
                }
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    codeController.dispose();
    nameController.dispose();
    creditsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SubjectProvider>();
    final classProvider = context.watch<ClassProvider>();
    final user = context.watch<AuthViewModel>().user;
    final canEdit = user?.role.canEditAcademicData ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục môn học')),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () => _openForm(context),
              child: const Icon(Icons.add),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Tìm môn học...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: vm.setSearchQuery,
          ),
          const SizedBox(height: 12),
          ...vm.filteredSubjects.map(
            (subject) => Card(
              child: ListTile(
                title: Hero(
                  tag: 'subject-${subject.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text('${subject.code} - ${subject.name}'),
                  ),
                ),
                subtitle: Text(
                  '${subject.credits} tín chỉ • ${subject.classIds.length} lớp',
                ),
                trailing: canEdit
                    ? Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            onPressed: () =>
                                _openForm(context, subject: subject),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: () async {
                              try {
                                await vm.deleteSubject(subject.id);
                              } catch (error) {
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Không thể xóa môn học: $error'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      )
                    : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SubjectDetailScreen(subjectId: subject.id),
                      ),
                    );
                  },
              ),
            ),
          ),
            if (vm.filteredSubjects.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: Text('Không có môn học phù hợp.')),
              ),
            const SizedBox(height: 12),
            Text(
              'Tổng số lớp hiện có: ${classProvider.classes.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
