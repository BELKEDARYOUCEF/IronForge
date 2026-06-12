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
}

