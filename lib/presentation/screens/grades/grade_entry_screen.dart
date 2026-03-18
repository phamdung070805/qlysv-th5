import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/class_provider.dart';
import '../../viewmodels/grade_provider.dart';
import '../../viewmodels/subject_provider.dart';

class GradeEntryScreen extends StatefulWidget {
  const GradeEntryScreen({required this.classId, super.key});

  final String classId;

  @override
  State<GradeEntryScreen> createState() => _GradeEntryScreenState();
}

class _GradeEntryScreenState extends State<GradeEntryScreen> {
  String? _studentId;
  String? _subjectId;
  final TextEditingController _scoreController = TextEditingController();

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final score = double.tryParse(_scoreController.text.trim());
    if (_studentId == null || _subjectId == null || score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ dữ liệu hợp lệ.')),
      );
      return;
    }
    if (score < 0 || score > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Điểm phải trong khoảng 0-10.')),
      );
      return;
    }

    await context.read<GradeProvider>().upsertGrade(
      classId: widget.classId,
      studentId: _studentId!,
      subjectId: _subjectId!,
      score: score,
    );
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nhập điểm thành công.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final subjectProvider = context.watch<SubjectProvider>();
    final classRoom = classProvider.classById(widget.classId);
    final students = classProvider.studentsInClass(widget.classId);
    final subjects = subjectProvider.subjects
        .where((subject) => classRoom?.subjectIds.contains(subject.id) == true)
        .toList();
    _studentId ??= students.isNotEmpty ? students.first.id : null;
    _subjectId ??= subjects.isNotEmpty ? subjects.first.id : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Nhập điểm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _studentId,
            decoration: const InputDecoration(labelText: 'Sinh viên'),
            items: students
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(item.fullName),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _studentId = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _subjectId,
            decoration: const InputDecoration(labelText: 'Môn học'),
            items: subjects
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(item.name),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _subjectId = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _scoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Điểm (0-10)'),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _submit, child: const Text('Lưu điểm')),
        ],
      ),
    );
  }
}
