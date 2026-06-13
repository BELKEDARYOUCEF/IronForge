enum SetType { standard, warmup, dropSet, restPause, myoRep, superset, giantSet }

class LoggedSet {
  const LoggedSet({
    required this.weight,
    required this.reps,
    this.rpe,
    this.notes,
    this.type = SetType.standard,
    this.completedAt,
  });

  final double weight;
  final int reps;
  final double? rpe;
  final String? notes;
  final SetType type;
  final DateTime? completedAt;

  double get volume => weight * reps;

  double get estimatedOneRepMax => reps <= 1 ? weight : weight * (1 + reps / 30);

  Map<String, Object?> toMap() {
    return {
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
      'notes': notes,
      'type': type.name,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory LoggedSet.fromMap(Map<dynamic, dynamic> map) {
    return LoggedSet(
      weight: ((map['weight'] as num?) ?? 0).toDouble(),
      reps: ((map['reps'] as num?) ?? 0).toInt(),
      rpe: (map['rpe'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      type: SetType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => SetType.standard,
      ),
      completedAt: map['completedAt'] == null ? null : DateTime.tryParse(map['completedAt'] as String),
    );
  }

  LoggedSet copyWith({
    double? weight,
    int? reps,
    double? rpe,
    String? notes,
    SetType? type,
    DateTime? completedAt,
  }) {
    return LoggedSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class LoggedExercise {
  LoggedExercise({
    required this.exerciseId,
    required this.exerciseName,
    List<LoggedSet>? sets,
    this.restSeconds = 120,
    this.notes,
  }) : sets = sets ?? [];

  final String exerciseId;
  final String exerciseName;
  final List<LoggedSet> sets;
  final int restSeconds;
  final String? notes;

  double get totalVolume => sets.fold(0, (sum, set) => sum + set.volume);
  double get bestE1rm => sets.fold(0, (best, set) => set.estimatedOneRepMax > best ? set.estimatedOneRepMax : best);

  Map<String, Object?> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((set) => set.toMap()).toList(),
      'restSeconds': restSeconds,
      'notes': notes,
    };
  }

  factory LoggedExercise.fromMap(Map<dynamic, dynamic> map) {
    return LoggedExercise(
      exerciseId: map['exerciseId'] as String,
      exerciseName: map['exerciseName'] as String,
      sets: [
        for (final set in (map['sets'] as List? ?? const []))
          LoggedSet.fromMap(set as Map<dynamic, dynamic>),
      ],
      restSeconds: ((map['restSeconds'] as num?) ?? 120).toInt(),
      notes: map['notes'] as String?,
    );
  }
}

class WorkoutSession {
  WorkoutSession({
    required this.id,
    required this.startedAt,
    List<LoggedExercise>? exercises,
    this.completedAt,
    this.name,
  }) : exercises = exercises ?? [];

  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? name;
  final List<LoggedExercise> exercises;

  double get totalVolume => exercises.fold(0, (sum, exercise) => sum + exercise.totalVolume);
  int get totalSets => exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'name': name,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
    };
  }

  factory WorkoutSession.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      completedAt: map['completedAt'] == null ? null : DateTime.tryParse(map['completedAt'] as String),
      name: map['name'] as String?,
      exercises: [
        for (final exercise in (map['exercises'] as List? ?? const []))
          LoggedExercise.fromMap(exercise as Map<dynamic, dynamic>),
      ],
    );
  }
}
