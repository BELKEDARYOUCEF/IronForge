import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../domain/workout.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  if (Hive.isBoxOpen(HiveWorkoutRepository.boxName)) {
    return HiveWorkoutRepository(Hive.box(HiveWorkoutRepository.boxName));
  }

  return InMemoryWorkoutRepository();
});

final workoutHistoryProvider = FutureProvider<List<WorkoutSession>>((ref) {
  return ref.watch(workoutRepositoryProvider).loadHistory();
});

abstract class WorkoutRepository {
  Future<List<WorkoutSession>> loadHistory();
  Future<void> saveWorkout(WorkoutSession session);
  Future<LoggedSet?> lastSetForExercise(String exerciseId);
}

class HiveWorkoutRepository implements WorkoutRepository {
  HiveWorkoutRepository(this._box);

  static const boxName = 'workout_sessions';

  final Box<dynamic> _box;

  @override
  Future<List<WorkoutSession>> loadHistory() async {
    final sessions = _box.values
        .whereType<Map<dynamic, dynamic>>()
        .map(WorkoutSession.fromMap)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return List.unmodifiable(sessions);
  }

  @override
  Future<void> saveWorkout(WorkoutSession session) {
    return _box.put(session.id, session.toMap());
  }

  @override
  Future<LoggedSet?> lastSetForExercise(String exerciseId) async {
    final history = await loadHistory();
    for (final session in history) {
      for (final exercise in session.exercises.reversed) {
        if (exercise.exerciseId == exerciseId && exercise.sets.isNotEmpty) {
          return exercise.sets.last;
        }
      }
    }
    return null;
  }
}

class InMemoryWorkoutRepository implements WorkoutRepository {
  InMemoryWorkoutRepository([List<WorkoutSession>? seed]) : _sessions = seed ?? [];

  final List<WorkoutSession> _sessions;

  @override
  Future<List<WorkoutSession>> loadHistory() async {
    return List.unmodifiable(_sessions);
  }

  @override
  Future<void> saveWorkout(WorkoutSession session) async {
    final index = _sessions.indexWhere((item) => item.id == session.id);
    if (index == -1) {
      _sessions.add(session);
    } else {
      _sessions[index] = session;
    }
  }

  @override
  Future<LoggedSet?> lastSetForExercise(String exerciseId) async {
    for (final session in _sessions.reversed) {
      for (final exercise in session.exercises.reversed) {
        if (exercise.exerciseId == exerciseId && exercise.sets.isNotEmpty) {
          return exercise.sets.last;
        }
      }
    }
    return null;
  }
}
