import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _lastViewedClassKey = 'last_viewed_class';
  static const String _lastViewedSubjectKey = 'last_viewed_subject';

  bool _isDarkMode = false;
  String _lastViewedClassId = '';
  String _lastViewedSubjectId = '';

  bool get isDarkMode => _isDarkMode;
  String get lastViewedClassId => _lastViewedClassId;
  String get lastViewedSubjectId => _lastViewedSubjectId;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _lastViewedClassId = prefs.getString(_lastViewedClassKey) ?? '';
    _lastViewedSubjectId = prefs.getString(_lastViewedSubjectKey) ?? '';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setLastViewedClassId(String classId) async {
    _lastViewedClassId = classId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastViewedClassKey, classId);
  }

  Future<void> setLastViewedSubjectId(String subjectId) async {
    _lastViewedSubjectId = subjectId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastViewedSubjectKey, subjectId);
  }
}
