import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_metric_tile.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../../workout_logger/data/workout_repository.dart';
import '../../workout_logger/domain/workout.dart';
import '../domain/progress_stats.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String range = 'ALL';

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(workoutHistoryProvider);
    final sessions = _sessionsForRange(history.valueOrNull ?? const []);
    final stats = ProgressStats(sessions);

    return ForgeShell(
      title: 'Progress Overview',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (history.isLoading) const LinearProgressIndicator(),
          Wrap(
            spacing: 8,
            children: [
              for (final item in const ['7D', '4W', '3M', '1Y', 'ALL'])
                ForgeChip(label: item, selected: range == item, onTap: () => setState(() => range = item)),
            ],
          ),
          const SizedBox(height: 16),
          ForgeCard(
            glow: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BENCH PRESS', style: IFText.micro),
                const SizedBox(height: 8),
                const Text('1RM Estimate', style: IFText.bodyMuted),
                Text('${stats.bestE1rmFor('bench_press').toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: IFColors.red)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StrengthChart(sessions: stats.chronologicalSessions),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.32,
            children: [
              ForgeMetricTile(label: 'Total Volume', value: '${(stats.totalVolume / 1000).toStringAsFixed(1)}t', icon: Icons.scale_rounded),
              ForgeMetricTile(label: 'Total Workouts', value: '${sessions.length}', icon: Icons.check_circle_rounded),
              ForgeMetricTile(label: 'PRs', value: '${_prCount(sessions)}', icon: Icons.emoji_events_rounded, iconColor: IFColors.gold),
              ForgeMetricTile(label: 'Completed Sets', value: '${stats.totalSets}', icon: Icons.timer_rounded),
            ],
          ),
        ],
      ),
    );
  }

  List<WorkoutSession> _sessionsForRange(List<WorkoutSession> sessions) {
    final days = switch (range) {
      '7D' => 7,
      '4W' => 28,
      '3M' => 90,
      '1Y' => 365,
      _ => null,
    };
    if (days == null) return sessions;
    final since = DateTime.now().subtract(Duration(days: days));
    return sessions.where((session) => session.startedAt.isAfter(since)).toList();
  }

  int _prCount(List<WorkoutSession> sessions) {
    final bestByExercise = <String, double>{};
    var count = 0;
    for (final session in [...sessions]..sort((a, b) => a.startedAt.compareTo(b.startedAt))) {
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          final best = bestByExercise[exercise.exerciseId] ?? 0;
          if (set.estimatedOneRepMax > best) {
            if (best > 0) count++;
            bestByExercise[exercise.exerciseId] = set.estimatedOneRepMax;
          }
        }
      }
    }
    return count;
  }
}

class _StrengthChart extends StatelessWidget {
  const _StrengthChart({required this.sessions});

  final List<WorkoutSession> sessions;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < sessions.length; i++) FlSpot(i.toDouble(), sessions[i].totalVolume / 1000),
    ];

    return ForgeCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      child: SizedBox(
        height: 220,
        child: spots.isEmpty
            ? const Center(child: Text('Save a workout to build your chart.', style: IFText.bodyMuted))
            : LineChart(
                LineChartData(
                  minY: 0,
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: IFColors.borderSoft, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(0)}t', style: const TextStyle(color: IFColors.textFaint, fontSize: 11)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sessions.length) return const SizedBox.shrink();
                          return Text('${sessions[index].startedAt.month}/${sessions[index].startedAt.day}', style: const TextStyle(color: IFColors.textFaint, fontSize: 11));
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      color: IFColors.red,
                      barWidth: 3,
                      isCurved: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: IFColors.red.withValues(alpha: 0.16)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
