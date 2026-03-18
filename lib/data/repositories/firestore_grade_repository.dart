import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/grade.dart';
import '../../domain/repositories/grade_repository.dart';

class FirestoreGradeRepository implements GradeRepository {
  FirestoreGradeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _grades =>
      _firestore.collection('grades');

  @override
  Future<List<Grade>> fetchGrades() async {
    final snapshot = await _grades.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<Grade> upsertGrade({
    required String classId,
    required String studentId,
    required String subjectId,
    required double score,
  }) async {
    final docId = createGradeDocId(
      studentId: studentId,
      classId: classId,
      subjectId: subjectId,
    );
    final grade = Grade(
      id: docId,
      classId: classId,
      studentId: studentId,
      subjectId: subjectId,
      score: score,
    );
    await _grades.doc(docId).set(_toMap(grade));
    return grade;
  }

  @override
  String createGradeDocId({
    required String studentId,
    required String classId,
    required String subjectId,
  }) {
    return [studentId, classId, subjectId].join('_');
  }

  Grade _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final scoreRaw = data['score'];
    final score = scoreRaw is num
        ? scoreRaw.toDouble()
        : double.tryParse(scoreRaw?.toString() ?? '') ?? 0;

    return Grade(
      id: doc.id,
      classId: (data['classId'] ?? '').toString(),
      studentId: (data['studentId'] ?? '').toString(),
      subjectId: (data['subjectId'] ?? '').toString(),
      score: score,
    );
  }

  Map<String, dynamic> _toMap(Grade grade) {
    return {
      'classId': grade.classId,
      'studentId': grade.studentId,
      'subjectId': grade.subjectId,
      'score': grade.score,
    };
  }
}
