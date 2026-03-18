class Subject {
  const Subject({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    this.classIds = const [],
  });

  final String id;
  final String code;
  final String name;
  final int credits;
  final List<String> classIds;

  Subject copyWith({
    String? id,
    String? code,
    String? name,
    int? credits,
    List<String>? classIds,
  }) {
    return Subject(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      credits: credits ?? this.credits,
      classIds: classIds ?? this.classIds,
    );
  }
}
