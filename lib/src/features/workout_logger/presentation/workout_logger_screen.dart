import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_empty_state.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../../../shared/widgets/pr_celebration.dart';
import '../../exercises/data/exercise_repository.dart';
import '../domain/workout.dart';
import '../domain/workout_math.dart';
import 'workout_controller.dart';

enum _WeightUnit { kg, lbs }

class WorkoutLoggerScreen extends ConsumerWidget {
  const WorkoutLoggerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutControllerProvider);
    return ForgeShell(
      title: 'Live Workout',
      child: Column(
        children: [
          _WorkoutHeader(workout: workout),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _ExercisePicker(),
                const SizedBox(height: 12),
                for (final exercise in workout.exercises) _LoggedExerciseCard(exercise: exercise),
                if (workout.exercises.isEmpty)
                  ForgeEmptyState(
                    icon: Icons.fitness_center_rounded,
                    title: 'Add your first lift.',
                    message: 'Pick an exercise and start forging your baseline.',
                    action: OutlinedButton.icon(
                      onPressed: () => context.go('/exercises'),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('BUILD LIBRARY'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHeader extends ConsumerWidget {
  const _WorkoutHeader({required this.workout});

  final WorkoutSession workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(color: IFColors.black2, border: Border(bottom: BorderSide(color: IFColors.borderSoft))),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _Metric(label: 'Sets', value: '${workout.totalSets}', icon: Icons.check_circle_rounded)),
              Expanded(child: _Metric(label: 'Volume', value: '${(workout.totalVolume / 1000).toStringAsFixed(1)}t', icon: Icons.scale_rounded)),
              Expanded(child: _Metric(label: 'Exercises', value: '${workout.exercises.length}', icon: Icons.fitness_center_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: workout.totalSets == 0
                ? null
                : () async {
                    await ref.read(workoutControllerProvider.notifier).finishWorkout();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout saved offline.')));
                  },
            icon: const Icon(Icons.flag_rounded),
            label: const Text('FINISH WORKOUT'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: IFColors.red),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: IFText.micro),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }
}

class _ExercisePicker extends ConsumerWidget {
  const _ExercisePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider).valueOrNull ?? const [];

    return ForgeCard(
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), labelText: 'Quick add exercise'),
        items: [
          for (final exercise in exercises) DropdownMenuItem(value: exercise.id, child: Text(exercise.name)),
        ],
        onChanged: (id) {
          if (id == null) return;
          final exercise = exercises.firstWhere((item) => item.id == id);
          ref.read(workoutControllerProvider.notifier).addExercise(exercise);
        },
      ),
    );
  }
}

class _LoggedExerciseCard extends ConsumerStatefulWidget {
  const _LoggedExerciseCard({required this.exercise});

  final LoggedExercise exercise;

  @override
  ConsumerState<_LoggedExerciseCard> createState() => _LoggedExerciseCardState();
}

class _LoggedExerciseCardState extends ConsumerState<_LoggedExerciseCard> {
  final weightController = TextEditingController(text: '100');
  final repsController = TextEditingController(text: '8');
  final rpeController = TextEditingController(text: '8');
  late final TextEditingController notesController;
  final plateCalculator = const PlateCalculator();
  _WeightUnit unit = _WeightUnit.kg;
  Timer? restTimer;
  int restRemaining = 0;
  bool restRunning = true;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(text: widget.exercise.notes ?? '');
  }

  @override
  void dispose() {
    restTimer?.cancel();
    weightController.dispose();
    repsController.dispose();
    rpeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void startRestTimer() {
    restTimer?.cancel();
    setState(() {
      restRemaining = widget.exercise.restSeconds;
      restRunning = true;
    });
    restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!restRunning) return;
      if (restRemaining <= 1) {
        timer.cancel();
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.heavyImpact();
        setState(() => restRemaining = 0);
      } else {
        setState(() => restRemaining -= 1);
      }
    });
  }

  double inputWeightInKg() {
    final value = double.tryParse(weightController.text) ?? 0;
    return unit == _WeightUnit.kg ? value : value / 2.2046226218;
  }

  String formatWeight(double kg) {
    final value = unit == _WeightUnit.kg ? kg : kg * 2.2046226218;
    return '${value.g} ${unit == _WeightUnit.kg ? 'kg' : 'lbs'}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(workoutControllerProvider.notifier);
    final plates = plateCalculator.platesPerSide(inputWeightInKg());

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ForgeCard(
        glow: widget.exercise.sets.isNotEmpty,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.exercise.exerciseName, style: IFText.h2)),
                IconButton(onPressed: () => context.go('/rest-timer'), icon: const Icon(Icons.timer_outlined, color: IFColors.red)),
              ],
            ),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ForgeChip(label: 'Barbell', icon: Icons.fitness_center_rounded),
                ForgeChip(label: 'Compound', icon: Icons.bolt_rounded),
              ],
            ),
            const SizedBox(height: 14),
            if (widget.exercise.sets.isNotEmpty) _SetsTable(exercise: widget.exercise, formatWeight: formatWeight),
            if (widget.exercise.sets.isEmpty) const Text('No working sets yet.', style: IFText.bodyMuted),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.notes_rounded), labelText: 'Exercise notes'),
              onChanged: (value) => controller.updateExerciseNotes(widget.exercise.exerciseId, value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _SmallInput(label: unit == _WeightUnit.kg ? 'kg' : 'lbs', controller: weightController)),
                const SizedBox(width: 8),
                Expanded(child: _SmallInput(label: 'reps', controller: repsController)),
                const SizedBox(width: 8),
                Expanded(child: _SmallInput(label: 'RPE', controller: rpeController)),
              ],
            ),
            const SizedBox(height: 10),
            SegmentedButton<_WeightUnit>(
              segments: const [ButtonSegment(value: _WeightUnit.kg, label: Text('kg')), ButtonSegment(value: _WeightUnit.lbs, label: Text('lbs'))],
              selected: {unit},
              onSelectionChanged: (value) => setState(() => unit = value.first),
            ),
            const SizedBox(height: 12),
            _PlatePreview(plates: plates, onTap: () => context.go('/plate-calculator')),
            const SizedBox(height: 12),
            _RestTimerCompact(
              seconds: restRemaining,
              total: widget.exercise.restSeconds,
              running: restRunning,
              onToggle: () => setState(() => restRunning = !restRunning),
              onAdd15: () => setState(() => restRemaining += 15),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => controller.addSameAsLastSet(widget.exercise.exerciseId), icon: const Icon(Icons.replay_rounded), label: const Text('SAME'))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(onPressed: () => controller.addSmartSet(widget.exercise.exerciseId), icon: const Icon(Icons.auto_awesome_rounded), label: const Text('SMART +'))),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final set = LoggedSet(weight: inputWeightInKg(), reps: int.tryParse(repsController.text) ?? 0, rpe: double.tryParse(rpeController.text));
                final isPr = controller.isPr(widget.exercise.exerciseId, set);
                controller.addSet(widget.exercise.exerciseId, set);
                HapticFeedback.mediumImpact();
                SystemSound.play(SystemSoundType.click);
                startRestTimer();
                if (isPr && context.mounted) {
                  await showPrCelebration(context);
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('LOG SET'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetsTable extends ConsumerWidget {
  const _SetsTable({required this.exercise, required this.formatWeight});

  final LoggedExercise exercise;
  final String Function(double kg) formatWeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Row(
          children: [
            SizedBox(width: 36, child: Text('SET', style: IFText.micro)),
            Expanded(child: Text('LOAD', style: IFText.micro)),
            SizedBox(width: 48, child: Text('REPS', style: IFText.micro)),
            SizedBox(width: 48, child: Text('RPE', style: IFText.micro)),
            SizedBox(width: 44),
          ],
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < exercise.sets.length; i++)
          _SetRow(index: i + 1, set: exercise.sets[i], exerciseId: exercise.exerciseId, formatWeight: formatWeight),
      ],
    );
  }
}

class _SmallInput extends StatelessWidget {
  const _SmallInput({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label));
  }
}

class _RestTimerCompact extends StatelessWidget {
  const _RestTimerCompact({required this.seconds, required this.total, required this.running, required this.onToggle, required this.onAdd15});

  final int seconds;
  final int total;
  final bool running;
  final VoidCallback onToggle;
  final VoidCallback onAdd15;

  @override
  Widget build(BuildContext context) {
    final label = seconds == 0 ? '${total}s' : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    final progress = seconds == 0 ? 0.0 : (seconds / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: IFColors.panel2, borderRadius: BorderRadius.circular(12), border: Border.all(color: IFColors.border)),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(value: progress, color: IFColors.red, backgroundColor: IFColors.panel3, strokeWidth: 5),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('REST TIMER', style: IFText.micro), Text(label, style: IFText.h2)])),
          IconButton(onPressed: onToggle, icon: Icon(running ? Icons.pause_rounded : Icons.play_arrow_rounded)),
          TextButton(onPressed: onAdd15, child: const Text('+15s')),
        ],
      ),
    );
  }
}

class _PlatePreview extends StatelessWidget {
  const _PlatePreview({required this.plates, required this.onTap});

  final List<double> plates;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: IFColors.panel2, borderRadius: BorderRadius.circular(12), border: Border.all(color: IFColors.border)),
        child: Row(
          children: [
            const Icon(Icons.calculate_rounded, color: IFColors.red),
            const SizedBox(width: 10),
            Expanded(child: Text('Plates/side: ${plates.isEmpty ? 'bar only' : plates.map((p) => p.g).join(' + ')}', style: IFText.bodyMuted)),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends ConsumerWidget {
  const _SetRow({required this.index, required this.set, required this.exerciseId, required this.formatWeight});

  final int index;
  final LoggedSet set;
  final String exerciseId;
  final String Function(double kg) formatWeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPr = ref.read(workoutControllerProvider.notifier).isPr(exerciseId, set);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: IFColors.panel2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isPr ? IFColors.gold : IFColors.borderSoft),
      ),
      child: Row(
        children: [
          SizedBox(width: 36, child: Text('$index', style: const TextStyle(color: IFColors.textMuted, fontWeight: FontWeight.w800))),
          Expanded(child: Text(formatWeight(set.weight), style: const TextStyle(fontWeight: FontWeight.w900))),
          SizedBox(width: 48, child: Text('${set.reps}')),
          SizedBox(width: 48, child: Text(set.rpe?.toStringAsFixed(1) ?? '-')),
          if (isPr) const Icon(Icons.emoji_events_rounded, color: IFColors.gold, size: 18),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (action) {
              if (action == 'edit') {
                _showEditSetDialog(context, ref);
              } else if (action == 'delete') {
                ref.read(workoutControllerProvider.notifier).deleteSet(exerciseId, index - 1);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSetDialog(BuildContext context, WidgetRef ref) async {
    final weightController = TextEditingController(text: set.weight.g);
    final repsController = TextEditingController(text: '${set.reps}');
    final rpeController = TextEditingController(text: set.rpe?.g ?? '');
    final notesController = TextEditingController(text: set.notes ?? '');
    final updated = await showDialog<LoggedSet>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit set $index'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'kg')),
            TextField(controller: repsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'reps')),
            TextField(controller: rpeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'RPE')),
            TextField(controller: notesController, minLines: 1, maxLines: 2, decoration: const InputDecoration(labelText: 'Set notes')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              LoggedSet(
                weight: double.tryParse(weightController.text) ?? set.weight,
                reps: int.tryParse(repsController.text) ?? set.reps,
                rpe: double.tryParse(rpeController.text),
                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                type: set.type,
                completedAt: set.completedAt,
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    weightController.dispose();
    repsController.dispose();
    rpeController.dispose();
    notesController.dispose();
    if (updated != null) ref.read(workoutControllerProvider.notifier).updateSet(exerciseId, index - 1, updated);
  }
}

extension _WeightFormat on num {
  String get g => this % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(2);
}
