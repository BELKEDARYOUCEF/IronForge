import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_spacing.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_empty_state.dart';
import '../../../shared/widgets/forge_metric_tile.dart';
import '../../../shared/widgets/forge_section_header.dart';
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
    final allSessions = history.valueOrNull ?? const <WorkoutSession>[];
    final bestBench = stats.bestE1rmFor('bench_press');
    final benchDelta = _benchDelta(allSessions);

    return ForgeShell(
      title: 'Progress Overview',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          if (history.isLoading)
            const LinearProgressIndicator(color: IFColors.red),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in const ['7D', '4W', '3M', '1Y', 'ALL'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ForgeChip(
                      label: item,
                      selected: range == item,
                      onTap: () => setState(() => range = item),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: IFSpacing.spacingBlock),
          _MainStrengthCard(bestBench: bestBench, delta: benchDelta),
          const SizedBox(height: IFSpacing.spacingBlock),
          const ForgeSectionHeader(
              title: 'Strength Curve', subtitle: 'Volume by session'),
          const SizedBox(height: 8),
          _StrengthChart(sessions: stats.chronologicalSessions),
          const SizedBox(height: IFSpacing.spacingBlock),
          if (sessions.isEmpty)
            const ForgeEmptyState(
              compact: true,
              icon: Icons.show_chart_rounded,
              title: 'No progress yet.',
              message: 'Save workouts to build your strength curve.',
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: IFSpacing.spacingBlock,
              crossAxisSpacing: IFSpacing.spacingBlock,
              childAspectRatio: 1.4,
              children: [
                ForgeMetricTile(
                  label: 'Total Volume',
                  value: '${(stats.totalVolume / 1000).toStringAsFixed(1)}t',
                  icon: Icons.scale_rounded,
                ),
                ForgeMetricTile(
                  label: 'Total Workouts',
                  value: '${sessions.length}',
                  icon: Icons.check_circle_rounded,
                ),
                ForgeMetricTile(
                  label: 'PRs',
                  value: '${_prCount(sessions)}',
                  icon: Icons.emoji_events_rounded,
                  iconColor: IFColors.gold,
                ),
                ForgeMetricTile(
                  label: 'Completed Sets',
                  value: '${stats.totalSets}',
                  icon: Icons.timer_rounded,
                ),
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
    return sessions
        .where((session) => session.startedAt.isAfter(since))
        .toList();
  }

  int _prCount(List<WorkoutSession> sessions) {
    final bestByExercise = <String, double>{};
    var count = 0;
    for (final session in [...sessions]
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt))) {
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

  double? _benchDelta(List<WorkoutSession> sessions) {
    final now = DateTime.now();
    final currentSince = now.subtract(const Duration(days: 30));
    final previousSince = now.subtract(const Duration(days: 60));
    final current = ProgressStats(sessions
            .where((s) => s.startedAt.isAfter(currentSince))
            .toList())
        .bestE1rmFor('bench_press');
    final previous = ProgressStats(sessions
            .where((s) =>
                s.startedAt.isAfter(previousSince) &&
                s.startedAt.isBefore(currentSince))
            .toList())
        .bestE1rmFor('bench_press');
    if (current == 0 || previous == 0) return null;
    return current - previous;
  }
}

class _MainStrengthCard extends StatelessWidget {
  const _MainStrengthCard({required this.bestBench, required this.delta});

  final double bestBench;
  final double? delta;

  @override
  Widget build(BuildContext context) {
    final hasBench = bestBench > 0;
    final deltaPositive = delta != null && delta! >= 0;
    final deltaColor =
        delta == null ? IFColors.textMuted : (deltaPositive ? IFColors.green : IFColors.orange);
    final deltaText = delta == null
        ? 'Log bench sets to calculate progress.'
        : '${deltaPositive ? '+' : ''}${delta!.toStringAsFixed(1)} kg from last 30 days';

    return ForgeCard(
      glow: hasBench,
      padding: const EdgeInsets.all(IFSpacing.paddingCard),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BENCH PRESS', style: IFText.micro),
                const SizedBox(height: 6),
                const Text('1RM Estimate', style: IFText.bodyMuted),
                const SizedBox(height: 4),
                Text(
                  hasBench ? '${bestBench.toStringAsFixed(1)} kg' : '—',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: IFColors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deltaText,
                  style: TextStyle(
                    color: deltaColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: IFColors.red.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: IFColors.red.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.fitness_center_rounded, color: IFColors.red),
          ),
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

    // Show bottom labels only when there are few sessions to avoid crowding.
    final showBottomLabels = sessions.length <= 10;

    return ForgeCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      child: SizedBox(
        height: 200,
        child: spots.isEmpty
            ? const Center(
                child: Text('Save workouts to build your strength curve.',
                    style: IFText.bodyMuted))
            : LineChart(
                LineChartData(
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => const FlLine(
                        color: IFColors.borderSoft, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toStringAsFixed(0)}t',
                          style: const TextStyle(
                              color: IFColors.textFaint, fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: showBottomLabels,
                        reservedSize: 26,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sessions.length) {
                            return const SizedBox.shrink();
                          }
                          final d = sessions[index].startedAt;
                          return Text(
                            '${d.month}/${d.day}',
                            style: const TextStyle(
                                color: IFColors.textFaint, fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      color: IFColors.red,
                      barWidth: 2.5,
                      isCurved: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 3,
                          color: IFColors.red,
                          strokeWidth: 2,
                          strokeColor: IFColors.black,
                        ),
                      ),
                      belowBarData: BarAreaData(
                          show: true,
                          color: IFColors.red.withValues(alpha: 0.14)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
