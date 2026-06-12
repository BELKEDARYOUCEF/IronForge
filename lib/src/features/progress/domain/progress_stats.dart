import '../../workout_logger/domain/workout.dart';

class ProgressStats {
  const ProgressStats(this.sessions);

  final List<WorkoutSession> sessions;

  double get totalVolume => sessions.fold(0, (sum, session) => sum + session.totalVolume);
  int get totalSets => sessions.fold(0, (sum, session) => sum + session.totalSets);

  double bestE1rmFor(String exerciseId) {
    return sessions
        .expand((session) => session.exercises)
        .where((exercise) => exercise.exerciseId == exerciseId)
        .expand((exercise) => exercise.sets)
        .fold(0, (best, set) => set.estimatedOneRepMax > best ? set.estimatedOneRepMax : best);
  }
}

