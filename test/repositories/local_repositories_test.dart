import 'package:flutter_test/flutter_test.dart';
import 'package:ironforge/src/features/exercises/data/exercise_repository.dart';
import 'package:ironforge/src/features/exercises/domain/exercise.dart';
import 'package:ironforge/src/features/onboarding/data/user_profile_repository.dart';
import 'package:ironforge/src/features/onboarding/domain/user_profile.dart';
import 'package:ironforge/src/features/routines/data/routine_repository.dart';
import 'package:ironforge/src/features/routines/domain/routine.dart';
import 'package:ironforge/src/features/workout_logger/data/workout_repository.dart';
import 'package:ironforge/src/features/workout_logger/domain/workout.dart';

void main() {
  test('workout repository saves history and returns last set', () async {
    final repository = InMemoryWorkoutRepository();
    final session = WorkoutSession(
      id: 'session-1',
      startedAt: DateTime(2026, 6, 13),
      exercises: [
        LoggedExercise(
          exerciseId: 'bench_press',
          exerciseName: 'Bench Press',
          sets: [const LoggedSet(weight: 100, reps: 8)],
        ),
      ],
    );

    await repository.saveWorkout(session);

    expect(await repository.loadHistory(), [session]);
    expect((await repository.lastSetForExercise('bench_press'))?.weight, 100);
  });

  test('routine repository creates, updates and deletes routines', () async {
    final repository = InMemoryRoutineRepository();
    const routine = Routine(id: 'r1', name: 'Upper Lower', daysPerWeek: 4, progressionStepKg: 2.5);

    await repository.saveRoutine(routine);
    await repository.saveRoutine(const Routine(id: 'r1', name: 'Upper Lower Plus', daysPerWeek: 4, progressionStepKg: 5));

    expect((await repository.loadRoutines()).single.name, 'Upper Lower Plus');

    await repository.deleteRoutine('r1');

    expect(await repository.loadRoutines(), isEmpty);
  });

  test('exercise repository saves custom exercises and toggles favorites', () async {
    final repository = InMemoryExerciseRepository();
    const exercise = Exercise(
      id: 'custom-row',
      name: 'Cable Row Custom',
      primaryMuscle: 'Back',
      equipment: 'Cable',
      isCustom: true,
    );

    await repository.saveExercise(exercise);
    await repository.toggleFavorite(exercise);

    final saved = (await repository.loadExercises()).firstWhere((item) => item.id == 'custom-row');
    expect(saved.isFavorite, isTrue);
    expect(saved.isCustom, isTrue);
  });

  test('user profile repository saves onboarding choices', () async {
    final repository = InMemoryUserProfileRepository();
    const profile = UserProfile(
      goal: 'Strength',
      level: 'Intermediate',
      units: 'kg',
      frequencyPerWeek: 4,
      trainingType: 'Powerbuilding',
    );

    await repository.saveProfile(profile);

    expect((await repository.loadProfile())?.trainingType, 'Powerbuilding');
  });
}
