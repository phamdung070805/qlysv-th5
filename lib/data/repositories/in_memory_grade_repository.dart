import '../../domain/entities/grade.dart';
import '../../domain/repositories/grade_repository.dart';

class InMemoryGradeRepository implements GradeRepository {
  final List<Grade> _grades = [
    const Grade(
      id: 's1_lop-cntt-01_sub-ltdd',
      classId: 'lop-cntt-01',
      studentId: 's1',
      subjectId: 'sub-ltdd',
      score: 8.6,
    ),
    const Grade(
      id: 's1_lop-cntt-01_sub-csdl',
      classId: 'lop-cntt-01',
      studentId: 's1',
      subjectId: 'sub-csdl',
      score: 8.1,
    ),
    const Grade(
      id: 's2_lop-httt-01_sub-pttk',
      classId: 'lop-httt-01',
      studentId: 's2',
      subjectId: 'sub-pttk',
      score: 7.4,
    ),
  ];

  @override
  Future<List<Grade>> fetchGrades() async {
    return List.unmodifiable(_grades);
  }

  @override
  Future<Grade> upsertGrade({
    required String classId,
    required String studentId,
    required String subjectId,
    required double score,
  }) async {
    final index = _grades.indexWhere(
      (item) =>
          item.classId == classId &&
          item.studentId == studentId &&
          item.subjectId == subjectId,
    );
    if (index == -1) {
      final created = Grade(
        id: createGradeDocId(
          studentId: studentId,
          classId: classId,
          subjectId: subjectId,
        ),
        classId: classId,
        studentId: studentId,
        subjectId: subjectId,
        score: score,
      );
      _grades.add(created);
      return created;
    }

    final updated = _grades[index].copyWith(score: score);
    _grades[index] = updated;
    return updated;
  }

  @override
  String createGradeDocId({
    required String studentId,
    required String classId,
    required String subjectId,
  }) {
    return '${studentId}_${classId}_$subjectId';
  }
}
