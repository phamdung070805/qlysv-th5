class ClassRoom {
  const ClassRoom({
    required this.id,
    required this.name,
    this.studentIds = const [],
    this.subjectIds = const [],
  });

  final String id;
  final String name;
  final List<String> studentIds;
  final List<String> subjectIds;

  ClassRoom copyWith({
    String? id,
    String? name,
    List<String>? studentIds,
    List<String>? subjectIds,
  }) {
    return ClassRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      studentIds: studentIds ?? this.studentIds,
      subjectIds: subjectIds ?? this.subjectIds,
    );
  }
}
