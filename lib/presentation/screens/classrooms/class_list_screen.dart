import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../domain/entities/app_user.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/class_provider.dart';
import '../../viewmodels/settings_view_model.dart';
import '../../viewmodels/subject_provider.dart';
import 'class_detail_screen.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  Future<void> _openClassForm(
    BuildContext context, {
    String? classId,
    String? currentName,
  }) async {
    final controller = TextEditingController(text: currentName ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
          title: Row(
            children: [
              Expanded(
                child: Text(classId == null ? 'Thêm lớp học' : 'Sửa lớp học'),
              ),
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
                final name = controller.text.trim();
                if (name.isEmpty) {
                  return;
                }
                try {
                  if (classId == null) {
                    await context.read<ClassProvider>().addClass(name);
                  } else {
                    await context.read<ClassProvider>().updateClassName(
                      classId: classId,
                      className: name,
                    );
                  }
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Không thể lưu lớp học: $error'),
                    ),
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
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ClassProvider, SubjectProvider, AuthViewModel>(
      builder: (context, classProvider, subjectProvider, authViewModel, child) {
        final canEdit =
            authViewModel.user?.role.canEditAcademicData ?? false;

        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: true,
              expandedHeight: 160,
              title: Text('Danh sách lớp học'),
              flexibleSpace: FlexibleSpaceBar(
                background: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (canEdit)
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () => _openClassForm(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm lớp'),
                        ),
                      ),
                    if (canEdit) const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          selected: classProvider.filterSubjectId == null,
                          label: const Text('Tất cả môn'),
                          onSelected: (selected) {
                            classProvider.setFilterSubjectId(null);
                          },
                        ),
                        ...subjectProvider.subjects.map(
                          (subject) => ChoiceChip(
                            selected: classProvider.filterSubjectId == subject.id,
                            label: Text(subject.code),
                            onSelected: (selected) {
                              classProvider.setFilterSubjectId(
                                selected ? subject.id : null,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (classProvider.isLoading)
              SliverList.builder(
                itemCount: 4,
                itemBuilder: (context, index) => const _ClassShimmerCard(),
              )
            else if (classProvider.filteredClasses.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Chưa có lớp học nào.')),
              )
            else
              SliverList.builder(
                itemCount: classProvider.filteredClasses.length,
                itemBuilder: (context, index) {
                  final classRoom = classProvider.filteredClasses[index];
                  final studentCount = classProvider
                      .studentsInClass(classRoom.id)
                      .length;
                  final subjectCount = classRoom.subjectIds.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 240 + (index * 70)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - value) * 18),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(classRoom.name),
                          subtitle: Text(
                            '$studentCount SV • $subjectCount môn',
                          ),
                          trailing: canEdit
                              ? PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      await _openClassForm(
                                        context,
                                        classId: classRoom.id,
                                        currentName: classRoom.name,
                                      );
                                    } else if (value == 'delete') {
                                      await context
                                          .read<ClassProvider>()
                                          .deleteClass(classRoom.id);
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Sửa'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Xóa'),
                                      ),
                                    ];
                                  },
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: () async {
                            await context
                                .read<SettingsViewModel>()
                                .setLastViewedClassId(classRoom.id);
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    ClassDetailScreen(classId: classRoom.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        );
      },
    );
  }
}

class _ClassShimmerCard extends StatelessWidget {
  const _ClassShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE4E4E7),
        highlightColor: const Color(0xFFF4F4F5),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
