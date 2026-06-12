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
}

