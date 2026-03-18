import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/app_user.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/class_provider.dart';

class ClassroomManagementScreen extends StatefulWidget {
  const ClassroomManagementScreen({super.key});

  @override
  State<ClassroomManagementScreen> createState() =>
      _ClassroomManagementScreenState();
}

class _ClassroomManagementScreenState extends State<ClassroomManagementScreen> {
  final TextEditingController _classController = TextEditingController();

  Future<void> _openRenameDialog(
    BuildContext context, {
    required String classId,
    required String currentName,
  }) async {
    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
        title: Row(
          children: [
            const Expanded(child: Text('Đổi tên lớp')),
            IconButton(
              tooltip: 'Đóng',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Tên lớp'),
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              final nextName = controller.text.trim();
              if (nextName.isEmpty) {
                return;
              }
              try {
                await context.read<ClassProvider>().updateClassName(
                  classId: classId,
                  className: nextName,
                );
              } catch (error) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể đổi tên lớp: $error')),
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
      ),
    );
    controller.dispose();
  }

  @override
  void dispose() {
    _classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClassProvider>();
    final user = context.watch<AuthViewModel>().user;
    final canEdit = user?.role.canEditAcademicData ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục lớp học')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _classController,
            decoration: InputDecoration(
              labelText: 'Tên lớp mới',
              suffixIcon: IconButton(
                onPressed: !canEdit
                    ? null
                    : () async {
                        final value = _classController.text.trim();
                        if (value.isEmpty) {
                          return;
                        }
                        try {
                          await context.read<ClassProvider>().addClass(value);
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Không thể thêm lớp: $error')),
                          );
                          return;
                        }
                        _classController.clear();
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã thêm lớp học.')),
                        );
                      },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...vm.classes.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.name),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      onPressed: !canEdit
                          ? null
                          : () => _openRenameDialog(
                              context,
                              classId: item.id,
                              currentName: item.name,
                            ),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      onPressed: !canEdit
                          ? null
                          : () async {
                              try {
                                await context.read<ClassProvider>().deleteClass(
                                  item.id,
                                );
                              } catch (error) {
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Không thể xóa lớp: $error'),
                                  ),
                                );
                                return;
                              }
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã xóa lớp học.')),
                              );
                            },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
