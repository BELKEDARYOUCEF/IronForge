import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_spacing.dart';
import '../../../core/if_text_styles.dart';
import '../domain/calorie_estimator.dart';
import '../../../shared/widgets/forge_action_tile.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_primary_button.dart';
import '../../../shared/widgets/forge_section_header.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../../onboarding/data/user_profile_repository.dart';
import '../../progress/domain/progress_stats.dart';
import '../../routines/data/routine_repository.dart';
import '../../routines/domain/routine.dart';
import '../data/workout_repository.dart';
import '../domain/workout.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(workoutHistoryProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final routines =
        ref.watch(routinesProvider).valueOrNull ?? const <Routine>[];
    final sessions = history.valueOrNull ?? const <WorkoutSession>[];
    final stats = ProgressStats(sessions);
    final weekVolume =
        stats.volumeSince(DateTime.now().subtract(const Duration(days: 7)));
    final streak = _streakDays(sessions);
    final bestStreak = _bestStreakDays(sessions);
    final primaryRoutine = routines.isNotEmpty ? routines.first : null;
    final benchE1rm = stats.bestE1rmFor('bench_press');
    final estimatedDuration = _avgSessionDuration(sessions);

    return ForgeShell(
      title: 'IronForge',
      actions: [
        IconButton(
            onPressed: () => context.go('/onboarding'),
            icon: const Icon(Icons.settings_rounded)),
        const SizedBox(width: 6),
      ],
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          _HomeHeader(onSettingsTap: () => context.go('/onboarding')),
          const SizedBox(height: IFSpacing.spacingBlock),

          // ── Streak + PR côte à côte ──────────────────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: _StreakCard(
                        streak: streak, bestStreak: bestStreak)),
                const SizedBox(width: 10),
                Expanded(child: _PrCard(benchE1rm: benchE1rm)),
              ],
            ),
          ),
          const SizedBox(height: IFSpacing.spacingBlock),

          // ── Quote compacte ───────────────────────────────────────
          const _QuoteCard(),
          const SizedBox(height: IFSpacing.spacingBlock),

          // ── CTA ──────────────────────────────────────────────────
          ForgePrimaryButton(
              label: 'START WORKOUT',
              icon: Icons.play_arrow_rounded,
              onPressed: () => context.go('/workout')),
          const SizedBox(height: IFSpacing.spacingBlock),

          // ── Today's Plan ─────────────────────────────────────────
          ForgeSectionHeader(
            title: "Today's Plan",
            action: primaryRoutine == null ? 'Programs' : 'Open',
            onActionTap: () => context.go('/routines'),
          ),
          const SizedBox(height: 10),
          _TodaysPlanCard(
            profileTrainingType: profile?.trainingType,
            profileGoal: profile?.goal,
            profileFrequency: profile?.frequencyPerWeek,
            routine: primaryRoutine,
            bodyWeightKg: profile?.bodyWeightKg,
            estimatedDuration: estimatedDuration,
            onTap: () => context.go('/routines'),
          ),
          const SizedBox(height: IFSpacing.spacingBlock),

          // ── Métriques : rangée de 4 tuiles compactes ─────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _MiniMetric(
                    label: 'Volume',
                    value: '${(weekVolume / 1000).toStringAsFixed(1)}t',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniMetric(
                    label: 'Workouts',
                    value: '${sessions.length}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniMetric(
                    label: 'Sets',
                    value: '${stats.totalSets}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniMetric(
                    label: 'Bench',
                    value: benchE1rm > 0
                        ? '${benchE1rm.toStringAsFixed(0)}kg'
                        : '—',
                    valueColor: IFColors.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: IFSpacing.spacingBlock),

          // ── Quick Actions ────────────────────────────────────────
          const ForgeSectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.85,
            children: [
              ForgeActionTile(
                  label: 'Progress',
                  subtitle: 'Strength curve',
                  icon: Icons.bar_chart_rounded,
                  onTap: () => context.go('/progress')),
              ForgeActionTile(
                  label: 'Exercises',
                  subtitle: 'Library',
                  icon: Icons.fitness_center_rounded,
                  onTap: () => context.go('/exercises')),
              ForgeActionTile(
                  label: 'Programs',
                  subtitle: 'Routines',
                  icon: Icons.rocket_launch_rounded,
                  onTap: () => context.go('/routines')),
              ForgeActionTile(
                  label: 'AI Coach',
                  subtitle: 'Insights',
                  icon: Icons.psychology_alt_rounded,
                  color: IFColors.blue,
                  onTap: () => context.go('/ai-coach')),
            ],
          ),
        ],
      ),
    );
  }

  /// Average duration of completed sessions; falls back to 60 min if none.
  Duration _avgSessionDuration(List<WorkoutSession> sessions) {
    final completed = sessions
        .where((s) => s.completedAt != null)
        .map((s) => s.completedAt!.difference(s.startedAt).inMinutes)
        .where((m) => m > 0)
        .toList();
    if (completed.isEmpty) return const Duration(minutes: 60);
    final avg = completed.reduce((a, b) => a + b) ~/ completed.length;
    return Duration(minutes: avg);
  }

  int _streakDays(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;
    final days = sessions
        .map((session) => DateUtils.dateOnly(session.startedAt))
        .toSet();
    var streak = 0;
    var cursor = DateUtils.dateOnly(DateTime.now());
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _bestStreakDays(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;
    final orderedDays = sessions
        .map((session) => DateUtils.dateOnly(session.startedAt))
        .toSet()
        .toList()
      ..sort();
    var best = 0;
    var current = 0;
    DateTime? previous;

    for (final day in orderedDays) {
      if (previous == null || day.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      if (current > best) best = current;
      previous = day;
    }

    return best;
  }
}

// ── _HomeHeader ──────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yo, Iron Titan', style: IFText.hero),
              SizedBox(height: 4),
              Text("Let's crush today.", style: IFText.bodyMuted),
            ],
          ),
        ),
        ForgeCard(
          padding: EdgeInsets.zero,
          onTap: onSettingsTap,
          child: const SizedBox(
            width: 46,
            height: 46,
            child: Icon(Icons.settings_rounded, color: IFColors.red),
          ),
        ),
      ],
    );
  }
}

// ── _StreakCard ──────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak, required this.bestStreak});

  final int streak;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      glow: streak > 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.local_fire_department_rounded,
                color: IFColors.orange, size: 15),
            SizedBox(width: 5),
            Text('STREAK', style: IFText.micro),
          ]),
          const SizedBox(height: 8),
          Text(
            '$streak',
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: IFColors.text,
                height: 1.0),
          ),
          const Text('days', style: IFText.bodyMuted),
          const SizedBox(height: 6),
          Text(
            bestStreak == 0 ? 'Best: —' : 'Best: ${bestStreak}d',
            style: IFText.micro,
          ),
        ],
      ),
    );
  }
}

// ── _PrCard ──────────────────────────────────────────────────────────────────

class _PrCard extends StatelessWidget {
  const _PrCard({required this.benchE1rm});

  final double benchE1rm;

  @override
  Widget build(BuildContext context) {
    final hasData = benchE1rm > 0;
    final value = hasData ? '${benchE1rm.toStringAsFixed(0)}kg' : '—';

    return ForgeCard(
      borderColor:
          hasData ? IFColors.gold.withValues(alpha: 0.40) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.emoji_events_rounded,
                color: hasData ? IFColors.gold : IFColors.textFaint,
                size: 15),
            const SizedBox(width: 5),
            const Text('BENCH PR', style: IFText.micro),
          ]),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: hasData ? IFColors.gold : IFColors.textFaint,
                height: 1.0),
          ),
          const Text('e1RM', style: IFText.bodyMuted),
          const SizedBox(height: 6),
          const Text('est. Epley', style: IFText.micro),
        ],
      ),
    );
  }
}

// ── _MiniMetric ──────────────────────────────────────────────────────────────

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: valueColor ?? IFColors.text,
                  height: 1.0),
            ),
          ),
          const SizedBox(height: 3),
          Text(label.toUpperCase(), style: IFText.micro),
        ],
      ),
    );
  }
}

// ── _QuoteCard ───────────────────────────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      borderColor: IFColors.redDark,
      backgroundColor: IFColors.panel2,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Discipline is choosing between what you want now and what you want most.',
              style: IFText.h3,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: IFColors.red.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: IFColors.red.withValues(alpha: 0.28)),
            ),
            child: const Icon(Icons.fitness_center_rounded,
                color: IFColors.red, size: 22),
          ),
        ],
      ),
    );
  }
}

// ── _TodaysPlanCard ──────────────────────────────────────────────────────────

class _TodaysPlanCard extends StatelessWidget {
  const _TodaysPlanCard({
    required this.profileTrainingType,
    required this.profileGoal,
    required this.profileFrequency,
    required this.routine,
    required this.bodyWeightKg,
    required this.estimatedDuration,
    required this.onTap,
  });

  final String? profileTrainingType;
  final String? profileGoal;
  final int? profileFrequency;
  final Routine? routine;
  final double? bodyWeightKg;
  final Duration estimatedDuration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = routine?.name ?? profileTrainingType ?? 'Push Day';
    final frequency = routine?.daysPerWeek ?? profileFrequency;
    final subtitle = routine == null
        ? (profileGoal == null
            ? 'Build your first program'
            : '$frequency days/week • $profileGoal')
        : '$frequency days/week • ${routine!.progressionLabel}';
    final badge = routine == null ? 'SUGGESTED' : 'ACTIVE';
    final footer = routine == null
        ? 'Offline program • Set your routine'
        : 'Offline program • Progression ready';

    // Calories via MET estimator — null if no weight in profile
    final kcal = bodyWeightKg != null
        ? estimateKcal(
            bodyWeightKg: bodyWeightKg!, duration: estimatedDuration)
        : null;
    final calorieLabel =
        kcal != null ? '$kcal kcal est.' : '— kcal est.';

    return ForgeCard(
      onTap: onTap,
      selected: routine != null,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [IFColors.red, IFColors.redDark],
              ),
              borderRadius: BorderRadius.circular(IFSpacing.radiusInput),
            ),
            child:
                const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: IFText.h3)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: IFColors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: IFColors.red.withValues(alpha: 0.25)),
                      ),
                      child: Text(badge,
                          style: const TextStyle(
                              color: IFColors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: IFText.bodyMuted),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: Text(footer, style: IFText.micro)),
                    const Icon(Icons.local_fire_department_rounded,
                        size: 11, color: IFColors.orange),
                    const SizedBox(width: 3),
                    Text(calorieLabel, style: IFText.micro),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: IFColors.textFaint),
        ],
      ),
    );
  }
}
