import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/app_user.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/class_provider.dart';
import '../../viewmodels/student_view_model.dart';
import '../../viewmodels/subject_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    final studentVm = context.watch<StudentViewModel>();
    final classVm = context.watch<ClassProvider>();
    final subjectVm = context.watch<SubjectProvider>();
    final theme = Theme.of(context);

    final studentCount = studentVm.students.length;
    final classCount = classVm.classes.length;
    final subjectCount = subjectVm.subjects.length;
    final roleLabel = user?.role.label ?? 'Người dùng';
    final displayName = user?.displayName.trim();
    final greetingName = (displayName == null || displayName.isEmpty)
        ? roleLabel
        : displayName;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào $greetingName',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatChip(
                      icon: Icons.groups_outlined,
                      label: 'Sinh viên',
                      value: studentCount.toString(),
                    ),
                    _StatChip(
                      icon: Icons.class_outlined,
                      label: 'Lớp học',
                      value: classCount.toString(),
                    ),
                    _StatChip(
                      icon: Icons.menu_book_outlined,
                      label: 'Môn học',
                      value: subjectCount.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gợi ý thao tác nhanh',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '1. Vào tab Lớp học để tạo lớp và gán môn cho từng lớp.',
                ),
                const SizedBox(height: 8),
                Text(
                  '2. Vào tab Sinh viên để thêm mới, cập nhật và phân lớp.',
                ),
                const SizedBox(height: 8),
                Text(
                  '3. Vào Cài đặt để quản lý danh mục lớp và môn học.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text('$label: ', style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
