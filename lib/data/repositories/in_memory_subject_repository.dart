import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';

class InMemorySubjectRepository implements SubjectRepository {
  final List<Subject> _subjects = [
    const Subject(
      id: 'sub-ltdd',
      code: 'MOB101',
      name: 'Lập trình di động',
      credits: 3,
      classIds: ['lop-cntt-01'],
    ),
    const Subject(
      id: 'sub-csdl',
      code: 'DBS201',
      name: 'Cơ sở dữ liệu',
      credits: 3,
      classIds: ['lop-cntt-01', 'lop-httt-01'],
    ),
    const Subject(
      id: 'sub-pttk',
      code: 'SYS301',
      name: 'Phân tích thiết kế HTTT',
      credits: 2,
      classIds: ['lop-httt-01'],
    ),
    const Subject(
      id: 'sub-ktqt',
      code: 'ACC220',
      name: 'Kế toán quản trị',
      credits: 2,
      classIds: ['lop-ketoan-01'],
    ),
  ];

  @override
  Future<List<Subject>> fetchSubjects() async {
    return List.unmodifiable(_subjects);
  }

  @override
  Future<Subject> addSubject({
    required String code,
    required String name,
    required int credits,
  }) async {
    final subject = Subject(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      code: code.trim().toUpperCase(),
      name: name.trim(),
      credits: credits,
    );
    _subjects.add(subject);
    return subject;
  }

  @override
  Future<Subject> updateSubject(Subject subject) async {
    final index = _subjects.indexWhere((item) => item.id == subject.id);
    if (index == -1) {
      throw Exception('Không tìm thấy môn học để cập nhật.');
    }
    _subjects[index] = subject;
    return subject;
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    _subjects.removeWhere((item) => item.id == subjectId);
  }
}
