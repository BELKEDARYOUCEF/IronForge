import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_theme.dart';
import '../../../shared/widgets/forge_shell.dart';
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
                for (final exercise in workout.exercises)
                  _LoggedExerciseCard(exercise: exercise),
                if (workout.exercises.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text(
                        'Add your first lift.',
                        style: TextStyle(color: forgeSteel, fontSize: 16),
                      ),
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
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: forgePanel,
        border: Border(bottom: BorderSide(color: Color(0xFF22272E))),
      ),
      child: Row(
        children: [
          Expanded(child: _Metric(label: 'Sets', value: '${workout.totalSets}')),
          Expanded(child: _Metric(label: 'Volume', value: '${(workout.totalVolume / 1000).toStringAsFixed(1)}t')),
          Expanded(
            child: ElevatedButton(
              onPressed: workout.totalSets == 0
                  ? null
                  : () async {
                      await ref.read(workoutControllerProvider.notifier).finishWorkout();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Workout saved offline.')),
                      );
                    },
              child: const Text('Finish'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: forgeSteel, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _ExercisePicker extends ConsumerWidget {
  const _ExercisePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider).valueOrNull ?? const [];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Quick add exercise'),
      items: [
        for (final exercise in exercises)
          DropdownMenuItem(value: exercise.id, child: Text(exercise.name)),
      ],
      onChanged: (id) {
        if (id == null) return;
        final exercise = exercises.firstWhere((item) => item.id == id);
        ref.read(workoutControllerProvider.notifier).addExercise(exercise);
      },
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

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(text: widget.exercise.notes ?? '');
  }

  @override
  void didUpdateWidget(covariant _LoggedExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.notes != widget.exercise.notes && notesController.text != widget.exercise.notes) {
      notesController.text = widget.exercise.notes ?? '';
    }
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
    setState(() => restRemaining = widget.exercise.restSeconds);
    restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (restRemaining <= 1) {
        timer.cancel();
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.heavyImpact();
        setState(() => restRemaining = 0);
        return;
      }
      setState(() => restRemaining -= 1);
    });
  }

  double inputWeightInKg() {
    final value = double.tryParse(weightController.text) ?? 0;
    return unit == _WeightUnit.kg ? value : value / 2.2046226218;
  }

  String formatWeight(double kg) {
    final value = unit == _WeightUnit.kg ? kg : kg * 2.2046226218;
    final label = unit == _WeightUnit.kg ? 'kg' : 'lbs';
    return '${value.g} $label';
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(workoutControllerProvider.notifier);
    final plates = plateCalculator.platesPerSide(inputWeightInKg());
    final restLabel = restRemaining == 0
        ? '${widget.exercise.restSeconds}s'
        : '${(restRemaining ~/ 60).toString().padLeft(1, '0')}:${(restRemaining % 60).toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.exercise.exerciseName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                const Icon(Icons.timer, color: forgeElectric),
                const SizedBox(width: 6),
                Text(restLabel),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < widget.exercise.sets.length; i++)
              _SetRow(
                index: i + 1,
                set: widget.exercise.sets[i],
                exerciseId: widget.exercise.exerciseId,
                formatWeight: formatWeight,
              ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Exercise notes'),
              onChanged: (value) => controller.updateExerciseNotes(widget.exercise.exerciseId, value),
            ),
            const SizedBox(height: 10),
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
              segments: const [
                ButtonSegment(value: _WeightUnit.kg, label: Text('kg')),
                ButtonSegment(value: _WeightUnit.lbs, label: Text('lbs')),
              ],
              selected: {unit},
              onSelectionChanged: (value) => setState(() => unit = value.first),
            ),
            const SizedBox(height: 10),
            Text('Plates/side: ${plates.map((p) => p.g).join(' + ')}', style: const TextStyle(color: forgeSteel)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.addSameAsLastSet(widget.exercise.exerciseId),
                    child: const Text('Same last'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.addSmartSet(widget.exercise.exerciseId),
                    child: const Text('Smart +'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final set = LoggedSet(
                        weight: inputWeightInKg(),
                        reps: int.tryParse(repsController.text) ?? 0,
                        rpe: double.tryParse(rpeController.text),
                      );
                      controller.addSet(widget.exercise.exerciseId, set);
                      HapticFeedback.mediumImpact();
                      SystemSound.play(SystemSoundType.click);
                      startRestTimer();
                      if (controller.isPr(widget.exercise.exerciseId, set)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PR forged. Add plates next time.')),
                        );
                      }
                    },
                    child: const Text('Log'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallInput extends StatelessWidget {
  const _SmallInput({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _SetRow extends ConsumerWidget {
  const _SetRow({
    required this.index,
    required this.set,
    required this.exerciseId,
    required this.formatWeight,
  });

  final int index;
  final LoggedSet set;
  final String exerciseId;
  final String Function(double kg) formatWeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPr = ref.read(workoutControllerProvider.notifier).isPr(exerciseId, set);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: forgePanelAlt,
        borderRadius: BorderRadius.circular(8),
        border: isPr ? Border.all(color: forgeGold) : null,
      ),
      child: Row(
        children: [
          Text('$index', style: const TextStyle(color: forgeSteel)),
          const SizedBox(width: 14),
          Expanded(child: Text('${formatWeight(set.weight)} x ${set.reps}')),
          Text('RPE ${set.rpe?.toStringAsFixed(1) ?? '-'}'),
          if (isPr) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.emoji_events, color: forgeGold)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
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
      builder: (context) {
        return AlertDialog(
          title: Text('Edit set $index'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'kg'),
              ),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'reps'),
              ),
              TextField(
                controller: rpeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'RPE'),
              ),
              TextField(
                controller: notesController,
                minLines: 1,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Set notes'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  LoggedSet(
                    weight: double.tryParse(weightController.text) ?? set.weight,
                    reps: int.tryParse(repsController.text) ?? set.reps,
                    rpe: double.tryParse(rpeController.text),
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                    type: set.type,
                    completedAt: set.completedAt,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    weightController.dispose();
    repsController.dispose();
    rpeController.dispose();
    notesController.dispose();

    if (updated != null) {
      ref.read(workoutControllerProvider.notifier).updateSet(exerciseId, index - 1, updated);
    }
  }
}

extension _WeightFormat on num {
  String get g => this % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(2);
}
