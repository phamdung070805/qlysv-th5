import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    _authSubscription = _authRepository.authStateChanges().listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
    _initialize();
  }

  final AuthRepository _authRepository;
  final ImagePicker _imagePicker = ImagePicker();
  StreamSubscription<AppUser?>? _authSubscription;

  AppUser? _user;
  bool _isLoading = true;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  Future<void> _initialize() async {
    try {
      _user = await _authRepository.getCurrentUser();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _runAction(() async {
      await _authRepository.signIn(email: email, password: password);
    });
  }

  Future<bool> signUp({
    required String displayName,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    return _runAction(() async {
      await _authRepository.signUp(
        displayName: displayName,
        email: email,
        password: password,
        role: role,
      );
    });
  }

  Future<bool> pickAvatar() async {
    try {
      clearError();
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return false;
      }

      _isLoading = true;
      notifyListeners();

      final avatarBytes = await pickedFile.readAsBytes();
      _user = await _authRepository.updateAvatar(avatarBytes);
      return true;
    } catch (error) {
      _errorMessage = _readableError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      clearError();
      await _authRepository.signOut();
    } catch (error) {
      _errorMessage = _readableError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> provisionStudentAccountByAdmin({
    required String mssv,
    required String displayName,
  }) async {
    return _runAction(() async {
      final actor = _user;
      if (actor == null || actor.role != AppRole.admin) {
        throw Exception('Chỉ admin mới có quyền tạo tài khoản tự động cho sinh viên.');
      }
      await _authRepository.provisionStudentAccountByAdmin(
        mssv: mssv,
        displayName: displayName,
      );
    });
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (error) {
      _errorMessage = _readableError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _readableError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
