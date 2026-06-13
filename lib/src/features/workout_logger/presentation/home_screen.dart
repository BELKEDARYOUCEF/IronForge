import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_theme.dart';
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

    return ForgeShell(
      title: 'IronForge',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Forge today. Beat last week.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const Text(
            'Offline workout log for strength progress.',
            style: TextStyle(color: forgeSteel, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/workout'),
            child: const Text('START WORKOUT'),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tune, color: forgeElectric),
              title: Text(profile == null ? 'Complete setup' : '${profile.goal} • ${profile.level}'),
              subtitle: Text(profile == null ? 'Goal, level, units, frequency, training type' : '${profile.frequencyPerWeek} days/week • ${profile.units} • ${profile.trainingType}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/onboarding'),
            ),
          ),
          const SizedBox(height: 16),
          _StatGrid(history: history),
          const SizedBox(height: 16),
          const _NavTile(label: 'Progress', route: '/progress'),
          const _NavTile(label: 'Exercise Library', route: '/exercises'),
          const _NavTile(label: 'Routines', route: '/routines'),
          const _NavTile(label: 'Premium', route: '/premium'),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.history});

  final AsyncValue<List<WorkoutSession>> history;

  @override
  Widget build(BuildContext context) {
    final sessions = history.valueOrNull ?? const [];
    final stats = ProgressStats(sessions);
    final weekVolume = stats.volumeSince(DateTime.now().subtract(const Duration(days: 7)));

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: [
        _StatCard(label: 'Workouts', value: '${sessions.length}'),
        _StatCard(label: 'Week Volume', value: '${(weekVolume / 1000).toStringAsFixed(1)}t'),
        _StatCard(label: 'Sets', value: '${stats.totalSets}'),
        _StatCard(label: 'Best Bench', value: '${stats.bestE1rmFor('bench_press').toStringAsFixed(0)} kg'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(color: forgeSteel)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(route),
      ),
    );
  }
}
