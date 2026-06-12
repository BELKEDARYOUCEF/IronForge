import 'workout.dart';

class PlateCalculator {
  const PlateCalculator({
    this.barWeight = 20,
    this.availablePlates = const [25, 20, 15, 10, 5, 2.5, 1.25],
  });

  final double barWeight;
  final List<double> availablePlates;

  List<double> platesPerSide(double targetWeight) {
    var remaining = (targetWeight - barWeight) / 2;
    final plates = <double>[];

    for (final plate in availablePlates) {
      while (remaining + 0.001 >= plate) {
        plates.add(plate);
        remaining -= plate;
      }
    }

    return plates;
  }
}

class ProgressiveOverloadEngine {
  const ProgressiveOverloadEngine();

  LoggedSet suggestNextSet(LoggedSet previous, {int targetReps = 8}) {
    if (previous.reps >= targetReps && (previous.rpe ?? 8) <= 8.5) {
      return previous.copyWith(weight: previous.weight + 2.5, reps: targetReps);
    }
    return previous.copyWith(reps: previous.reps + 1);
  }

  bool isPersonalRecord(LoggedSet candidate, Iterable<LoggedSet> history) {
    final best = history.fold<double>(0, (max, set) {
      return set.estimatedOneRepMax > max ? set.estimatedOneRepMax : max;
    });
    return candidate.estimatedOneRepMax > best;
  }
}

