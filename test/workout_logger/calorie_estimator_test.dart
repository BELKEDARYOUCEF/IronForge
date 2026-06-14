import 'package:flutter_test/flutter_test.dart';
import 'package:ironforge/src/features/workout_logger/domain/calorie_estimator.dart';

void main() {
  group('estimateKcal', () {
    test('returns null when bodyWeightKg is zero', () {
      expect(estimateKcal(bodyWeightKg: 0, duration: const Duration(hours: 1)),
          isNull);
    });

    test('returns null when bodyWeightKg is negative', () {
      expect(
          estimateKcal(bodyWeightKg: -10, duration: const Duration(hours: 1)),
          isNull);
    });

    test('computes correctly for 80 kg and 60 min → 400 kcal', () {
      expect(
          estimateKcal(
              bodyWeightKg: 80, duration: const Duration(minutes: 60)),
          400);
    });

    test('computes correctly for 70 kg and 45 min → 263 kcal', () {
      // 5.0 * 70 * 45/60 = 262.5 → rounds to 263
      expect(
          estimateKcal(
              bodyWeightKg: 70, duration: const Duration(minutes: 45)),
          263);
    });

    test('returns 0 for zero duration', () {
      expect(
          estimateKcal(bodyWeightKg: 80, duration: Duration.zero),
          0);
    });
  });
}
