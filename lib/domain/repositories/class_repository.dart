import '../entities/class_room.dart';

abstract class ClassRepository {
  Future<List<ClassRoom>> fetchClasses();

  Future<ClassRoom> addClass(String className);

  Future<ClassRoom> updateClassRoom(ClassRoom classRoom);

  Future<void> deleteClass(String classId);
}
