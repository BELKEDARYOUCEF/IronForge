import 'package:flutter_test/flutter_test.dart';
import 'package:ironforge/src/features/progress/domain/progress_stats.dart';
import 'package:ironforge/src/features/workout_logger/domain/workout.dart';

void main() {
  test('progress stats calculate volume, sets and best e1rm', () {
    final stats = ProgressStats([
      WorkoutSession(
        id: 'w1',
        startedAt: DateTime(2026, 6, 1),
        exercises: [
          LoggedExercise(
            exerciseId: 'bench_press',
            exerciseName: 'Bench Press',
            sets: [
              const LoggedSet(weight: 100, reps: 8),
              const LoggedSet(weight: 105, reps: 5),
            ],
          ),
        ],
      ),
    ]);

    expect(stats.totalSets, 2);
    expect(stats.totalVolume, 1325);
    expect(stats.bestE1rmFor('bench_press'), closeTo(126.6, 0.1));
  });
}
