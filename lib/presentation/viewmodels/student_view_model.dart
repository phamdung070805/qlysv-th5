import 'package:flutter/foundation.dart';

import '../../data/services/mock_supabase_storage_service.dart';
import '../../domain/entities/class_room.dart';
import '../../domain/entities/grade.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/grade_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/subject_repository.dart';

class StudentViewModel extends ChangeNotifier {
  StudentViewModel({
    required StudentRepository studentRepository,
    required ClassRepository classRepository,
    required SubjectRepository subjectRepository,
    required GradeRepository gradeRepository,
    required MockSupabaseStorageService storageService,
  }) : _studentRepository = studentRepository,
       _classRepository = classRepository,
       _subjectRepository = subjectRepository,
       _gradeRepository = gradeRepository,
       _storageService = storageService;

  final StudentRepository _studentRepository;
  final ClassRepository _classRepository;
  final SubjectRepository _subjectRepository;
  final GradeRepository _gradeRepository;
  final MockSupabaseStorageService _storageService;

  bool _isLoading = true;
  String _studentSearchQuery = '';
  String _subjectSearchQuery = '';
  String? _classFilterId;
  bool _sortScoreHighToLow = true;

  List<Student> _students = [];
  List<ClassRoom> _classes = [];
  List<Subject> _subjects = [];
  List<Grade> _grades = [];

  bool get isLoading => _isLoading;
  String get studentSearchQuery => _studentSearchQuery;
  String get subjectSearchQuery => _subjectSearchQuery;
  String? get classFilterId => _classFilterId;
  bool get sortScoreHighToLow => _sortScoreHighToLow;
  List<ClassRoom> get classes => List.unmodifiable(_classes);
  List<Student> get students => List.unmodifiable(_students);
  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<Grade> get grades => List.unmodifiable(_grades);

  List<Subject> get filteredSubjects {
    if (_subjectSearchQuery.trim().isEmpty) {
      return List.unmodifiable(_subjects);
    }
    final query = _subjectSearchQuery.toLowerCase();
    return _subjects
        .where((subject) => subject.name.toLowerCase().contains(query))
        .toList();
  }

  List<Student> get filteredStudents {
    final result = _students.where((student) {
      if (_classFilterId != null && student.classId != _classFilterId) {
        return false;
      }
      if (_studentSearchQuery.trim().isNotEmpty) {
        final q = _studentSearchQuery.toLowerCase();
        final contains =
            student.fullName.toLowerCase().contains(q) ||
            student.mssv.contains(q) ||
            student.email.toLowerCase().contains(q);
        if (!contains) {
          return false;
        }
      }
      return true;
    }).toList();

    result.sort((a, b) {
      final classCompare = classNameOf(
        a.classId,
      ).toLowerCase().compareTo(classNameOf(b.classId).toLowerCase());
      if (classCompare != 0) {
        return classCompare;
      }
      return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
    });
    return result;
  }

  List<Student> studentsInClass(String classId) {
    return _students.where((student) => student.classId == classId).toList();
  }

  List<Subject> subjectsInClass(String classId) {
    ClassRoom? classRoom;
    for (final item in _classes) {
      if (item.id == classId) {
        classRoom = item;
        break;
      }
    }
    if (classRoom == null) {
      return [];
    }
    final safeClassRoom = classRoom;

    return _subjects
        .where((subject) => safeClassRoom.subjectIds.contains(subject.id))
        .toList();
  }

  List<Grade> gradesInClass(String classId) {
    return _grades.where((grade) => grade.classId == classId).toList();
  }

  List<Grade> gradesByClassAndSubject(String classId, String subjectId) {
    final list = _grades
        .where(
          (grade) => grade.classId == classId && grade.subjectId == subjectId,
        )
        .toList();
    list.sort(
      (a, b) => _sortScoreHighToLow
          ? b.score.compareTo(a.score)
          : a.score.compareTo(b.score),
    );
    return list;
  }

  double classAverageBySubject(String classId, String subjectId) {
    final classGrades = gradesByClassAndSubject(classId, subjectId);
    if (classGrades.isEmpty) {
      return 0;
    }
    final sum = classGrades.fold<double>(
      0,
      (value, item) => value + item.score,
    );
    return sum / classGrades.length;
  }

  double classGpa(String classId) {
    final classGrades = gradesInClass(classId);
    if (classGrades.isEmpty) {
      return 0;
    }
    final sum = classGrades.fold<double>(
      0,
      (value, item) => value + item.score,
    );
    return sum / classGrades.length;
  }

  Map<String, int> classRankDistribution(String classId) {
    final classStudents = studentsInClass(classId);
    int gioi = 0;
    int kha = 0;
    int tb = 0;

    for (final student in classStudents) {
      final studentGrades = _grades
          .where(
            (grade) =>
                grade.classId == classId && grade.studentId == student.id,
          )
          .toList();
      if (studentGrades.isEmpty) {
        tb++;
        continue;
      }
      final avg =
          studentGrades.fold<double>(0, (value, grade) => value + grade.score) /
          studentGrades.length;
      if (avg >= 8) {
        gioi++;
      } else if (avg >= 6.5) {
        kha++;
      } else {
        tb++;
      }
    }

    return {'Giỏi': gioi, 'Khá': kha, 'Trung bình': tb};
  }

  Map<String, int> scoreBuckets(String classId, String subjectId) {
    final rows = gradesByClassAndSubject(classId, subjectId);
    final result = {'0-4': 0, '4-6': 0, '6-8': 0, '8-10': 0};
    for (final grade in rows) {
      if (grade.score < 4) {
        result['0-4'] = result['0-4']! + 1;
      } else if (grade.score < 6) {
        result['4-6'] = result['4-6']! + 1;
      } else if (grade.score < 8) {
        result['6-8'] = result['6-8']! + 1;
      } else {
        result['8-10'] = result['8-10']! + 1;
      }
    }
    return result;
  }

  String classNameOf(String classId) {
    for (final item in _classes) {
      if (item.id == classId) {
        return item.name;
      }
    }
    return 'Chưa phân lớp';
  }

  String subjectNameOf(String subjectId) {
    for (final item in _subjects) {
      if (item.id == subjectId) {
        return item.name;
      }
    }
    return 'Môn chưa xác định';
  }

  Subject? subjectById(String subjectId) {
    for (final item in _subjects) {
      if (item.id == subjectId) {
        return item;
      }
    }
    return null;
  }

  Student? findById(String studentId) {
    for (final student in _students) {
      if (student.id == studentId) {
        return student;
      }
    }
    return null;
  }

  ClassRoom? _classById(String classId) {
    for (final item in _classes) {
      if (item.id == classId) {
        return item;
      }
    }
    return null;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await _reloadAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _reloadAll() async {
    _classes = await _classRepository.fetchClasses();
    _students = await _studentRepository.fetchStudents();
    _subjects = await _subjectRepository.fetchSubjects();
    _grades = await _gradeRepository.fetchGrades();
  }

  void setStudentSearchQuery(String value) {
    _studentSearchQuery = value;
    notifyListeners();
  }

  void setSubjectSearchQuery(String value) {
    _subjectSearchQuery = value;
    notifyListeners();
  }

  void setClassFilterId(String? value) {
    _classFilterId = value;
    notifyListeners();
  }

  void setSortScoreHighToLow(bool value) {
    _sortScoreHighToLow = value;
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    _validateStudentUniqueness(mssv: student.mssv, email: student.email);

    final created = await _studentRepository.addStudent(student);
    final classRoom = _classById(created.classId);
    if (classRoom != null && !classRoom.studentIds.contains(created.id)) {
      await _classRepository.updateClassRoom(
        classRoom.copyWith(studentIds: [...classRoom.studentIds, created.id]),
      );
    }
    await _reloadAll();
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    _validateStudentUniqueness(
      mssv: student.mssv,
      email: student.email,
      excludeStudentId: student.id,
    );

    final old = findById(student.id);
    await _studentRepository.updateStudent(student);

    if (old != null && old.classId != student.classId) {
      final oldClass = _classById(old.classId);
      if (oldClass != null) {
        final pruned = [...oldClass.studentIds]..remove(student.id);
        await _classRepository.updateClassRoom(
          oldClass.copyWith(studentIds: pruned),
        );
      }

      final newClass = _classById(student.classId);
      if (newClass != null && !newClass.studentIds.contains(student.id)) {
        await _classRepository.updateClassRoom(
          newClass.copyWith(studentIds: [...newClass.studentIds, student.id]),
        );
      }
    }

    await _reloadAll();
    notifyListeners();
  }

  Future<void> deleteStudent(String studentId) async {
    final old = findById(studentId);
    await _studentRepository.deleteStudent(studentId);
    if (old != null) {
      final classRoom = _classById(old.classId);
      if (classRoom != null) {
        final pruned = [...classRoom.studentIds]..remove(studentId);
        await _classRepository.updateClassRoom(
          classRoom.copyWith(studentIds: pruned),
        );
      }
    }
    await _reloadAll();
    notifyListeners();
  }

  Future<void> uploadStudentAvatar({
    required String studentId,
    required String fileName,
  }) async {
    final link = await _storageService.uploadStudentAvatar(studentId, fileName);
    await _studentRepository.updateAvatarUrl(studentId, link);
    await _reloadAll();
    notifyListeners();
  }

  Future<void> addClass(String className) async {
    await _classRepository.addClass(className);
    await _reloadAll();
    notifyListeners();
  }

  Future<void> deleteClass(String classId) async {
    await _classRepository.deleteClass(classId);
    await _reloadAll();
    notifyListeners();
  }

  Future<void> addStudentToClass({
    required String classId,
    required String studentId,
  }) async {
    ClassRoom? classRoom;
    for (final item in _classes) {
      if (item.id == classId) {
        classRoom = item;
        break;
      }
    }
    Student? student;
    for (final item in _students) {
      if (item.id == studentId) {
        student = item;
        break;
      }
    }
    if (classRoom == null || student == null) {
      return;
    }

    final newStudentIds = [...classRoom.studentIds];
    if (!newStudentIds.contains(studentId)) {
      newStudentIds.add(studentId);
    }
    await _classRepository.updateClassRoom(
      classRoom.copyWith(studentIds: newStudentIds),
    );
    await _studentRepository.updateStudent(student.copyWith(classId: classId));
    await _reloadAll();
    notifyListeners();
  }

  Future<void> removeStudentFromClass({
    required String classId,
    required String studentId,
  }) async {
    ClassRoom? classRoom;
    for (final item in _classes) {
      if (item.id == classId) {
        classRoom = item;
        break;
      }
    }
    Student? student;
    for (final item in _students) {
      if (item.id == studentId) {
        student = item;
        break;
      }
    }
    if (classRoom == null || student == null) {
      return;
    }

    final newStudentIds = [...classRoom.studentIds]..remove(studentId);
    await _classRepository.updateClassRoom(
      classRoom.copyWith(studentIds: newStudentIds),
    );
    await _studentRepository.updateStudent(student.copyWith(classId: ''));
    await _reloadAll();
    notifyListeners();
  }

  Future<void> assignSubjectToClass({
    required String classId,
    required String subjectId,
  }) async {
    ClassRoom? classRoom;
    for (final item in _classes) {
      if (item.id == classId) {
        classRoom = item;
        break;
      }
    }
    if (classRoom == null) {
      return;
    }

    final subjectIds = [...classRoom.subjectIds];
    if (!subjectIds.contains(subjectId)) {
      subjectIds.add(subjectId);
    }
    await _classRepository.updateClassRoom(
      classRoom.copyWith(subjectIds: subjectIds),
    );
    final subject = subjectById(subjectId);
    if (subject != null && !subject.classIds.contains(classId)) {
      await _subjectRepository.updateSubject(
        subject.copyWith(classIds: [...subject.classIds, classId]),
      );
    }
    await _reloadAll();
    notifyListeners();
  }

  Future<void> addSubject({
    required String code,
    required String name,
    required int credits,
  }) async {
    await _subjectRepository.addSubject(
      code: code,
      name: name,
      credits: credits,
    );
    await _reloadAll();
    notifyListeners();
  }

  Future<void> updateSubject(Subject subject) async {
    await _subjectRepository.updateSubject(subject);
    await _reloadAll();
    notifyListeners();
  }

  Future<void> deleteSubject(String subjectId) async {
    await _subjectRepository.deleteSubject(subjectId);
    final updatedClasses = await _classRepository.fetchClasses();
    for (final classRoom in updatedClasses) {
      if (classRoom.subjectIds.contains(subjectId)) {
        final prunedIds = [...classRoom.subjectIds]..remove(subjectId);
        await _classRepository.updateClassRoom(
          classRoom.copyWith(subjectIds: prunedIds),
        );
      }
    }
    await _reloadAll();
    notifyListeners();
  }

  Future<void> upsertGrade({
    required String classId,
    required String studentId,
    required String subjectId,
    required double score,
  }) async {
    await _gradeRepository.upsertGrade(
      classId: classId,
      studentId: studentId,
      subjectId: subjectId,
      score: score,
    );
    await _reloadAll();
    notifyListeners();
  }

  void _validateStudentUniqueness({
    required String mssv,
    required String email,
    String? excludeStudentId,
  }) {
    final normalizedMssv = mssv.trim();
    final normalizedEmail = email.trim().toLowerCase();

    for (final item in _students) {
      if (excludeStudentId != null && item.id == excludeStudentId) {
        continue;
      }

      if (item.mssv.trim() == normalizedMssv) {
        throw Exception('MSSV đã tồn tại trong hệ thống.');
      }

      if (item.email.trim().toLowerCase() == normalizedEmail) {
        throw Exception('Email sinh viên đã tồn tại trong hệ thống.');
      }
    }
  }
}
