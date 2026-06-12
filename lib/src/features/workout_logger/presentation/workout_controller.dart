import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/sample_data.dart';
import '../../exercises/domain/exercise.dart';
import '../domain/workout.dart';
import '../domain/workout_math.dart';

final workoutControllerProvider =
    StateNotifierProvider<WorkoutController, WorkoutSession>((ref) {
  return WorkoutController();
});

class WorkoutController extends StateNotifier<WorkoutSession> {
  WorkoutController()
      : super(WorkoutSession(id: const Uuid().v4(), startedAt: DateTime.now()));

  final _overload = const ProgressiveOverloadEngine();

  void addExercise(Exercise exercise) {
    if (state.exercises.any((item) => item.exerciseId == exercise.id)) return;
    state.exercises.add(
      LoggedExercise(exerciseId: exercise.id, exerciseName: exercise.name),
    );
    state = WorkoutSession(
      id: state.id,
      startedAt: state.startedAt,
      exercises: [...state.exercises],
      completedAt: state.completedAt,
      name: state.name,
    );
  }

  void addSameAsLastSet(String exerciseId) {
    final last = _lastKnownSet(exerciseId) ?? const LoggedSet(weight: 20, reps: 8, rpe: 7);
    addSet(exerciseId, last);
  }

  void addSmartSet(String exerciseId) {
    final last = _lastKnownSet(exerciseId) ?? const LoggedSet(weight: 20, reps: 8, rpe: 7);
    addSet(exerciseId, _overload.suggestNextSet(last));
  }

  void addSet(String exerciseId, LoggedSet set) {
    final exercise = state.exercises.firstWhere((item) => item.exerciseId == exerciseId);
    exercise.sets.add(set.copyWith(completedAt: DateTime.now()));
    state = WorkoutSession(
      id: state.id,
      startedAt: state.startedAt,
      exercises: [...state.exercises],
      completedAt: state.completedAt,
      name: state.name,
    );
  }

  bool isPr(String exerciseId, LoggedSet set) {
    final history = sampleHistory
        .expand((workout) => workout.exercises)
        .where((exercise) => exercise.exerciseId == exerciseId)
        .expand((exercise) => exercise.sets);
    return _overload.isPersonalRecord(set, history);
  }

  LoggedSet? _lastKnownSet(String exerciseId) {
    for (final workout in sampleHistory) {
      for (final exercise in workout.exercises) {
        if (exercise.exerciseId == exerciseId && exercise.sets.isNotEmpty) {
          return exercise.sets.last;
        }
      }
    }
    return null;
  }
}

