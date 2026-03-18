import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'mock_auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository._(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, Uint8List> _avatarsByUserId = {};

  static Future<AuthRepository> initialize({
    FirebaseOptions? firebaseOptions,
  }) async {
    if (Firebase.apps.isEmpty) {
      try {
        if (firebaseOptions == null) {
          await Firebase.initializeApp();
        } else {
          await Firebase.initializeApp(options: firebaseOptions);
        }
      } catch (_) {
        return MockAuthRepository();
      }
    }

    return FirebaseAuthRepository._(FirebaseAuth.instance);
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap(_mapUserWithRole);
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    return _mapUserWithRole(_firebaseAuth.currentUser);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = await _mapUserWithRole(credential.user);
      if (user == null) {
        throw Exception('Không thể đọc thông tin người dùng sau khi đăng nhập.');
      }

      return user;
    } on FirebaseAuthException catch (error) {
      // For legacy demo credentials, auto-create the account on first login.
      if (_isLegacyDemoAccount(email: normalizedEmail, password: password)) {
        final demoUser = await _createDemoAccountIfNeeded(
          email: normalizedEmail,
          password: password,
        );
        if (demoUser != null) {
          return demoUser;
        }
      }

      throw Exception(_translateAuthError(error));
    }
  }

  @override
  Future<AppUser> signUp({
    required String displayName,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(displayName.trim());
    if (credential.user != null) {
      await _saveRoleForUser(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        role: role,
      );
    }
    await credential.user?.reload();

    final refreshedUser = _firebaseAuth.currentUser;
    final user = await _mapUserWithRole(refreshedUser);
    if (user == null) {
      throw Exception('Không thể tạo tài khoản mới.');
    }

    return user;
  }

  @override
  Future<AppUser> updateAvatar(Uint8List avatarBytes) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('Bạn cần đăng nhập trước khi cập nhật ảnh đại diện.');
    }

    _avatarsByUserId[currentUser.uid] = avatarBytes;
    final user = await _mapUserWithRole(currentUser);
    if (user == null) {
      throw Exception('Không thể cập nhật hồ sơ người dùng.');
    }

    return user;
  }

  @override
  Future<void> provisionStudentAccountByAdmin({
    required String mssv,
    required String displayName,
  }) async {
    // Firebase client SDK cannot safely create another user while preserving
    // the current admin session. Keep this as a no-op in client mode.
    return;
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  Future<AppUser?> _mapUserWithRole(User? user) async {
    if (user == null) {
      return null;
    }

    final storedRole = await _loadRoleForUser(user.uid);
    final role = storedRole ?? _resolveRoleFromEmail(user.email);

    if (storedRole == null) {
      await _saveRoleForUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        role: role,
      );
    }

    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : 'Sinh viên',
      role: role,
      avatarBytes: _avatarsByUserId[user.uid],
    );
  }

  bool _isLegacyDemoAccount({required String email, required String password}) {
    if (password != '123456') {
      return false;
    }

    return email == 'admin@studentmanager.dev' ||
        email == 'teacher@studentmanager.dev' ||
        email == 'student@studentmanager.dev';
  }

  Future<AppUser?> _createDemoAccountIfNeeded({
    required String email,
    required String password,
  }) async {
    try {
      final createdCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final displayName = switch (email) {
        'admin@studentmanager.dev' => 'Nhóm trưởng',
        'teacher@studentmanager.dev' => 'Giảng viên mẫu',
        _ => 'Sinh viên mẫu',
      };

      await createdCredential.user?.updateDisplayName(displayName);
      await createdCredential.user?.reload();

      if (createdCredential.user != null) {
        await _saveRoleForUser(
          uid: createdCredential.user!.uid,
          email: email,
          displayName: displayName,
          role: _resolveRoleFromEmail(email),
        );
      }

      final refreshed = _firebaseAuth.currentUser;
      return _mapUserWithRole(refreshed);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        final signedIn = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return _mapUserWithRole(signedIn.user);
      }

      return null;
    }
  }

  AppRole _resolveRoleFromEmail(String? email) {
    final normalized = (email ?? '').toLowerCase();
    if (normalized.contains('admin')) {
      return AppRole.admin;
    }
    if (normalized.contains('teacher')) {
      return AppRole.teacher;
    }
    return AppRole.student;
  }

  Future<void> _saveRoleForUser({
    required String uid,
    required String email,
    required String displayName,
    required AppRole role,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'displayName': displayName,
      'role': _toRoleKey(role),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<AppRole?> _loadRoleForUser(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    return _fromRoleKey(data['role']?.toString());
  }

  String _toRoleKey(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return 'admin';
      case AppRole.teacher:
        return 'teacher';
      case AppRole.student:
        return 'student';
    }
  }

  AppRole? _fromRoleKey(String? key) {
    switch ((key ?? '').toLowerCase()) {
      case 'admin':
        return AppRole.admin;
      case 'teacher':
        return AppRole.teacher;
      case 'student':
        return AppRole.student;
      default:
        return null;
    }
  }

  String _translateAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Email đăng ký đã tồn tại. Vui lòng dùng email khác.';
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email hoặc mật khẩu chưa đúng. Nếu là tài khoản mới, hãy bấm "Tạo tài khoản mới" trước.';
      case 'too-many-requests':
        return 'Bạn thử đăng nhập quá nhiều lần. Vui lòng đợi một lúc rồi thử lại.';
      case 'network-request-failed':
        return 'Không thể kết nối mạng tới Firebase. Vui lòng kiểm tra Internet.';
      default:
        return error.message ?? 'Đăng nhập thất bại, vui lòng thử lại.';
    }
  }
}
