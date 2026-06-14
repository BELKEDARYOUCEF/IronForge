import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_action_tile.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_metric_tile.dart';
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

    return ForgeShell(
      title: 'IronForge',
      actions: [
        IconButton(
            onPressed: () => context.go('/onboarding'),
            icon: const Icon(Icons.settings_rounded)),
        const SizedBox(width: 6),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HomeHeader(onSettingsTap: () => context.go('/onboarding')),
          const SizedBox(height: 14),
          _StreakHero(streak: streak, bestStreak: bestStreak),
          const SizedBox(height: 12),
          const _QuoteCard(),
          const SizedBox(height: 14),
          ForgePrimaryButton(
              label: 'START WORKOUT',
              icon: Icons.play_arrow_rounded,
              onPressed: () => context.go('/workout')),
          const SizedBox(height: 16),
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
            onTap: () => context.go('/routines'),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              ForgeMetricTile(
                  label: 'Volume',
                  value: '${(weekVolume / 1000).toStringAsFixed(1)}t',
                  icon: Icons.scale_rounded),
              ForgeMetricTile(
                  label: 'Workouts',
                  value: '${sessions.length}',
                  icon: Icons.check_circle_rounded),
              ForgeMetricTile(
                  label: 'Sets',
                  value: '${stats.totalSets}',
                  icon: Icons.timer_rounded),
              ForgeMetricTile(
                  label: 'Best Bench',
                  value:
                      '${stats.bestE1rmFor('bench_press').toStringAsFixed(0)} kg',
                  icon: Icons.emoji_events_rounded,
                  iconColor: IFColors.gold),
            ],
          ),
          const SizedBox(height: 16),
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
              SizedBox(height: 5),
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

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.streak, required this.bestStreak});

  final int streak;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    final fireCount = streak.clamp(0, 5);

    return ForgeCard(
      glow: true,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: IFColors.orange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: IFColors.orange.withValues(alpha: 0.28)),
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: IFColors.orange, size: 31),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WORKOUT STREAK', style: IFText.micro),
                const SizedBox(height: 4),
                Text('$streak days', style: IFText.h1),
                const SizedBox(height: 3),
                Text(bestStreak == 0 ? 'Best: -' : 'Best: $bestStreak days',
                    style: IFText.bodyMuted),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fireCount == 0 ? '-' : List.filled(fireCount, '🔥').join(),
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 6),
              const Text('LOCAL', style: IFText.micro),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      borderColor: IFColors.redDark,
      backgroundColor: IFColors.panel2,
      padding: const EdgeInsets.all(14),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: IFColors.red.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: IFColors.red.withValues(alpha: 0.28)),
            ),
            child: const Icon(Icons.fitness_center_rounded,
                color: IFColors.red, size: 26),
          ),
        ],
      ),
    );
  }
}

class _TodaysPlanCard extends StatelessWidget {
  const _TodaysPlanCard({
    required this.profileTrainingType,
    required this.profileGoal,
    required this.profileFrequency,
    required this.routine,
    required this.onTap,
  });

  final String? profileTrainingType;
  final String? profileGoal;
  final int? profileFrequency;
  final Routine? routine;
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
        ? '5 Exercises • PPL'
        : 'Offline program • Progression ready';

    return ForgeCard(
      onTap: onTap,
      selected: routine != null,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [IFColors.red, IFColors.redDark],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
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
                          horizontal: 8, vertical: 4),
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
                const SizedBox(height: 5),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: IFText.bodyMuted),
                const SizedBox(height: 5),
                Text(footer, style: IFText.micro),
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
