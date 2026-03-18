import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';

class FirestoreStudentRepository implements StudentRepository {
  FirestoreStudentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _students =>
      _firestore.collection('students');

  @override
  Future<List<Student>> fetchStudents() async {
    final snapshot = await _students.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<Student> addStudent(Student student) async {
    final doc = _students.doc();
    final created = student.copyWith(id: doc.id);
    await doc.set(_toMap(created));
    return created;
  }

  @override
  Future<Student> updateStudent(Student student) async {
    await _students.doc(student.id).set(_toMap(student));
    return student;
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    await _students.doc(studentId).delete();
  }

  @override
  Future<Student> toggleFavorite(String studentId) async {
    final docRef = _students.doc(studentId);
    return _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) {
        throw Exception('Khong tim thay sinh vien.');
      }
      final student = _fromDoc(snapshot);
      final updated = student.copyWith(isFavorite: !student.isFavorite);
      tx.set(docRef, _toMap(updated));
      return updated;
    });
  }

  @override
  Future<Student> updateAvatarUrl(String studentId, String avatarUrl) async {
    final docRef = _students.doc(studentId);
    return _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) {
        throw Exception('Khong tim thay sinh vien.');
      }
      final student = _fromDoc(snapshot);
      final updated = student.copyWith(avatarUrl: avatarUrl);
      tx.set(docRef, _toMap(updated));
      return updated;
    });
  }

  Student _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final birthDateRaw = data['birthDate'];
    DateTime birthDate;
    if (birthDateRaw is Timestamp) {
      birthDate = birthDateRaw.toDate();
    } else if (birthDateRaw is String) {
      birthDate = DateTime.tryParse(birthDateRaw) ?? DateTime(2000, 1, 1);
    } else {
      birthDate = DateTime(2000, 1, 1);
    }

    return Student(
      id: doc.id,
      mssv: (data['mssv'] ?? '').toString(),
      fullName: (data['fullName'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      birthDate: birthDate,
      classId: (data['classId'] ?? '').toString(),
      isFavorite: data['isFavorite'] == true,
      avatarUrl: data['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> _toMap(Student student) {
    return {
      'mssv': student.mssv,
      'fullName': student.fullName,
      'email': student.email,
      'birthDate': Timestamp.fromDate(student.birthDate),
      'classId': student.classId,
      'isFavorite': student.isFavorite,
      'avatarUrl': student.avatarUrl,
    };
  }
}
