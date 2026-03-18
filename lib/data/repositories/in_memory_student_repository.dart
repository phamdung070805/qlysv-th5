import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';

class InMemoryStudentRepository implements StudentRepository {
  final List<Student> _students = [
    Student(
      id: 's1',
      mssv: '22110001',
      fullName: 'Nguyen Van An',
      email: 'an22110001@stu.edu.vn',
      birthDate: DateTime(2003, 8, 10),
      classId: 'lop-cntt-01',
      avatarUrl: 'https://i.pravatar.cc/200?img=1',
    ),
    Student(
      id: 's2',
      mssv: '22110002',
      fullName: 'Tran Thi Bich',
      email: 'bich22110002@stu.edu.vn',
      birthDate: DateTime(2003, 2, 3),
      classId: 'lop-httt-01',
      avatarUrl: 'https://i.pravatar.cc/200?img=2',
    ),
    Student(
      id: 's3',
      mssv: '20190003',
      fullName: 'Le Minh Chau',
      email: 'chau20190003@stu.edu.vn',
      birthDate: DateTime(2001, 12, 12),
      classId: 'lop-ketoan-01',
      avatarUrl: 'https://i.pravatar.cc/200?img=3',
    ),
    Student(
      id: 's4',
      mssv: '22110004',
      fullName: 'Pham Gia Bao',
      email: 'bao22110004@stu.edu.vn',
      birthDate: DateTime(2003, 5, 6),
      classId: 'lop-cntt-01',
      avatarUrl: 'https://i.pravatar.cc/200?img=4',
    ),
    Student(
      id: 's5',
      mssv: '22110005',
      fullName: 'Do Thu Ha',
      email: 'ha22110005@stu.edu.vn',
      birthDate: DateTime(2003, 9, 21),
      classId: 'lop-cntt-01',
      avatarUrl: 'https://i.pravatar.cc/200?img=5',
    ),
    Student(
      id: 's6',
      mssv: '22110006',
      fullName: 'Bui Tuan Kiet',
      email: 'kiet22110006@stu.edu.vn',
      birthDate: DateTime(2003, 1, 15),
      classId: 'lop-httt-01',
      avatarUrl: 'https://i.pravatar.cc/200?img=6',
    ),
    Student(
      id: 's7',
      mssv: '22110007',
      fullName: 'Hoang Minh Khang',
      email: 'khang22110007@stu.edu.vn',
      birthDate: DateTime(2003, 11, 2),
      classId: 'lop-httt-01',
      avatarUrl: 'https://i.pravatar.cc/200?img=7',
    ),
    Student(
      id: 's8',
      mssv: '22110008',
      fullName: 'Nguyen Thi Lan',
      email: 'lan22110008@stu.edu.vn',
      birthDate: DateTime(2003, 3, 18),
      classId: 'lop-ketoan-01',
      avatarUrl: 'https://i.pravatar.cc/200?img=8',
    ),
    Student(
      id: 's9',
      mssv: '22110009',
      fullName: 'Tran Quoc Nam',
      email: 'nam22110009@stu.edu.vn',
      birthDate: DateTime(2003, 7, 9),
      classId: 'lop-ketoan-01',
      avatarUrl: 'https://i.pravatar.cc/200?img=9',
    ),
    Student(
      id: 's10',
      mssv: '22110010',
      fullName: 'Vo Ngoc Nhi',
      email: 'nhi22110010@stu.edu.vn',
      birthDate: DateTime(2003, 4, 30),
      classId: 'lop-cntt-01',
      avatarUrl: 'https://i.pravatar.cc/200?img=10',
    ),
  ];

  @override
  Future<List<Student>> fetchStudents() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return List.unmodifiable(_students);
  }

  @override
  Future<Student> addStudent(Student student) async {
    final created = student.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
    );
    _students.add(created);
    return created;
  }

  @override
  Future<Student> updateStudent(Student student) async {
    final index = _students.indexWhere((item) => item.id == student.id);
    if (index == -1) {
      throw Exception('Không tìm thấy sinh viên để cập nhật.');
    }
    _students[index] = student;
    return student;
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    _students.removeWhere((item) => item.id == studentId);
  }

  @override
  Future<Student> toggleFavorite(String studentId) async {
    final index = _students.indexWhere((item) => item.id == studentId);
    if (index == -1) {
      throw Exception('Không tìm thấy sinh viên.');
    }
    final updated = _students[index].copyWith(
      isFavorite: !_students[index].isFavorite,
    );
    _students[index] = updated;
    return updated;
  }

  @override
  Future<Student> updateAvatarUrl(String studentId, String avatarUrl) async {
    final index = _students.indexWhere((item) => item.id == studentId);
    if (index == -1) {
      throw Exception('Không tìm thấy sinh viên.');
    }
    final updated = _students[index].copyWith(avatarUrl: avatarUrl);
    _students[index] = updated;
    return updated;
  }
}
