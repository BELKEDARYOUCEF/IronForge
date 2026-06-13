import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_metric_tile.dart';
import '../../../shared/widgets/forge_primary_button.dart';
import '../../../shared/widgets/forge_section_header.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../../onboarding/data/user_profile_repository.dart';
import '../../progress/domain/progress_stats.dart';
import '../data/workout_repository.dart';
import '../domain/workout.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(workoutHistoryProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final sessions = history.valueOrNull ?? const <WorkoutSession>[];
    final stats = ProgressStats(sessions);
    final weekVolume = stats.volumeSince(DateTime.now().subtract(const Duration(days: 7)));

    return ForgeShell(
      title: 'IronForge',
      actions: [
        IconButton(onPressed: () => context.go('/onboarding'), icon: const Icon(Icons.settings_rounded)),
        const SizedBox(width: 6),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Yo, Iron Titan', style: IFText.hero),
                    SizedBox(height: 6),
                    Text("Let's crush today.", style: IFText.bodyMuted),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: IFColors.panel2, borderRadius: BorderRadius.circular(14), border: Border.all(color: IFColors.border)),
                child: const Icon(Icons.notifications_none_rounded, color: IFColors.red),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ForgeCard(
            glow: true,
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: IFColors.orange, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('WORKOUT STREAK', style: IFText.micro),
                      Text('${_streakDays(sessions)} days', style: IFText.h1),
                      const Text('Best: 28 days placeholder', style: IFText.bodyMuted),
                    ],
                  ),
                ),
                const Text('🔥🔥🔥', style: TextStyle(fontSize: 22)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ForgeCard(
            borderColor: IFColors.redDark,
            child: Row(
              children: [
                const Expanded(child: Text('Strength is built one clean rep at a time.', style: IFText.h3)),
                const SizedBox(width: 12),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: IFColors.red.withValues(alpha: 0.16), shape: BoxShape.circle),
                  child: const Icon(Icons.fitness_center_rounded, color: IFColors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ForgePrimaryButton(label: 'START WORKOUT', icon: Icons.play_arrow_rounded, onPressed: () => context.go('/workout')),
          const SizedBox(height: 18),
          const ForgeSectionHeader(title: "Today's Plan"),
          const SizedBox(height: 10),
          ForgeCard(
            onTap: () => context.go('/routines'),
            child: Row(
              children: [
                const Icon(Icons.rocket_launch_rounded, color: IFColors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile?.trainingType ?? 'Push Day', style: IFText.h3),
                      Text(profile == null ? 'Complete setup to personalize your plan' : '${profile.frequencyPerWeek} days/week • ${profile.goal}', style: IFText.bodyMuted),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              ForgeMetricTile(label: 'Volume', value: '${(weekVolume / 1000).toStringAsFixed(1)}t', icon: Icons.scale_rounded),
              ForgeMetricTile(label: 'Workouts', value: '${sessions.length}', icon: Icons.check_circle_rounded),
              ForgeMetricTile(label: 'Sets', value: '${stats.totalSets}', icon: Icons.timer_rounded),
              ForgeMetricTile(label: 'Best Bench', value: '${stats.bestE1rmFor('bench_press').toStringAsFixed(0)} kg', icon: Icons.emoji_events_rounded, iconColor: IFColors.gold),
            ],
          ),
          const SizedBox(height: 18),
          const ForgeSectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.75,
            children: const [
              _QuickAction(label: 'Progress', icon: Icons.bar_chart_rounded, route: '/progress'),
              _QuickAction(label: 'Exercises', icon: Icons.fitness_center_rounded, route: '/exercises'),
              _QuickAction(label: 'Programs', icon: Icons.rocket_launch_rounded, route: '/routines'),
              _QuickAction(label: 'AI Coach', icon: Icons.psychology_alt_rounded, route: '/ai-coach'),
            ],
          ),
        ],
      ),
    );
  }

  int _streakDays(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;
    final days = sessions.map((session) => DateUtils.dateOnly(session.startedAt)).toSet();
    var streak = 0;
    var cursor = DateUtils.dateOnly(DateTime.now());
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon, required this.route});

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      onTap: () => context.go(route),
      child: Row(
        children: [
          Icon(icon, color: IFColors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: IFText.cardTitle)),
          const Icon(Icons.chevron_right_rounded, color: IFColors.textFaint),
        ],
      ),
    );
  }
}
