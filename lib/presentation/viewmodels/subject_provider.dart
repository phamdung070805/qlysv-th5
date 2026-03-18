import 'package:flutter/foundation.dart';

import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';

class SubjectProvider extends ChangeNotifier {
  SubjectProvider({required SubjectRepository subjectRepository})
    : _subjectRepository = subjectRepository;

  final SubjectRepository _subjectRepository;

  bool _isLoading = true;
  String _searchQuery = '';
  List<Subject> _subjects = [];

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<Subject> get subjects => List.unmodifiable(_subjects);

  List<Subject> get filteredSubjects {
    if (_searchQuery.trim().isEmpty) {
      return subjects;
    }
    final query = _searchQuery.toLowerCase();
    return _subjects
        .where(
          (subject) =>
              subject.name.toLowerCase().contains(query) ||
              subject.code.toLowerCase().contains(query),
        )
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
    _subjects = await _subjectRepository.fetchSubjects();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Subject? subjectById(String subjectId) {
    for (final item in _subjects) {
      if (item.id == subjectId) {
        return item;
      }
    }
    return null;
  }

  String subjectNameOf(String subjectId) {
    return subjectById(subjectId)?.name ?? 'Môn chưa xác định';
  }

  Future<void> addSubject({
    required String code,
    required String name,
    required int credits,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    final existed = _subjects.any(
      (item) => item.code.trim().toUpperCase() == normalizedCode,
    );
    if (existed) {
      throw Exception('Mã môn học đã tồn tại.');
    }

    await _subjectRepository.addSubject(code: code, name: name, credits: credits);
    await reload();
    notifyListeners();
  }

  Future<void> updateSubject(Subject subject) async {
    final normalizedCode = subject.code.trim().toUpperCase();
    final existed = _subjects.any(
      (item) =>
          item.id != subject.id &&
          item.code.trim().toUpperCase() == normalizedCode,
    );
    if (existed) {
      throw Exception('Mã môn học đã tồn tại.');
    }

    await _subjectRepository.updateSubject(subject);
    await reload();
    notifyListeners();
  }

  Future<void> deleteSubject(String subjectId) async {
    await _subjectRepository.deleteSubject(subjectId);
    await reload();
    notifyListeners();
  }

  Future<void> attachClassToSubject({
    required String subjectId,
    required String classId,
  }) async {
    final subject = subjectById(subjectId);
    if (subject == null) {
      return;
    }
    final ids = [...subject.classIds];
    if (!ids.contains(classId)) {
      ids.add(classId);
      await _subjectRepository.updateSubject(subject.copyWith(classIds: ids));
      await reload();
      notifyListeners();
    }
  }

  Future<void> detachClassFromSubject({
    required String subjectId,
    required String classId,
  }) async {
    final subject = subjectById(subjectId);
    if (subject == null) {
      return;
    }
    final ids = [...subject.classIds]..remove(classId);
    await _subjectRepository.updateSubject(subject.copyWith(classIds: ids));
    await reload();
    notifyListeners();
  }
}