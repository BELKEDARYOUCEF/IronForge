import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_empty_state.dart';
import '../../../shared/widgets/forge_primary_button.dart';
import '../../../shared/widgets/forge_section_header.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../data/workout_repository.dart';
import '../domain/workout.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(workoutHistoryProvider);

    return ForgeShell(
      title: 'History',
      actions: const [
        Icon(Icons.tune_rounded, color: IFColors.red),
        SizedBox(width: 12),
      ],
      child: history.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: IFColors.red)),
        error: (error, stackTrace) =>
            Center(child: Text('History unavailable: $error')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return ForgeEmptyState(
              icon: Icons.history_rounded,
              title: 'No workouts yet.',
              message: 'Start your first session and forge your baseline.',
              action: ForgePrimaryButton(
                label: 'START WORKOUT',
                icon: Icons.play_arrow_rounded,
                onPressed: () => context.go('/workout'),
              ),
            );
          }

          final filtered = _filtered(sessions);
          final groups = _groupByDay(filtered);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            children: [
              ForgeCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _HistoryMetric(
                        label: 'Workouts', value: '${sessions.length}'),
                    _HistoryMetric(
                        label: 'Sets', value: '${_totalSets(sessions)}'),
                    _HistoryMetric(
                        label: 'Volume',
                        value:
                            '${(_totalVolume(sessions) / 1000).toStringAsFixed(1)}t'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in const ['All', 'Workouts', 'PRs', 'Notes'])
                    ForgeChip(
                        label: item,
                        selected: filter == item,
                        onTap: () => setState(() => filter = item)),
                ],
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const ForgeEmptyState(
                  compact: true,
                  icon: Icons.filter_alt_off_rounded,
                  title: 'No matching workouts.',
                  message: 'Try another history filter.',
                )
              else
                for (final group in groups.entries) ...[
                  ForgeSectionHeader(title: group.key),
                  const SizedBox(height: 10),
                  for (final session in group.value)
                    _HistoryCard(session: session),
                  const SizedBox(height: 4),
                ],
            ],
          );
        },
      ),
    );
  }

  List<WorkoutSession> _filtered(List<WorkoutSession> sessions) {
    return switch (filter) {
      'Notes' => sessions
          .where((session) =>
              session.exercises.any((exercise) => exercise.notes != null))
          .toList(),
      'PRs' => sessions
          .where((session) =>
              session.exercises.any((exercise) => exercise.bestE1rm > 0))
          .toList(),
      _ => sessions,
    };
  }

  Map<String, List<WorkoutSession>> _groupByDay(List<WorkoutSession> sessions) {
    final groups = <String, List<WorkoutSession>>{};
    for (final session in sessions) {
      final label = DateFormat.yMMMMd().format(session.startedAt);
      groups.putIfAbsent(label, () => []).add(session);
    }
    return groups;
  }

  int _totalSets(List<WorkoutSession> sessions) {
    return sessions.fold(0, (sum, session) => sum + session.totalSets);
  }

  double _totalVolume(List<WorkoutSession> sessions) {
    return sessions.fold(0, (sum, session) => sum + session.totalVolume);
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm().format(session.startedAt);
    final title = session.name ??
        (session.exercises.isEmpty
            ? 'Workout'
            : session.exercises.first.exerciseName);
    final duration = _durationLabel(session);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ForgeCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: IFColors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                    border:
                        Border.all(color: IFColors.red.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.fitness_center_rounded,
                      color: IFColors.red),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: IFText.h3),
                      const SizedBox(height: 3),
                      Text(
                          '$time • ${session.exercises.length} exercises • ${session.totalSets} sets',
                          style: IFText.micro),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(session.totalVolume / 1000).toStringAsFixed(1)}t',
                      style: const TextStyle(
                          color: IFColors.red, fontWeight: FontWeight.w900),
                    ),
                    if (duration != null) Text(duration, style: IFText.micro),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final exercise in session.exercises)
              _ExerciseHistoryRow(exercise: exercise),
          ],
        ),
      ),
    );
  }

  String? _durationLabel(WorkoutSession session) {
    final completedAt = session.completedAt;
    if (completedAt == null) return null;
    final minutes = completedAt.difference(session.startedAt).inMinutes;
    if (minutes <= 0) return null;
    if (minutes < 60) return '${minutes}m';
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }
}

class _ExerciseHistoryRow extends StatelessWidget {
  const _ExerciseHistoryRow({required this.exercise});

  final LoggedExercise exercise;

  @override
  Widget build(BuildContext context) {
    final bestSet = _bestSet(exercise);
    final bestLabel = bestSet == null
        ? '-'
        : bestSet.weight == 0
            ? 'Bodyweight'
            : '${bestSet.weight.g} kg';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: IFColors.panel2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IFColors.borderSoft),
      ),
      child: Row(
        children: [
          const Icon(Icons.chevron_right_rounded,
              color: IFColors.textFaint, size: 19),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.exerciseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: IFText.cardTitle),
                const SizedBox(height: 2),
                Text(
                    '${exercise.sets.length} sets • best ${exercise.bestE1rm.g} kg e1RM',
                    style: IFText.micro),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(bestLabel,
              style: const TextStyle(
                  color: IFColors.red, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  LoggedSet? _bestSet(LoggedExercise exercise) {
    LoggedSet? best;
    for (final set in exercise.sets) {
      if (best == null || set.weight > best.weight) best = set;
    }
    return best;
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label.toUpperCase(), style: IFText.micro),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: IFColors.text)),
          ),
        ],
      ),
    );
  }
}

extension _HistoryWeightFormat on num {
  String get g => this % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(1);
}
