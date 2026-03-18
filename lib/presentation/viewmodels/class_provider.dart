import 'package:flutter/foundation.dart';

import '../../domain/entities/class_room.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/student_repository.dart';

class ClassProvider extends ChangeNotifier {
  ClassProvider({
    required ClassRepository classRepository,
    required StudentRepository studentRepository,
  }) : _classRepository = classRepository,
       _studentRepository = studentRepository;

  final ClassRepository _classRepository;
  final StudentRepository _studentRepository;

  bool _isLoading = true;
  String? _filterSubjectId;
  List<ClassRoom> _classes = [];
  List<Student> _students = [];

  bool get isLoading => _isLoading;
  String? get filterSubjectId => _filterSubjectId;
  List<ClassRoom> get classes => List.unmodifiable(_classes);
  List<Student> get students => List.unmodifiable(_students);

  List<ClassRoom> get filteredClasses {
    if (_filterSubjectId == null) {
      return classes;
    }
    return _classes
        .where((classRoom) => classRoom.subjectIds.contains(_filterSubjectId))
        .toList();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await reload();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    _classes = await _classRepository.fetchClasses();
    _students = await _studentRepository.fetchStudents();
  }

  Future<void> refresh() async {
    await reload();
    notifyListeners();
  }

  void setFilterSubjectId(String? subjectId) {
    _filterSubjectId = subjectId;
    notifyListeners();
  }

  ClassRoom? classById(String classId) {
    for (final item in _classes) {
      if (item.id == classId) {
        return item;
      }
    }
    return null;
  }

  List<Student> studentsInClass(String classId) {
    final result = _students
        .where((student) => student.classId == classId)
        .toList();
    result.sort(
      (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    );
    return result;
  }

  String classNameOf(String classId) {
    final classRoom = classById(classId);
    return classRoom?.name ?? 'Chưa phân lớp';
  }

  Future<void> addClass(String className) async {
    final normalized = className.trim().toLowerCase();
    final existed = _classes.any(
      (item) => item.name.trim().toLowerCase() == normalized,
    );
    if (existed) {
      throw Exception('Tên lớp đã tồn tại.');
    }

    await _classRepository.addClass(className);
    await reload();
    notifyListeners();
  }

  Future<void> updateClassName({
    required String classId,
    required String className,
  }) async {
    final classRoom = classById(classId);
    if (classRoom == null) {
      return;
    }

    final normalized = className.trim().toLowerCase();
    final existed = _classes.any(
      (item) =>
          item.id != classId && item.name.trim().toLowerCase() == normalized,
    );
    if (existed) {
      throw Exception('Tên lớp đã tồn tại.');
    }

    await _classRepository.updateClassRoom(classRoom.copyWith(name: className));
    await reload();
    notifyListeners();
  }

  Future<void> deleteClass(String classId) async {
    await _classRepository.deleteClass(classId);
    await reload();
    notifyListeners();
  }

  Future<void> assignSubjectToClass({
    required String classId,
    required String subjectId,
  }) async {
    final classRoom = classById(classId);
    if (classRoom == null) {
      return;
    }
    final ids = [...classRoom.subjectIds];
    if (!ids.contains(subjectId)) {
      ids.add(subjectId);
      await _classRepository.updateClassRoom(classRoom.copyWith(subjectIds: ids));
      await reload();
      notifyListeners();
    }
  }

  Future<void> removeSubjectFromClass({
    required String classId,
    required String subjectId,
  }) async {
    final classRoom = classById(classId);
    if (classRoom == null) {
      return;
    }
    final ids = [...classRoom.subjectIds]..remove(subjectId);
    await _classRepository.updateClassRoom(classRoom.copyWith(subjectIds: ids));
    await reload();
    notifyListeners();
  }

  Future<void> addStudentToClass({
    required String classId,
    required String studentId,
  }) async {
    final classRoom = classById(classId);
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

    final ids = [...classRoom.studentIds];
    if (!ids.contains(studentId)) {
      ids.add(studentId);
    }
    await _classRepository.updateClassRoom(classRoom.copyWith(studentIds: ids));
    await _studentRepository.updateStudent(student.copyWith(classId: classId));
    await reload();
    notifyListeners();
  }

  Future<void> removeStudentFromClass({
    required String classId,
    required String studentId,
  }) async {
    final classRoom = classById(classId);
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

    final ids = [...classRoom.studentIds]..remove(studentId);
    await _classRepository.updateClassRoom(classRoom.copyWith(studentIds: ids));
    await _studentRepository.updateStudent(student.copyWith(classId: ''));
    await reload();
    notifyListeners();
  }
}