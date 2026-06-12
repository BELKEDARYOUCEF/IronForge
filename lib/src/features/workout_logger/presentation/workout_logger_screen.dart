import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_theme.dart';
import '../../../core/sample_data.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../domain/workout.dart';
import '../domain/workout_math.dart';
import 'workout_controller.dart';

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

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({required this.workout});

  final WorkoutSession workout;

  @override
  Widget build(BuildContext context) {
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
          const Expanded(child: _Metric(label: 'Rest', value: '2:00')),
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
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Quick add exercise'),
      items: [
        for (final exercise in sampleExercises)
          DropdownMenuItem(value: exercise.id, child: Text(exercise.name)),
      ],
      onChanged: (id) {
        final exercise = sampleExercises.firstWhere((item) => item.id == id);
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
  final plateCalculator = const PlateCalculator();

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    rpeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(workoutControllerProvider.notifier);
    final plates = plateCalculator.platesPerSide(double.tryParse(weightController.text) ?? 20);

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
                Text('${widget.exercise.restSeconds}s'),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < widget.exercise.sets.length; i++)
              _SetRow(index: i + 1, set: widget.exercise.sets[i], exerciseId: widget.exercise.exerciseId),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _SmallInput(label: 'kg', controller: weightController)),
                const SizedBox(width: 8),
                Expanded(child: _SmallInput(label: 'reps', controller: repsController)),
                const SizedBox(width: 8),
                Expanded(child: _SmallInput(label: 'RPE', controller: rpeController)),
              ],
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
                        weight: double.tryParse(weightController.text) ?? 0,
                        reps: int.tryParse(repsController.text) ?? 0,
                        rpe: double.tryParse(rpeController.text),
                      );
                      controller.addSet(widget.exercise.exerciseId, set);
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
  const _SetRow({required this.index, required this.set, required this.exerciseId});

  final int index;
  final LoggedSet set;
  final String exerciseId;

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
          Expanded(child: Text('${set.weight.g} kg x ${set.reps}')),
          Text('RPE ${set.rpe?.toStringAsFixed(1) ?? '-'}'),
          if (isPr) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.emoji_events, color: forgeGold)),
        ],
      ),
    );
  }
}

extension _WeightFormat on num {
  String get g => this % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(2);
}
