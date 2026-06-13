import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_empty_state.dart';
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
      actions: const [Icon(Icons.tune_rounded), SizedBox(width: 12)],
      child: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('History unavailable: $error')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return ForgeEmptyState(
              icon: Icons.history_rounded,
              title: 'No workouts yet.',
              message: 'Start your first session and forge your baseline.',
              action: ElevatedButton(onPressed: () => context.go('/workout'), child: const Text('START WORKOUT')),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in const ['All', 'Workouts', 'PRs', 'Notes'])
                    ForgeChip(label: item, selected: filter == item, onTap: () => setState(() => filter = item)),
                ],
              ),
              const SizedBox(height: 16),
              for (final session in _filtered(sessions)) _HistoryCard(session: session),
            ],
          );
        },
      ),
    );
  }

  List<WorkoutSession> _filtered(List<WorkoutSession> sessions) {
    return switch (filter) {
      'Notes' => sessions.where((session) => session.exercises.any((exercise) => exercise.notes != null)).toList(),
      _ => sessions,
    };
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().format(session.startedAt);
    final title = session.name ?? (session.exercises.isEmpty ? 'Workout' : session.exercises.first.exerciseName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ForgeCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date.toUpperCase(), style: IFText.micro),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: Text(title, style: IFText.h3)),
                Text('${(session.totalVolume / 1000).toStringAsFixed(1)}t', style: const TextStyle(color: IFColors.red, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
            for (final exercise in session.exercises)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.fitness_center_rounded, color: IFColors.red),
                title: Text(exercise.exerciseName),
                subtitle: Text('${exercise.sets.length} sets • best ${exercise.bestE1rm.toStringAsFixed(1)} kg e1RM'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
