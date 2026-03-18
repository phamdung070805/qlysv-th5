import '../entities/subject.dart';

abstract class SubjectRepository {
  Future<List<Subject>> fetchSubjects();

  Future<Subject> addSubject({
    required String code,
    required String name,
    required int credits,
  });

  Future<Subject> updateSubject(Subject subject);

  Future<void> deleteSubject(String subjectId);
}
