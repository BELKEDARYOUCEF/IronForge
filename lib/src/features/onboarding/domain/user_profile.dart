class UserProfile {
  const UserProfile({
    required this.goal,
    required this.level,
    required this.units,
    required this.frequencyPerWeek,
    required this.trainingType,
    this.bodyWeightKg,
  });

  final String goal;
  final String level;
  final String units;
  final int frequencyPerWeek;
  final String trainingType;
  final double? bodyWeightKg;

  Map<String, Object?> toMap() {
    return {
      'goal': goal,
      'level': level,
      'units': units,
      'frequencyPerWeek': frequencyPerWeek,
      'trainingType': trainingType,
      'bodyWeightKg': bodyWeightKg,
    };
  }

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      goal: map['goal'] as String,
      level: map['level'] as String,
      units: map['units'] as String,
      frequencyPerWeek: ((map['frequencyPerWeek'] as num?) ?? 3).toInt(),
      trainingType: map['trainingType'] as String,
      bodyWeightKg: (map['bodyWeightKg'] as num?)?.toDouble(),
    );
  }
}
