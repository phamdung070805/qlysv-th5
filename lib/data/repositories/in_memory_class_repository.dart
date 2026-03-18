import '../../domain/entities/class_room.dart';
import '../../domain/repositories/class_repository.dart';

class InMemoryClassRepository implements ClassRepository {
  final List<ClassRoom> _classes = [
    const ClassRoom(
      id: 'lop-cntt-01',
      name: 'CNTT 01',
      studentIds: ['s1', 's4', 's5', 's10'],
      subjectIds: ['sub-ltdd', 'sub-csdl'],
    ),
    const ClassRoom(
      id: 'lop-httt-01',
      name: 'HTTT 01',
      studentIds: ['s2', 's6', 's7'],
      subjectIds: ['sub-pttk', 'sub-csdl'],
    ),
    const ClassRoom(
      id: 'lop-ketoan-01',
      name: 'Kế toán 01',
      studentIds: ['s3', 's8', 's9'],
      subjectIds: ['sub-ktqt'],
    ),
  ];

  @override
  Future<List<ClassRoom>> fetchClasses() async {
    return List.unmodifiable(_classes);
  }

  @override
  Future<ClassRoom> addClass(String className) async {
    final classRoom = ClassRoom(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: className.trim(),
    );
    _classes.add(classRoom);
    return classRoom;
  }

  @override
  Future<ClassRoom> updateClassRoom(ClassRoom classRoom) async {
    final index = _classes.indexWhere((item) => item.id == classRoom.id);
    if (index == -1) {
      throw Exception('Không tìm thấy lớp học để cập nhật.');
    }
    _classes[index] = classRoom;
    return classRoom;
  }

  @override
  Future<void> deleteClass(String classId) async {
    _classes.removeWhere((item) => item.id == classId);
  }
}
