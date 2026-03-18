class Student {
  const Student({
    required this.id,
    required this.mssv,
    required this.fullName,
    required this.email,
    required this.birthDate,
    required this.classId,
    this.isFavorite = false,
    this.avatarUrl,
  });

  final String id;
  final String mssv;
  final String fullName;
  final String email;
  final DateTime birthDate;
  final String classId;
  final bool isFavorite;
  final String? avatarUrl;

  bool get hasAvatar => avatarUrl != null && avatarUrl!.trim().isNotEmpty;

  String get displayInitial {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return 'S';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  Student copyWith({
    String? id,
    String? mssv,
    String? fullName,
    String? email,
    DateTime? birthDate,
    String? classId,
    bool? isFavorite,
    String? avatarUrl,
  }) {
    return Student(
      id: id ?? this.id,
      mssv: mssv ?? this.mssv,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      classId: classId ?? this.classId,
      isFavorite: isFavorite ?? this.isFavorite,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
