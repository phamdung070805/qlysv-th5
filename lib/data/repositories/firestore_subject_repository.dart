import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';

class FirestoreSubjectRepository implements SubjectRepository {
  FirestoreSubjectRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _subjects =>
      _firestore.collection('subjects');

  @override
  Future<List<Subject>> fetchSubjects() async {
    final snapshot = await _subjects.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<Subject> addSubject({
    required String code,
    required String name,
    required int credits,
  }) async {
    final doc = _subjects.doc();
    final subject = Subject(
      id: doc.id,
      code: code.trim().toUpperCase(),
      name: name.trim(),
      credits: credits,
      classIds: const [],
    );
    await doc.set(_toMap(subject));
    return subject;
  }

  @override
  Future<Subject> updateSubject(Subject subject) async {
    await _subjects.doc(subject.id).set(_toMap(subject));
    return subject;
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    await _subjects.doc(subjectId).delete();
  }

  Subject _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final creditsRaw = data['credits'];
    final credits = creditsRaw is num
        ? creditsRaw.toInt()
        : int.tryParse(creditsRaw?.toString() ?? '') ?? 0;

    return Subject(
      id: doc.id,
      code: (data['code'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      credits: credits,
      classIds: _readStringList(data['classIds']),
    );
  }

  Map<String, dynamic> _toMap(Subject subject) {
    return {
      'code': subject.code,
      'name': subject.name,
      'credits': subject.credits,
      'classIds': subject.classIds,
    };
  }

  List<String> _readStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
