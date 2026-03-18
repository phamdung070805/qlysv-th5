import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/app_user.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/class_provider.dart';
import '../../viewmodels/grade_provider.dart';
import '../../viewmodels/settings_view_model.dart';
import '../../viewmodels/subject_provider.dart';
import '../grades/grade_entry_screen.dart';
import '../subjects/subject_detail_screen.dart';

class ClassDetailScreen extends StatelessWidget {
  const ClassDetailScreen({required this.classId, super.key});

  final String classId;

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final subjectProvider = context.watch<SubjectProvider>();
    final gradeProvider = context.watch<GradeProvider>();
    final user = context.watch<AuthViewModel>().user;
    final canEdit = user?.role.canEditAcademicData ?? false;
    final classRoom = classProvider.classById(classId);
    final className = classRoom?.name ?? 'Lớp học';
    final students = classProvider.studentsInClass(classId);
    final subjects = subjectProvider.subjects
        .where((subject) => classRoom?.subjectIds.contains(subject.id) == true)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(className),
          actions: canEdit
              ? [
                  IconButton(
                    onPressed: () => _showAddStudentDialog(context),
                    icon: const Icon(Icons.person_add_alt_1),
                    tooltip: 'Thêm sinh viên vào lớp',
                  ),
                  IconButton(
                    onPressed: () => _showAssignSubjectDialog(context),
                    icon: const Icon(Icons.playlist_add),
                    tooltip: 'Gán môn học vào lớp',
                  ),
                ]
              : null,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sinh viên'),
              Tab(text: 'Môn học'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            students.isEmpty
                ? const _EmptyTab(message: 'Lớp chưa có sinh viên.')
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: students
                        .map(
                          (student) => Card(
                            child: ListTile(
                              leading: Hero(
                                tag: 'student-avatar-${student.id}',
                                child: CircleAvatar(
                                  backgroundImage: student.hasAvatar
                                      ? NetworkImage(student.avatarUrl!)
                                      : null,
                                  child: student.hasAvatar
                                      ? null
                                      : Text(
                                          student.displayInitial,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              title: Text(student.fullName),
                              subtitle: Text(student.mssv),
                              trailing: canEdit
                                  ? SizedBox(
                                      width: 170,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'GPA ${gradeProvider.studentGpaInClass(classId, student.id).toStringAsFixed(2)}',
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Xóa khỏi lớp',
                                            onPressed: () => _removeStudentFromClass(
                                              context,
                                              studentId: student.id,
                                              studentName: student.fullName,
                                            ),
                                            icon: const Icon(Icons.person_remove_outlined),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(
                                      'GPA ${gradeProvider.studentGpaInClass(classId, student.id).toStringAsFixed(2)}',
                                    ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
            subjects.isEmpty
                ? const _EmptyTab(message: 'Lớp chưa được gán môn học.')
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: subjects
                        .map(
                          (subject) => Card(
                            child: ListTile(
                              title: Hero(
                                tag: 'subject-${subject.id}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text('${subject.code} - ${subject.name}'),
                                ),
                              ),
                              subtitle: Text('${subject.credits} tín chỉ'),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: 'Chi tiết môn',
                                    onPressed: () async {
                                      await context
                                          .read<SettingsViewModel>()
                                          .setLastViewedSubjectId(subject.id);
                                      if (!context.mounted) {
                                        return;
                                      }
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => SubjectDetailScreen(
                                            subjectId: subject.id,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.info_outline),
                                  ),
                                  if (canEdit)
                                    IconButton(
                                      onPressed: () {
                                        classProvider.removeSubjectFromClass(
                                          classId: classId,
                                          subjectId: subject.id,
                                        );
                                        subjectProvider.detachClassFromSubject(
                                          subjectId: subject.id,
                                          classId: classId,
                                        );
                                      },
                                      icon: const Icon(Icons.remove_circle),
                                    ),
                                ],
                              ),
                              onTap: () async {
                                await context
                                    .read<SettingsViewModel>()
                                    .setLastViewedSubjectId(subject.id);
                                if (!context.mounted) {
                                  return;
                                }
                                _showSubjectGradeBoardDialog(
                                  context,
                                  subjectId: subject.id,
                                );
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ],
        ),
        floatingActionButton: canEdit
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'grade-entry-$classId',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GradeEntryScreen(classId: classId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Nhập điểm'),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.extended(
                    heroTag: 'grade-chart-$classId',
                    onPressed: () => _showScoreChartDialog(context),
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Phổ điểm'),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Future<void> _showAddStudentDialog(BuildContext context) async {
    final classProvider = context.read<ClassProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final inClass = classProvider
        .studentsInClass(classId)
        .map((item) => item.id)
        .toSet();
    final candidates = classProvider.students
        .where((student) => !inClass.contains(student.id))
        .toList();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm sinh viên vào lớp'),
        content: SizedBox(
          width: 420,
          child: candidates.isEmpty
              ? const Text('Không còn sinh viên phù hợp.')
              : ListView(
                  shrinkWrap: true,
                  children: candidates
                      .map(
                        (student) => ListTile(
                          title: Text(student.fullName),
                          subtitle: Text(student.mssv),
                          onTap: () async {
                            await classProvider.addStudentToClass(
                              classId: classId,
                              studentId: student.id,
                            );
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.of(context).pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã thêm ${student.fullName} vào lớp.',
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
        ),
      ),
    );
  }

  Future<void> _removeStudentFromClass(
    BuildContext context, {
    required String studentId,
    required String studentName,
  }) async {
    final classProvider = context.read<ClassProvider>();
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sinh viên khỏi lớp'),
        content: Text('Bạn có chắc muốn xóa $studentName khỏi lớp này?'),
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
      ),
    );

    if (shouldRemove != true) {
      return;
    }

    await classProvider.removeStudentFromClass(
      classId: classId,
      studentId: studentId,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xóa $studentName khỏi lớp.')),
    );
  }

  Future<void> _showAssignSubjectDialog(BuildContext context) async {
    final classProvider = context.read<ClassProvider>();
    final subjectProvider = context.read<SubjectProvider>();
    final assigned = (classProvider.classById(classId)?.subjectIds ?? const <String>[])
        .toSet();
    final candidates = subjectProvider.subjects
        .where((subject) => !assigned.contains(subject.id))
        .toList();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gán môn học vào lớp'),
        content: SizedBox(
          width: 420,
          child: candidates.isEmpty
              ? const Text('Không còn môn học để gán.')
              : ListView(
                  shrinkWrap: true,
                  children: candidates
                      .map(
                        (subject) => ListTile(
                          title: Text(subject.name),
                          subtitle: Text('${subject.credits} tín chỉ'),
                          onTap: () async {
                            await classProvider.assignSubjectToClass(
                              classId: classId,
                              subjectId: subject.id,
                            );
                            await subjectProvider.attachClassToSubject(
                              subjectId: subject.id,
                              classId: classId,
                            );
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                      .toList(),
                ),
        ),
      ),
    );
  }

  Future<void> _showScoreChartDialog(BuildContext context) async {
    final classProvider = context.read<ClassProvider>();
    final subjectProvider = context.read<SubjectProvider>();
    final gradeProvider = context.read<GradeProvider>();
    final classRoom = classProvider.classById(classId);
    final subjects = subjectProvider.subjects
        .where((subject) => classRoom?.subjectIds.contains(subject.id) == true)
        .toList();

    if (subjects.isEmpty) {
      return;
    }

    String subjectId = subjects.first.id;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final buckets = gradeProvider.scoreBuckets(classId, subjectId);
            return AlertDialog(
              title: const Text('Phổ điểm theo môn'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: subjectId,
                      items: subjects
                          .map(
                            (subject) => DropdownMenuItem<String>(
                              value: subject.id,
                              child: Text(subject.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          subjectId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: [
                            _bar(0, buckets['0-4'] ?? 0),
                            _bar(1, buckets['4-6'] ?? 0),
                            _bar(2, buckets['6-8'] ?? 0),
                            _bar(3, buckets['8-10'] ?? 0),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const labels = ['0-4', '4-6', '6-8', '8-10'];
                                  return Text(labels[value.toInt()]);
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSubjectGradeBoardDialog(
    BuildContext context, {
    required String subjectId,
  }) async {
    final classProvider = context.read<ClassProvider>();
    final subjectProvider = context.read<SubjectProvider>();
    final gradeProvider = context.read<GradeProvider>();

    final subject = subjectProvider.subjectById(subjectId);
    if (subject == null) {
      return;
    }
    final rows = gradeProvider.gradesByClassAndSubject(classId, subjectId);
    final students = classProvider.studentsInClass(classId);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bảng điểm ${subject.code} - ${subject.name}'),
        content: SizedBox(
          width: 640,
          child: rows.isEmpty
              ? const Text('Chưa có điểm cho môn này trong lớp.')
              : SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('MSSV')),
                      DataColumn(label: Text('Họ tên')),
                      DataColumn(label: Text('Điểm')),
                    ],
                    rows: rows.map((grade) {
                      String studentMssv = '-';
                      String studentName = grade.studentId;
                      for (final item in students) {
                        if (item.id == grade.studentId) {
                          studentMssv = item.mssv;
                          studentName = item.fullName;
                          break;
                        }
                      }
                      return DataRow(
                        cells: [
                          DataCell(Text(studentMssv)),
                          DataCell(Text(studentName)),
                          DataCell(Text(grade.score.toStringAsFixed(2))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

BarChartGroupData _bar(int x, int y) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y.toDouble(),
        width: 18,
        borderRadius: BorderRadius.circular(4),
      ),
    ],
  );
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}
