import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/settings_view_model.dart';
import '../classrooms/classroom_management_screen.dart';
import '../subjects/subject_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 24),
        Card(
          child: SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text(
              'Lưu trạng thái giao diện vào SharedPreferences',
            ),
            value: settings.isDarkMode,
            onChanged: (value) {
              settings.setDarkMode(value);
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.class_outlined),
            title: const Text('Quản lý danh mục lớp'),
            subtitle: const Text(
              'Thêm, sửa, xóa lớp và đồng bộ cho biểu mẫu sinh viên.',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ClassroomManagementScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Quản lý danh mục môn học'),
            subtitle: const Text(
              'Quản lý mã môn, tên môn, số tín chỉ trước khi gán vào lớp.',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SubjectManagementScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
