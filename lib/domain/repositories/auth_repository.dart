import 'dart:typed_data';

import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser?> getCurrentUser();

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUp({
    required String displayName,
    required String email,
    required String password,
    required AppRole role,
  });

  Future<AppUser> updateAvatar(Uint8List avatarBytes);

  Future<void> provisionStudentAccountByAdmin({
    required String mssv,
    required String displayName,
  });

  Future<void> signOut();
}
