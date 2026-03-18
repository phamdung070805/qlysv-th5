import 'dart:async';
import 'dart:typed_data';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  final Map<String, _StoredAccount> _accountsByEmail = {
    'admin@studentmanager.dev': _StoredAccount(
      password: '123456',
      user: const AppUser(
        id: 'seed-admin',
        email: 'admin@studentmanager.dev',
        displayName: 'Nhóm trưởng',
        role: AppRole.admin,
      ),
    ),
    'teacher@studentmanager.dev': _StoredAccount(
      password: '123456',
      user: const AppUser(
        id: 'seed-teacher',
        email: 'teacher@studentmanager.dev',
        displayName: 'Giảng viên mẫu',
        role: AppRole.teacher,
      ),
    ),
    'student@studentmanager.dev': _StoredAccount(
      password: '123456',
      user: const AppUser(
        id: 'seed-student',
        email: 'student@studentmanager.dev',
        displayName: 'Sinh viên mẫu',
        role: AppRole.student,
      ),
    ),
  };

  AppUser? _currentUser;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  Future<AppUser?> getCurrentUser() async => _currentUser;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _accountsByEmail[normalizedEmail];

    if (account == null || account.password != password) {
      throw Exception('Email hoặc mật khẩu không đúng.');
    }

    _currentUser = account.user;
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> signUp({
    required String displayName,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_accountsByEmail.containsKey(normalizedEmail)) {
      throw Exception('Email đã tồn tại trong hệ thống.');
    }

    final user = AppUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      email: normalizedEmail,
      displayName: displayName.trim(),
      role: role,
    );

    _accountsByEmail[normalizedEmail] = _StoredAccount(
      password: password,
      user: user,
    );

    _currentUser = user;
    _controller.add(_currentUser);
    return user;
  }

  @override
  Future<AppUser> updateAvatar(Uint8List avatarBytes) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      throw Exception('Bạn cần đăng nhập trước khi cập nhật ảnh đại diện.');
    }

    final updatedUser = currentUser.copyWith(avatarBytes: avatarBytes);
    _currentUser = updatedUser;
    _accountsByEmail[currentUser.email] = _StoredAccount(
      password: _accountsByEmail[currentUser.email]!.password,
      user: updatedUser,
    );
    _controller.add(updatedUser);
    return updatedUser;
  }

  @override
  Future<void> provisionStudentAccountByAdmin({
    required String mssv,
    required String displayName,
  }) async {
    final accountKey = mssv.trim();
    if (accountKey.isEmpty) {
      throw Exception('MSSV không hợp lệ để tạo tài khoản tự động.');
    }
    if (_accountsByEmail.containsKey(accountKey)) {
      return;
    }

    final user = AppUser(
      id: 'sv-$accountKey',
      email: accountKey,
      displayName: displayName.trim().isEmpty ? 'Sinh viên $accountKey' : displayName.trim(),
      role: AppRole.student,
    );
    _accountsByEmail[accountKey] = _StoredAccount(password: accountKey, user: user);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}

class _StoredAccount {
  const _StoredAccount({required this.password, required this.user});

  final String password;
  final AppUser user;
}
