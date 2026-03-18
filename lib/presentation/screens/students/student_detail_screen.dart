import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/class_provider.dart';
import '../../viewmodels/student_view_model.dart';
import 'student_form_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({required this.studentId, super.key});

  final String studentId;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentViewModel>();
    final student = vm.findById(studentId);

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sinh viên')),
        body: const Center(child: Text('Không tìm thấy sinh viên.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sinh viên'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StudentFormScreen(initialStudent: student),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () async {
              final vm = context.read<StudentViewModel>();
              final classVm = context.read<ClassProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Xác nhận xóa'),
                    content: Text('Bạn có chắc muốn xóa ${student.fullName}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Hủy'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Xóa'),
                      ),
                    ],
                  );
                },
              );

              if (shouldDelete != true) {
                return;
              }

              await vm.deleteStudent(student.id);
              await classVm.refresh();
              if (!navigator.mounted) {
                return;
              }

              messenger.showSnackBar(
                const SnackBar(content: Text('Đã xóa sinh viên.')),
              );
              navigator.pop();
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Hero(
            tag: 'student-avatar-${student.id}',
            child: CircleAvatar(
              radius: 56,
              backgroundImage: student.hasAvatar
                  ? NetworkImage(student.avatarUrl!)
                  : null,
              child: student.hasAvatar
                  ? null
                  : Text(
                      student.displayInitial,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            student.fullName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'MSSV', value: student.mssv),
          _InfoRow(label: 'Email', value: student.email),
          _InfoRow(label: 'Ngày sinh', value: _formatDate(student.birthDate)),
          _InfoRow(label: 'Lớp', value: vm.classNameOf(student.classId)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
