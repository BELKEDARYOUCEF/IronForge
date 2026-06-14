import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_spacing.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_progress_ring.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../../onboarding/data/user_profile_repository.dart';
import '../../workout_logger/data/workout_repository.dart';
import '../../workout_logger/domain/workout.dart';
import '../domain/coach_engine.dart';

class AiCoachScreen extends ConsumerWidget {
  const AiCoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(workoutHistoryProvider);
    final profileAsync = ref.watch(userProfileProvider);

    final sessions = history.valueOrNull ?? const [];
    final profile = profileAsync.valueOrNull;

    final insights = const CoachEngine().analyze(
      sessions,
      weeklyFrequencyGoal: profile?.frequencyPerWeek ?? 3,
    );

    // Consistency = sessions this week ÷ weekly goal, clamped 0–100%
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final sessionsThisWeek =
        sessions.where((s) => !s.startedAt.isBefore(weekStart)).length;
    final goal = profile?.frequencyPerWeek ?? 3;
    final consistency =
        goal > 0 ? (sessionsThisWeek / goal).clamp(0.0, 1.0) : 0.0;

    // Volume chart: last 8 sessions in chronological order
    final sorted = [...sessions]
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    final chartSessions =
        sorted.length > 8 ? sorted.sublist(sorted.length - 8) : sorted;

    return ForgeShell(
      title: 'AI Coach',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          if (history.isLoading)
            const LinearProgressIndicator(color: IFColors.red),
          for (final insight in insights) ...[
            _InsightCard(insight: insight),
            const SizedBox(height: IFSpacing.spacingBlock),
          ],
          _ConsistencyCard(
            consistency: consistency,
            sessionsThisWeek: sessionsThisWeek,
            goal: goal,
          ),
          const SizedBox(height: IFSpacing.spacingBlock),
          _VolumeCard(sessions: chartSessions),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final CoachInsight insight;

  @override
  Widget build(BuildContext context) {
    final color = switch (insight.tone) {
      InsightTone.alert => IFColors.red,
      InsightTone.positive => IFColors.green,
      InsightTone.neutral => IFColors.blue,
    };
    final icon = switch (insight.tone) {
      InsightTone.alert => Icons.warning_amber_rounded,
      InsightTone.positive => Icons.trending_up_rounded,
      InsightTone.neutral => Icons.psychology_alt_rounded,
    };
    final badge = switch (insight.tone) {
      InsightTone.alert => 'ALERT',
      InsightTone.positive => 'POSITIVE',
      InsightTone.neutral => 'COACH',
    };

    return ForgeCard(
      glow: insight.tone == InsightTone.alert,
      borderColor: color,
      padding: const EdgeInsets.all(IFSpacing.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              const Text('INSIGHT', style: IFText.label),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(badge,
                    style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: IFSpacing.spacingBlock),
          Text(insight.title, style: IFText.h3),
          const SizedBox(height: 6),
          Text(insight.body, style: IFText.bodyMuted),
        ],
      ),
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard({
    required this.consistency,
    required this.sessionsThisWeek,
    required this.goal,
  });

  final double consistency;
  final int sessionsThisWeek;
  final int goal;

  String get _statusText {
    if (consistency >= 1.0) return 'On track';
    if (consistency >= 0.5) return 'Keep going';
    return 'Behind pace';
  }

  Color get _statusColor {
    if (consistency >= 1.0) return IFColors.green;
    if (consistency >= 0.5) return IFColors.orange;
    return IFColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (consistency * 100).round();

    return ForgeCard(
      padding: const EdgeInsets.all(IFSpacing.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                  child: Text('CONSISTENCY', style: IFText.label)),
              _ComingSoonPill(),
            ],
          ),
          const SizedBox(height: IFSpacing.spacingBlock),
          Row(
            children: [
              ForgeProgressRing(
                size: 86,
                strokeWidth: 9,
                value: consistency,
                color: _statusColor,
                backgroundColor: IFColors.panel3,
                center: Text(
                  '$pct%',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: IFColors.text,
                  ),
                ),
              ),
              const SizedBox(width: IFSpacing.spacingBlock),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusText,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sessionsThisWeek / $goal sessions this week',
                      style: IFText.bodyMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: IFSpacing.spacingBlock),
          const _ComingSoonRow(
              icon: Icons.bedtime_rounded, label: 'Sleep'),
          const _ComingSoonRow(
              icon: Icons.monitor_heart_rounded, label: 'HRV'),
        ],
      ),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  const _VolumeCard({required this.sessions});

  final List<WorkoutSession> sessions;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      padding: const EdgeInsets.fromLTRB(
          12, IFSpacing.paddingCard, 16, IFSpacing.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VOLUME ANALYSIS', style: IFText.label),
          const SizedBox(height: IFSpacing.spacingBlock),
          SizedBox(
            height: 130,
            child: sessions.isEmpty
                ? const Center(
                    child: Text(
                      'Start logging sessions to see volume trends.',
                      style: IFText.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                  )
                : BarChart(
                    BarChartData(
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
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= sessions.length) {
                                return const SizedBox.shrink();
                              }
                              final d = sessions[i].startedAt;
                              return Text(
                                '${d.month}/${d.day}',
                                style: const TextStyle(
                                    color: IFColors.textFaint, fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < sessions.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: sessions[i].totalVolume / 1000,
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [IFColors.redGlow, IFColors.redDark],
                                ),
                                width: 16,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            sessions.isEmpty
                ? '—'
                : 'Last ${sessions.length} session${sessions.length == 1 ? "" : "s"}.',
            style: IFText.micro,
          ),
        ],
      ),
    );
  }
}

class _ComingSoonRow extends StatelessWidget {
  const _ComingSoonRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: IFColors.panel2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: IFColors.borderSoft, width: IFSpacing.borderWidth),
      ),
      child: Row(
        children: [
          Icon(icon, color: IFColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: IFText.cardTitle)),
          const Text('Coming soon',
              style: TextStyle(
                  color: IFColors.textFaint, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ComingSoonPill extends StatelessWidget {
  const _ComingSoonPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: IFColors.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: IFColors.blue.withValues(alpha: 0.25)),
      ),
      child: const Text(
        'COMING SOON',
        style: TextStyle(
            color: IFColors.blue, fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }
}
