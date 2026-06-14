import 'package:flutter_test/flutter_test.dart';
import 'package:ironforge/src/features/ai_coach/domain/coach_engine.dart';
import 'package:ironforge/src/features/workout_logger/domain/workout.dart';

// ── Helpers ─────────────────────────────────────────────────────────────────

WorkoutSession _session({
  required String id,
  required DateTime date,
  String? name,
  List<LoggedExercise> exercises = const [],
}) =>
    WorkoutSession(
      id: id,
      startedAt: date,
      name: name,
      exercises: exercises,
    );

LoggedExercise _exercise(String id, String name, double weight, int reps) =>
    LoggedExercise(
      exerciseId: id,
      exerciseName: name,
      sets: [LoggedSet(weight: weight, reps: reps)],
    );

// Reference "today" for all tests
final _today = DateTime(2026, 6, 12); // Thursday

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  const engine = CoachEngine();

  group('neutral fallback', () {
    test('returns neutral insight when sessions list is empty', () {
      // goal=0 disables frequency rule so the fallback is truly reached
      final insights =
          engine.analyze([], now: _today, weeklyFrequencyGoal: 0);
      expect(insights.length, 1);
      expect(insights.first.tone, InsightTone.neutral);
    });

    test('returns encouraging insight when no rule matches', () {
      // 2 old sessions (> 7 days ago, different weeks) — not enough for
      // stagnation, no recent PR, no cross-week volume data, early in week
      final sessions = [
        _session(
          id: '1',
          date: DateTime(2026, 5, 1),
          exercises: [_exercise('bench', 'Bench Press', 80, 8)],
        ),
        _session(
          id: '2',
          date: DateTime(2026, 5, 8), // best is old (> 7 days)
          exercises: [_exercise('bench', 'Bench Press', 82.5, 8)],
        ),
      ];
      final insights = engine.analyze(
        sessions,
        now: DateTime(2026, 6, 9), // Monday — too early for freq rule
        weeklyFrequencyGoal: 3,
      );
      expect(insights.length, 1);
      expect(insights.first.tone, InsightTone.neutral);
    });
  });

  group('Rule 1 — stagnation', () {
    test('fires alert when E1RM flat across 3 sessions', () {
      final sessions = [
        _session(
          id: '1',
          date: DateTime(2026, 5, 20),
          exercises: [_exercise('squat', 'Squat', 100, 5)],
        ),
        _session(
          id: '2',
          date: DateTime(2026, 5, 27),
          exercises: [_exercise('squat', 'Squat', 100, 5)],
        ),
        _session(
          id: '3',
          date: DateTime(2026, 6, 3),
          exercises: [_exercise('squat', 'Squat', 100, 5)],
        ),
      ];
      final insights = engine.analyze(sessions, now: _today);
      expect(insights.any((i) => i.tone == InsightTone.alert), isTrue);
      expect(
        insights.any((i) => i.title == 'Stagnation détectée'),
        isTrue,
      );
    });

    test('does not fire when E1RM is increasing', () {
      final sessions = [
        _session(
          id: '1',
          date: DateTime(2026, 5, 20),
          exercises: [_exercise('squat', 'Squat', 100, 5)],
        ),
        _session(
          id: '2',
          date: DateTime(2026, 5, 27),
          exercises: [_exercise('squat', 'Squat', 105, 5)],
        ),
        _session(
          id: '3',
          date: DateTime(2026, 6, 3),
          exercises: [_exercise('squat', 'Squat', 110, 5)],
        ),
      ];
      final insights = engine.analyze(sessions, now: _today);
      expect(
        insights.any((i) => i.title == 'Stagnation détectée'),
        isFalse,
      );
    });

    test('does not fire with fewer than 3 sessions for an exercise', () {
      final sessions = [
        _session(
          id: '1',
          date: DateTime(2026, 6, 1),
          exercises: [_exercise('bench', 'Bench Press', 80, 8)],
        ),
        _session(
          id: '2',
          date: DateTime(2026, 6, 8),
          exercises: [_exercise('bench', 'Bench Press', 80, 8)],
        ),
      ];
      final insights = engine.analyze(
        sessions,
        now: DateTime(2026, 6, 8),
        weeklyFrequencyGoal: 0,
      );
      expect(
        insights.any((i) => i.title == 'Stagnation détectée'),
        isFalse,
      );
    });
  });

  group('Rule 2 — volume increase', () {
    test('fires positive when this week > last week by >= 10 %', () {
      // Last week: Mon Jun 2 – 10 000 kg
      // This week: Mon Jun 9 – 11 000 kg (+10%)
      final sessions = [
        _session(
          id: 'lw',
          date: DateTime(2026, 6, 2),
          exercises: [_exercise('dl', 'Deadlift', 100, 10)], // 1 000 kg vol
        ),
        _session(
          id: 'tw',
          date: DateTime(2026, 6, 9),
          exercises: [_exercise('dl', 'Deadlift', 110, 10)], // 1 100 kg vol
        ),
      ];
      final insights = engine.analyze(sessions, now: _today);
      expect(
        insights.any((i) => i.title == 'Volume en hausse'),
        isTrue,
      );
    });

    test('does not fire when increase is below 10 %', () {
      final sessions = [
        _session(
          id: 'lw',
          date: DateTime(2026, 6, 2),
          exercises: [_exercise('dl', 'Deadlift', 100, 10)],
        ),
        _session(
          id: 'tw',
          date: DateTime(2026, 6, 9),
          exercises: [_exercise('dl', 'Deadlift', 105, 10)], // +5%
        ),
      ];
      final insights = engine.analyze(sessions, now: _today);
      expect(
        insights.any((i) => i.title == 'Volume en hausse'),
        isFalse,
      );
    });
  });

  group('Rule 3 — recent PR', () {
    test('fires positive when all-time best was set within 7 days', () {
      final sessions = [
        _session(
          id: 'old',
          date: DateTime(2026, 5, 1),
          exercises: [_exercise('bench', 'Bench Press', 80, 5)],
        ),
        _session(
          id: 'new',
          date: DateTime(2026, 6, 10), // 2 days ago
          exercises: [_exercise('bench', 'Bench Press', 90, 5)], // new best
        ),
      ];
      final insights = engine.analyze(sessions, now: _today);
      expect(
        insights.any((i) => i.title == 'Nouveau PR !'),
        isTrue,
      );
    });

    test('does not fire when best was set more than 7 days ago', () {
      final sessions = [
        _session(
          id: 'old',
          date: DateTime(2026, 5, 1),
          exercises: [_exercise('bench', 'Bench Press', 90, 5)], // best, old
        ),
        _session(
          id: 'new',
          date: DateTime(2026, 6, 10),
          exercises: [_exercise('bench', 'Bench Press', 80, 5)],
        ),
      ];
      final insights = engine.analyze(
        sessions,
        now: _today,
        weeklyFrequencyGoal: 0,
      );
      expect(
        insights.any((i) => i.title == 'Nouveau PR !'),
        isFalse,
      );
    });
  });

  group('Rule 4 — frequency drop', () {
    test('fires alert on Thursday with 0 sessions vs goal of 3', () {
      // _today is Thursday (day 3 of week, index 0-based) — daysIn == 3
      final insights = engine.analyze(
        [],
        now: _today,
        weeklyFrequencyGoal: 3,
      );
      expect(
        insights.any((i) => i.title == 'Fréquence en retard'),
        isTrue,
      );
    });

    test('does not fire when goal is met', () {
      final thisWeek = [
        _session(id: 'a', date: DateTime(2026, 6, 9)),
        _session(id: 'b', date: DateTime(2026, 6, 10)),
        _session(id: 'c', date: DateTime(2026, 6, 11)),
      ];
      final insights = engine.analyze(
        thisWeek,
        now: _today,
        weeklyFrequencyGoal: 3,
      );
      expect(
        insights.any((i) => i.title == 'Fréquence en retard'),
        isFalse,
      );
    });

    test('does not fire early in the week (Monday / Tuesday)', () {
      final insights = engine.analyze(
        [],
        now: DateTime(2026, 6, 9), // Monday
        weeklyFrequencyGoal: 3,
      );
      expect(
        insights.any((i) => i.title == 'Fréquence en retard'),
        isFalse,
      );
    });
  });

  group('priority ordering', () {
    test('alert comes before positive', () {
      // Stagnation (alert) + PR (positive) both fire
      final sessions = [
        _session(
          id: '1',
          date: DateTime(2026, 5, 20),
          exercises: [_exercise('squat', 'Squat', 100, 5)],
        ),
        _session(
          id: '2',
          date: DateTime(2026, 5, 27),
          exercises: [_exercise('squat', 'Squat', 100, 5)],
        ),
        _session(
          id: '3',
          date: DateTime(2026, 6, 3),
          exercises: [
            _exercise('squat', 'Squat', 100, 5),
            _exercise('bench', 'Bench Press', 100, 5), // new PR for bench
          ],
        ),
        _session(
          id: '4',
          date: DateTime(2026, 6, 10),
          exercises: [
            _exercise('bench', 'Bench Press', 110, 5), // fresh all-time best
          ],
        ),
      ];
      final insights = engine.analyze(
        sessions,
        now: DateTime(2026, 6, 10), // Tuesday — freq rule won't fire
        weeklyFrequencyGoal: 0,
      );
      expect(insights.first.tone, InsightTone.alert);
    });

    test('returns at most 3 insights', () {
      // Trigger all 4 rules simultaneously
      final sessions = [
        // Stagnation: 3 sessions flat
        _session(
          id: 's1',
          date: DateTime(2026, 5, 15),
          exercises: [_exercise('squat', 'Squat', 100, 5)],
        ),
        _session(
          id: 's2',
          date: DateTime(2026, 5, 22),
          exercises: [_exercise('squat', 'Squat', 100, 5)],
        ),
        _session(
          id: 's3',
          date: DateTime(2026, 5, 29),
          exercises: [_exercise('squat', 'Squat', 100, 5)],
        ),
        // Last week volume
        _session(
          id: 'lw',
          date: DateTime(2026, 6, 2),
          exercises: [_exercise('dl', 'Deadlift', 100, 10)],
        ),
        // This week: recent PR + higher volume
        _session(
          id: 'tw',
          date: DateTime(2026, 6, 9),
          exercises: [
            _exercise('dl', 'Deadlift', 120, 10), // +20% volume & PR
          ],
        ),
      ];
      // Thursday → freq rule fires (0 sessions this week after Monday)
      // Actually session tw is Monday Jun 9, so done=1 < goal=3 → fires
      final insights = engine.analyze(
        sessions,
        now: _today,
        weeklyFrequencyGoal: 3,
      );
      expect(insights.length, lessThanOrEqualTo(3));
    });
  });
}
