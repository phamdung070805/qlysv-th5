import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/class_room.dart';
import '../../domain/repositories/class_repository.dart';

class FirestoreClassRepository implements ClassRepository {
  FirestoreClassRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _classes =>
      _firestore.collection('classes');

  @override
  Future<List<ClassRoom>> fetchClasses() async {
    final snapshot = await _classes.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<ClassRoom> addClass(String className) async {
    final doc = _classes.doc();
    final classRoom = ClassRoom(id: doc.id, name: className.trim());
    await doc.set(_toMap(classRoom));
    return classRoom;
  }

  @override
  Future<ClassRoom> updateClassRoom(ClassRoom classRoom) async {
    await _classes.doc(classRoom.id).set(_toMap(classRoom));
    return classRoom;
  }

  @override
  Future<void> deleteClass(String classId) async {
    await _classes.doc(classId).delete();
  }

  ClassRoom _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ClassRoom(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      studentIds: _readStringList(data['studentIds']),
      subjectIds: _readStringList(data['subjectIds']),
    );
  }

  Map<String, dynamic> _toMap(ClassRoom classRoom) {
    return {
      'name': classRoom.name,
      'studentIds': classRoom.studentIds,
      'subjectIds': classRoom.subjectIds,
    };
  }

  List<String> _readStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
