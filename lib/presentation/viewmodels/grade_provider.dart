import 'package:flutter/foundation.dart';

import '../../domain/entities/grade.dart';
import '../../domain/repositories/grade_repository.dart';

class GradeProvider extends ChangeNotifier {
  GradeProvider({required GradeRepository gradeRepository})
    : _gradeRepository = gradeRepository;

  final GradeRepository _gradeRepository;

  bool _isLoading = true;
  bool _sortScoreHighToLow = true;
  List<Grade> _grades = [];

  bool get isLoading => _isLoading;
  bool get sortScoreHighToLow => _sortScoreHighToLow;
  List<Grade> get grades => List.unmodifiable(_grades);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await reload();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    _grades = await _gradeRepository.fetchGrades();
  }

  void setSortScoreHighToLow(bool value) {
    _sortScoreHighToLow = value;
    notifyListeners();
  }

  List<Grade> gradesByClassAndSubject(String classId, String subjectId) {
    final rows = _grades
        .where((grade) => grade.classId == classId && grade.subjectId == subjectId)
        .toList();
    rows.sort(
      (a, b) => _sortScoreHighToLow
          ? b.score.compareTo(a.score)
          : a.score.compareTo(b.score),
    );
    return rows;
  }

  double classAverageBySubject(String classId, String subjectId) {
    final rows = gradesByClassAndSubject(classId, subjectId);
    if (rows.isEmpty) {
      return 0;
    }
    final sum = rows.fold<double>(0, (value, item) => value + item.score);
    return sum / rows.length;
  }

  Map<String, int> scoreBuckets(String classId, String subjectId) {
    final rows = gradesByClassAndSubject(classId, subjectId);
    final result = {'0-4': 0, '4-6': 0, '6-8': 0, '8-10': 0};
    for (final grade in rows) {
      if (grade.score < 4) {
        result['0-4'] = result['0-4']! + 1;
      } else if (grade.score < 6) {
        result['4-6'] = result['4-6']! + 1;
      } else if (grade.score < 8) {
        result['6-8'] = result['6-8']! + 1;
      } else {
        result['8-10'] = result['8-10']! + 1;
      }
    }
    return result;
  }

  Future<void> upsertGrade({
    required String classId,
    required String studentId,
    required String subjectId,
    required double score,
  }) async {
    await _gradeRepository.upsertGrade(
      classId: classId,
      studentId: studentId,
      subjectId: subjectId,
      score: score,
    );
    await reload();
    notifyListeners();
  }

  double studentGpaInClass(String classId, String studentId) {
    final rows = _grades
        .where((grade) => grade.classId == classId && grade.studentId == studentId)
        .toList();
    if (rows.isEmpty) {
      return 0;
    }
    final sum = rows.fold<double>(0, (value, item) => value + item.score);
    return sum / rows.length;
  }
}