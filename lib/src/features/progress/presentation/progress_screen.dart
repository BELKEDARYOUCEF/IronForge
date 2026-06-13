import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/app_theme.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../../workout_logger/domain/workout.dart';
import '../../workout_logger/data/workout_repository.dart';
import '../domain/progress_stats.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(workoutHistoryProvider);
    final stats = ProgressStats(history.valueOrNull ?? const []);

    return ForgeShell(
      title: 'Progress',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (history.isLoading)
            const LinearProgressIndicator(),
          _ProgressCard(label: 'Total volume', value: '${(stats.totalVolume / 1000).toStringAsFixed(1)}t'),
          _ProgressCard(label: 'Completed sets', value: '${stats.totalSets}'),
          _ProgressCard(label: 'Bench E1RM', value: '${stats.bestE1rmFor('bench_press').toStringAsFixed(1)} kg'),
          const SizedBox(height: 12),
          const Text('Strength Curve', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _StrengthChart(sessions: stats.chronologicalSessions),
        ],
      ),
    );
  }
}

class _StrengthChart extends StatelessWidget {
  const _StrengthChart({required this.sessions});

  final List<WorkoutSession> sessions;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < sessions.length; i++)
        FlSpot(i.toDouble(), sessions[i].totalVolume / 1000),
    ];

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      decoration: BoxDecoration(color: forgePanel, borderRadius: BorderRadius.circular(8)),
      child: spots.isEmpty
          ? const Center(
              child: Text('Save a workout to build your chart.', style: TextStyle(color: forgeSteel)),
            )
          : LineChart(
              LineChartData(
                minY: 0,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toStringAsFixed(0)}t',
                        style: const TextStyle(color: forgeSteel, fontSize: 11),
                      ),
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
                        return Text(
                          '${sessions[index].startedAt.month}/${sessions[index].startedAt.day}',
                          style: const TextStyle(color: forgeSteel, fontSize: 11),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    color: forgeElectric,
                    barWidth: 3,
                    isCurved: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: forgeElectric.withValues(alpha: 0.16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(color: forgeSteel)),
        trailing: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
