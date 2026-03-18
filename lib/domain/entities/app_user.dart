import 'dart:typed_data';

enum AppRole { admin, teacher, student }

extension AppRoleLabel on AppRole {
  String get label {
    switch (this) {
      case AppRole.admin:
        return 'Admin';
      case AppRole.teacher:
        return 'Giáo viên';
      case AppRole.student:
        return 'Sinh viên';
    }
  }
}

extension AppRolePermission on AppRole {
  bool get canEditAcademicData =>
      this == AppRole.admin || this == AppRole.teacher;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.role = AppRole.student,
    this.avatarBytes,
  });

  final String id;
  final String email;
  final String displayName;
  final AppRole role;
  final Uint8List? avatarBytes;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    AppRole? role,
    Uint8List? avatarBytes,
    bool clearAvatar = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      avatarBytes: clearAvatar ? null : avatarBytes ?? this.avatarBytes,
    );
  }
}
