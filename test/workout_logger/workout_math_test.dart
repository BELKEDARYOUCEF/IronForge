import 'package:flutter_test/flutter_test.dart';
import 'package:ironforge/src/features/workout_logger/domain/workout.dart';
import 'package:ironforge/src/features/workout_logger/domain/workout_math.dart';

void main() {
  test('plate calculator returns plates per side', () {
    const calculator = PlateCalculator();

    expect(calculator.platesPerSide(100), [25, 15]);
  });

  test('progressive overload increases load after successful target reps', () {
    const engine = ProgressiveOverloadEngine();
    final next = engine.suggestNextSet(
      const LoggedSet(weight: 100, reps: 8, rpe: 8),
      targetReps: 8,
    );

    expect(next.weight, 102.5);
    expect(next.reps, 8);
  });
}
