import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../exercises/domain/exercise.dart';
import '../data/workout_repository.dart';
import '../domain/workout.dart';
import '../domain/workout_math.dart';

final workoutControllerProvider =
    StateNotifierProvider<WorkoutController, WorkoutSession>((ref) {
  return WorkoutController(ref);
});

class WorkoutController extends StateNotifier<WorkoutSession> {
  WorkoutController(this._ref)
      : super(WorkoutSession(id: const Uuid().v4(), startedAt: DateTime.now())) {
    _loadHistory();
  }

  final Ref _ref;
  final _overload = const ProgressiveOverloadEngine();
  List<WorkoutSession> _history = const [];

  WorkoutRepository get _repository => _ref.read(workoutRepositoryProvider);

  Future<void> _loadHistory() async {
    _history = await _repository.loadHistory();
  }

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

  void updateSet(String exerciseId, int setIndex, LoggedSet set) {
    final exercise = state.exercises.firstWhere((item) => item.exerciseId == exerciseId);
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    exercise.sets[setIndex] = set;
    state = WorkoutSession(
      id: state.id,
      startedAt: state.startedAt,
      exercises: [...state.exercises],
      completedAt: state.completedAt,
      name: state.name,
    );
  }

  void deleteSet(String exerciseId, int setIndex) {
    final exercise = state.exercises.firstWhere((item) => item.exerciseId == exerciseId);
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    exercise.sets.removeAt(setIndex);
    state = WorkoutSession(
      id: state.id,
      startedAt: state.startedAt,
      exercises: [...state.exercises],
      completedAt: state.completedAt,
      name: state.name,
    );
  }

  void updateExerciseNotes(String exerciseId, String notes) {
    final exercises = [
      for (final exercise in state.exercises)
        if (exercise.exerciseId == exerciseId)
          LoggedExercise(
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exerciseName,
            sets: [...exercise.sets],
            restSeconds: exercise.restSeconds,
            notes: notes.trim().isEmpty ? null : notes.trim(),
          )
        else
          exercise,
    ];

    state = WorkoutSession(
      id: state.id,
      startedAt: state.startedAt,
      exercises: exercises,
      completedAt: state.completedAt,
      name: state.name,
    );
  }

  Future<void> finishWorkout() async {
    final completed = WorkoutSession(
      id: state.id,
      startedAt: state.startedAt,
      exercises: [...state.exercises],
      completedAt: DateTime.now(),
      name: state.name,
    );

    await _repository.saveWorkout(completed);
    _ref.invalidate(workoutHistoryProvider);
    _history = await _repository.loadHistory();

    state = WorkoutSession(id: const Uuid().v4(), startedAt: DateTime.now());
  }

  /// Last logged set for [exerciseId] from Hive history, or null.
  LoggedSet? lastKnownSet(String exerciseId) => _lastKnownSet(exerciseId);

  bool isPr(String exerciseId, LoggedSet set) {
    final history = _history
        .expand((workout) => workout.exercises)
        .where((exercise) => exercise.exerciseId == exerciseId)
        .expand((exercise) => exercise.sets);
    return _overload.isPersonalRecord(set, history);
  }

  LoggedSet? _lastKnownSet(String exerciseId) {
    for (final workout in _history) {
      for (final exercise in workout.exercises) {
        if (exercise.exerciseId == exerciseId && exercise.sets.isNotEmpty) {
          return exercise.sets.last;
        }
      }
    }
    return null;
  }
}
