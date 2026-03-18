import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/class_provider.dart';
import '../../viewmodels/subject_provider.dart';

class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({required this.subjectId, super.key});

  final String subjectId;

  @override
  Widget build(BuildContext context) {
    final subjectProvider = context.watch<SubjectProvider>();
    final classProvider = context.watch<ClassProvider>();
    final subject = subjectProvider.subjectById(subjectId);

    if (subject == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết môn học')),
        body: const Center(child: Text('Không tìm thấy môn học.')),
      );
    }

    final classes = classProvider.classes
        .where((classRoom) => subject.classIds.contains(classRoom.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết môn học')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'subject-${subject.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        '${subject.code} - ${subject.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Số tín chỉ: ${subject.credits}'),
                  const SizedBox(height: 4),
                  Text('Số lớp đã đăng ký: ${classes.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Danh sách lớp học phần',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (classes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Chưa có lớp nào đăng ký môn này.'),
              ),
            ),
          ...classes.map(
            (classRoom) => Card(
              child: ListTile(
                leading: const Icon(Icons.class_outlined),
                title: Text(classRoom.name),
                subtitle: Text(
                  '${classProvider.studentsInClass(classRoom.id).length} sinh viên',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
