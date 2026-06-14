import '../../workout_logger/domain/workout.dart';

enum InsightTone { positive, neutral, alert }

class CoachInsight {
  const CoachInsight({
    required this.title,
    required this.body,
    required this.tone,
    this.exerciseRef,
  });

  final String title;
  final String body;
  final InsightTone tone;
  final String? exerciseRef;
}

class CoachEngine {
  const CoachEngine();

  /// Returns up to 3 insights sorted by priority (alert > positive > neutral).
  /// Pass [now] in tests to control the reference date.
  List<CoachInsight> analyze(
    List<WorkoutSession> sessions, {
    int weeklyFrequencyGoal = 3,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final insights = <CoachInsight>[];

    final stagnation = _checkStagnation(sessions);
    if (stagnation != null) insights.add(stagnation);

    final freqDrop = _checkFrequencyDrop(sessions, weeklyFrequencyGoal, ref);
    if (freqDrop != null) insights.add(freqDrop);

    final recentPr = _checkRecentPr(sessions, ref);
    if (recentPr != null) insights.add(recentPr);

    final volumeBoost = _checkVolumeIncrease(sessions, ref);
    if (volumeBoost != null) insights.add(volumeBoost);

    insights.sort((a, b) => _priority(a.tone).compareTo(_priority(b.tone)));

    if (insights.isEmpty) return [_neutralFallback(sessions)];
    return insights.take(3).toList();
  }

  int _priority(InsightTone t) => switch (t) {
        InsightTone.alert => 0,
        InsightTone.positive => 1,
        InsightTone.neutral => 2,
      };

  // ── Rule 1: E1RM stagnation over the last 3 appearances ──────────────────

  CoachInsight? _checkStagnation(List<WorkoutSession> sessions) {
    // exerciseId → chronological list of (date, bestE1rm, name)
    final map = <String, List<_Point>>{};
    for (final s in sessions) {
      for (final ex in s.exercises) {
        if (ex.bestE1rm <= 0) continue;
        (map[ex.exerciseId] ??= [])
            .add(_Point(s.startedAt, ex.bestE1rm, ex.exerciseName));
      }
    }

    for (final entry in map.entries) {
      final pts = entry.value..sort((a, b) => a.date.compareTo(b.date));
      if (pts.length < 3) continue;
      final last3 = pts.sublist(pts.length - 3);
      // Stagnant: newest E1RM not above oldest of the window
      if (last3.last.e1rm <= last3.first.e1rm) {
        final name = last3.last.name;
        return CoachInsight(
          title: 'Stagnation détectée',
          body:
              '$name stagne depuis 3 séances. Tente un deload de 10 % ou varie les reps.',
          tone: InsightTone.alert,
          exerciseRef: entry.key,
        );
      }
    }
    return null;
  }

  // ── Rule 2: Weekly volume up >= 10% vs previous week ─────────────────────

  CoachInsight? _checkVolumeIncrease(
      List<WorkoutSession> sessions, DateTime now) {
    final thisStart = _weekStart(now);
    final lastStart = thisStart.subtract(const Duration(days: 7));

    double thisVol = 0;
    double lastVol = 0;
    for (final s in sessions) {
      if (!s.startedAt.isBefore(thisStart)) {
        thisVol += s.totalVolume;
      } else if (!s.startedAt.isBefore(lastStart)) {
        lastVol += s.totalVolume;
      }
    }

    if (lastVol <= 0 || thisVol <= 0) return null;
    final increase = (thisVol - lastVol) / lastVol;
    if (increase < 0.10) return null;

    final pct = (increase * 100).round();
    return CoachInsight(
      title: 'Volume en hausse',
      body:
          'Ton volume global a grimpé de +$pct % par rapport à la semaine dernière. '
          'Solide surcharge — garde le RPE < 9.',
      tone: InsightTone.positive,
    );
  }

  // ── Rule 3: All-time PR achieved within the last 7 days ──────────────────

  CoachInsight? _checkRecentPr(
      List<WorkoutSession> sessions, DateTime now) {
    final cutoff = now.subtract(const Duration(days: 7));

    // Build all-time best e1rm per exercise
    final allTime = <String, _Point>{};
    for (final s in sessions) {
      for (final ex in s.exercises) {
        final b = ex.bestE1rm;
        if (b <= 0) continue;
        final prev = allTime[ex.exerciseId];
        if (prev == null || b > prev.e1rm) {
          allTime[ex.exerciseId] = _Point(s.startedAt, b, ex.exerciseName);
        }
      }
    }

    // Check if any all-time best was set in the last 7 days
    for (final pt in allTime.values) {
      if (!pt.date.isBefore(cutoff)) {
        final val = pt.e1rm.toStringAsFixed(1);
        return CoachInsight(
          title: 'Nouveau PR !',
          body: 'Nouveau PR sur ${pt.name} : $val kg e1RM. '
              'Capitalise, ne brûle pas les étapes.',
          tone: InsightTone.positive,
          exerciseRef:
              allTime.entries.firstWhere((e) => e.value == pt).key,
        );
      }
    }
    return null;
  }

  // ── Rule 4: Session frequency below goal (fires from day 3 of the week) ──

  CoachInsight? _checkFrequencyDrop(
      List<WorkoutSession> sessions, int goal, DateTime now) {
    if (goal <= 0) return null;
    final weekStart = _weekStart(now);
    final daysIn = now.difference(weekStart).inDays;
    if (daysIn < 3) return null; // Too early in the week to fire

    final done =
        sessions.where((s) => !s.startedAt.isBefore(weekStart)).length;
    if (done >= goal) return null;

    final remaining = goal - done;
    return CoachInsight(
      title: 'Fréquence en retard',
      body: 'Tu es à $done/$goal séances cette semaine. '
          '$remaining séance${remaining > 1 ? "s" : ""} pour tenir le cap.',
      tone: InsightTone.alert,
    );
  }

  // ── Neutral fallback ──────────────────────────────────────────────────────

  CoachInsight _neutralFallback(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return const CoachInsight(
        title: 'Prêt à forger ?',
        body: 'Lance ta première séance et commence à construire ton legacy.',
        tone: InsightTone.neutral,
      );
    }
    final last = sessions.reduce(
        (a, b) => a.startedAt.isAfter(b.startedAt) ? a : b);
    final name = last.name ?? 'ta dernière séance';
    return CoachInsight(
      title: 'Continue sur ta lancée',
      body: 'Bonne séance lors de "$name". Reste régulier, les résultats suivront.',
      tone: InsightTone.neutral,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DateTime _weekStart(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1)); // Monday
  }
}

class _Point {
  const _Point(this.date, this.e1rm, this.name);
  final DateTime date;
  final double e1rm;
  final String name;
}
