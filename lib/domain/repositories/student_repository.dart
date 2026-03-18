import '../entities/student.dart';

abstract class StudentRepository {
  Future<List<Student>> fetchStudents();

  Future<Student> addStudent(Student student);

  Future<Student> updateStudent(Student student);

  Future<void> deleteStudent(String studentId);

  Future<Student> toggleFavorite(String studentId);

  Future<Student> updateAvatarUrl(String studentId, String avatarUrl);
}
