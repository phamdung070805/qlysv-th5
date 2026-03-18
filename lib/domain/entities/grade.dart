class Grade {
  const Grade({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.subjectId,
    required this.score,
  });

  final String id;
  final String classId;
  final String studentId;
  final String subjectId;
  final double score;

  Grade copyWith({
    String? id,
    String? classId,
    String? studentId,
    String? subjectId,
    double? score,
  }) {
    return Grade(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      score: score ?? this.score,
    );
  }
}
