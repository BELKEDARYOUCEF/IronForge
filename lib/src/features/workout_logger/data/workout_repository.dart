import '../domain/workout.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutSession>> loadHistory();
  Future<void> saveWorkout(WorkoutSession session);
  Future<LoggedSet?> lastSetForExercise(String exerciseId);
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

