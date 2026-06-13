class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.equipment,
    this.videoUrl,
    this.isFavorite = false,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String primaryMuscle;
  final String equipment;
  final String? videoUrl;
  final bool isFavorite;
  final bool isCustom;

  Exercise copyWith({
    String? id,
    String? name,
    String? primaryMuscle,
    String? equipment,
    String? videoUrl,
    bool? isFavorite,
    bool? isCustom,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      equipment: equipment ?? this.equipment,
      videoUrl: videoUrl ?? this.videoUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'primaryMuscle': primaryMuscle,
      'equipment': equipment,
      'videoUrl': videoUrl,
      'isFavorite': isFavorite,
      'isCustom': isCustom,
    };
  }

  factory Exercise.fromMap(Map<dynamic, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      primaryMuscle: map['primaryMuscle'] as String,
      equipment: map['equipment'] as String,
      videoUrl: map['videoUrl'] as String?,
      isFavorite: (map['isFavorite'] as bool?) ?? false,
      isCustom: (map['isCustom'] as bool?) ?? false,
    );
  }
}
