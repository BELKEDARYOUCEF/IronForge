class Routine {
  const Routine({
    required this.id,
    required this.name,
    required this.daysPerWeek,
    required this.progressionStepKg,
    this.notes,
  });

  final String id;
  final String name;
  final int daysPerWeek;
  final double progressionStepKg;
  final String? notes;

  String get progressionLabel => '+${progressionStepKg.toStringAsFixed(progressionStepKg % 1 == 0 ? 0 : 1)} kg when all target reps are hit';

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'daysPerWeek': daysPerWeek,
      'progressionStepKg': progressionStepKg,
      'notes': notes,
    };
  }

  factory Routine.fromMap(Map<dynamic, dynamic> map) {
    return Routine(
      id: map['id'] as String,
      name: map['name'] as String,
      daysPerWeek: ((map['daysPerWeek'] as num?) ?? 3).toInt(),
      progressionStepKg: ((map['progressionStepKg'] as num?) ?? 2.5).toDouble(),
      notes: map['notes'] as String?,
    );
  }
}
