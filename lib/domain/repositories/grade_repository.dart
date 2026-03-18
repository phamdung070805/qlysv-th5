import '../entities/grade.dart';

abstract class GradeRepository {
  Future<List<Grade>> fetchGrades();

  Future<Grade> upsertGrade({
    required String classId,
    required String studentId,
    required String subjectId,
    required double score,
  });

  String createGradeDocId({
    required String studentId,
    required String classId,
    required String subjectId,
  });
}
