import '../features/exercises/domain/exercise.dart';
import '../features/workout_logger/domain/workout.dart';

final sampleExercises = <Exercise>[
  const Exercise(
    id: 'bench_press',
    name: 'Barbell Bench Press',
    primaryMuscle: 'Chest',
    equipment: 'Barbell',
    isFavorite: true,
  ),
  const Exercise(
    id: 'squat',
    name: 'Back Squat',
    primaryMuscle: 'Quads',
    equipment: 'Barbell',
    isFavorite: true,
  ),
  const Exercise(
    id: 'deadlift',
    name: 'Deadlift',
    primaryMuscle: 'Posterior Chain',
    equipment: 'Barbell',
    isFavorite: true,
  ),
  const Exercise(
    id: 'pull_up',
    name: 'Pull-Up',
    primaryMuscle: 'Back',
    equipment: 'Bodyweight',
  ),
  const Exercise(
    id: 'lateral_raise',
    name: 'Dumbbell Lateral Raise',
    primaryMuscle: 'Shoulders',
    equipment: 'Dumbbell',
  ),
];

final sampleHistory = <WorkoutSession>[
  WorkoutSession(
    id: 'w1',
    startedAt: DateTime.now().subtract(const Duration(days: 7)),
    completedAt: DateTime.now().subtract(const Duration(days: 7, hours: -1)),
    exercises: [
      LoggedExercise(
        exerciseId: 'bench_press',
        exerciseName: 'Barbell Bench Press',
        sets: [
          const LoggedSet(weight: 100, reps: 8, rpe: 8),
          const LoggedSet(weight: 100, reps: 8, rpe: 8.5),
          const LoggedSet(weight: 100, reps: 7, rpe: 9),
        ],
      ),
    ],
  ),
];

