import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_spacing.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_empty_state.dart';
import '../../../shared/widgets/forge_primary_button.dart';
import '../../../shared/widgets/forge_progress_ring.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../../../shared/widgets/pr_celebration.dart';
import '../../exercises/data/exercise_repository.dart';
import '../../exercises/domain/exercise.dart';
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              children: [
                const _ExercisePicker(),
                const SizedBox(height: 10),
                for (final exercise in workout.exercises)
                  _LoggedExerciseCard(exercise: exercise),
                if (workout.exercises.isEmpty)
                  ForgeEmptyState(
                    icon: Icons.fitness_center_rounded,
                    title: 'Add your first lift.',
                    message:
                        'Pick an exercise and start forging your baseline.',
                    action: ForgePrimaryButton(
                      label: 'BUILD LIBRARY',
                      icon: Icons.add_rounded,
                      onPressed: () => context.go('/exercises'),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: IFColors.black2,
        border: Border(bottom: BorderSide(color: IFColors.borderSoft)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LIVE WORKOUT', style: IFText.micro),
                    const SizedBox(height: 3),
                    Text(
                      workout.exercises.isEmpty
                          ? 'Build your session'
                          : workout.exercises.first.exerciseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: IFText.h2,
                    ),
                  ],
                ),
              ),
              _HeaderIconButton(
                icon: Icons.more_vert_rounded,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              ForgePrimaryButton(
                label: 'FINISH',
                icon: Icons.flag_rounded,
                fullWidth: false,
                height: 42,
                onPressed: workout.totalSets == 0
                    ? null
                    : () async {
                        await ref
                            .read(workoutControllerProvider.notifier)
                            .finishWorkout();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Workout saved offline.')),
                        );
                        context.go('/');
                      },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Sets',
                  value: '${workout.totalSets}',
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  label: 'Volume',
                  value: '${(workout.totalVolume / 1000).toStringAsFixed(1)}t',
                  icon: Icons.scale_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  label: 'Exercises',
                  value: '${workout.exercises.length}',
                  icon: Icons.fitness_center_rounded,
                ),
              ),
            ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: IFColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IFColors.borderSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: IFColors.red),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: IFText.micro),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: SizedBox(
        width: 42,
        height: 42,
        child: Icon(icon, color: IFColors.textMuted, size: 21),
      ),
    );
  }
}

class _ExercisePicker extends ConsumerStatefulWidget {
  const _ExercisePicker();

  @override
  ConsumerState<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends ConsumerState<_ExercisePicker> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final exercises =
        ref.watch(exercisesProvider).valueOrNull ?? const <Exercise>[];

    return ForgeCard(
      onTap: () => _showPicker(context, exercises),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: IFColors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: IFColors.red.withValues(alpha: 0.26)),
            ),
            child: const Icon(Icons.search_rounded, color: IFColors.red),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('QUICK ADD EXERCISE', style: IFText.micro),
                SizedBox(height: 3),
                Text('Search your library', style: IFText.cardTitle),
              ],
            ),
          ),
          const Icon(Icons.add_rounded, color: IFColors.red),
        ],
      ),
    );
  }

  Future<void> _showPicker(
      BuildContext context, List<Exercise> exercises) async {
    query = '';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IFColors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final visible = exercises.where((exercise) {
              final search = query.trim().toLowerCase();
              return search.isEmpty ||
                  exercise.name.toLowerCase().contains(search) ||
                  exercise.primaryMuscle.toLowerCase().contains(search) ||
                  exercise.equipment.toLowerCase().contains(search);
            }).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  16 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: IFColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Expanded(child: Text('Add Exercise', style: IFText.h2)),
                        Icon(Icons.fitness_center_rounded, color: IFColors.red),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        labelText: 'Search exercises',
                      ),
                      onChanged: (value) => setSheetState(() => query = value),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 380),
                      child: visible.isEmpty
                          ? const ForgeEmptyState(
                              compact: true,
                              icon: Icons.search_rounded,
                              title: 'No exercises found.',
                              message:
                                  'Adjust search or add a custom exercise.',
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: visible.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final exercise = visible[index];
                                return ForgeCard(
                                  padding: const EdgeInsets.all(12),
                                  onTap: () {
                                    ref
                                        .read(
                                            workoutControllerProvider.notifier)
                                        .addExercise(exercise);
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(_equipmentIcon(exercise.equipment),
                                          color: IFColors.red),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(exercise.name,
                                                style: IFText.cardTitle),
                                            Text(
                                              '${exercise.primaryMuscle} • ${exercise.equipment}',
                                              style: IFText.bodyMuted,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.add_rounded,
                                          color: IFColors.red),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _equipmentIcon(String equipment) {
    return switch (equipment) {
      'Barbell' => Icons.fitness_center_rounded,
      'Dumbbell' => Icons.sports_gymnastics_rounded,
      'Machine' => Icons.precision_manufacturing_rounded,
      'Cable' => Icons.cable_rounded,
      'Bodyweight' => Icons.accessibility_new_rounded,
      _ => Icons.fitness_center_rounded,
    };
  }
}

class _LoggedExerciseCard extends ConsumerStatefulWidget {
  const _LoggedExerciseCard({required this.exercise});

  final LoggedExercise exercise;

  @override
  ConsumerState<_LoggedExerciseCard> createState() =>
      _LoggedExerciseCardState();
}

class _LoggedExerciseCardState extends ConsumerState<_LoggedExerciseCard> {
  final weightController = TextEditingController(text: '100');
  final repsController = TextEditingController(text: '8');
  final rpeController = TextEditingController(text: '8');
  late final TextEditingController notesController;
  final plateCalculator = const PlateCalculator();
  final _overload = const ProgressiveOverloadEngine();
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
    final library =
        ref.watch(exercisesProvider).valueOrNull ?? const <Exercise>[];
    final meta = _exerciseMeta(library, widget.exercise.exerciseId);
    final plates = plateCalculator.platesPerSide(inputWeightInKg());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ForgeCard(
        glow: widget.exercise.sets.isNotEmpty,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.exercise.exerciseName, style: IFText.h2),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.exercise.sets.length} sets • ${(widget.exercise.totalVolume / 1000).toStringAsFixed(1)}t volume',
                        style: IFText.micro,
                      ),
                    ],
                  ),
                ),
                _CompactIconAction(
                  icon: Icons.calculate_rounded,
                  onTap: () => context.go('/plate-calculator'),
                ),
                const SizedBox(width: 6),
                _CompactIconAction(
                  icon: Icons.timer_outlined,
                  onTap: () => context.go('/rest-timer'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ForgeChip(
                  label: meta?.equipment ?? 'Exercise',
                  icon: _equipmentIcon(meta?.equipment),
                ),
                ForgeChip(
                  label: meta?.primaryMuscle ?? 'Tracked',
                  icon: Icons.bolt_rounded,
                ),
                ForgeChip(
                  label: widget.exercise.sets.isEmpty ? 'Baseline' : 'Working',
                  icon: Icons.check_circle_rounded,
                  color: widget.exercise.sets.isEmpty
                      ? IFColors.textMuted
                      : IFColors.red,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.exercise.sets.isNotEmpty)
              _SetsTable(exercise: widget.exercise, formatWeight: formatWeight),
            if (widget.exercise.sets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: IFColors.panel2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: IFColors.borderSoft),
                ),
                child:
                    const Text('No working sets yet.', style: IFText.bodyMuted),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              minLines: 1,
              maxLines: 2,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.notes_rounded), labelText: 'Notes'),
              onChanged: (value) => controller.updateExerciseNotes(
                  widget.exercise.exerciseId, value),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _SmallInput(
                        label: unit == _WeightUnit.kg ? 'kg' : 'lbs',
                        controller: weightController)),
                const SizedBox(width: 8),
                Expanded(
                    child:
                        _SmallInput(label: 'reps', controller: repsController)),
                const SizedBox(width: 8),
                Expanded(
                    child:
                        _SmallInput(label: 'RPE', controller: rpeController)),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<_WeightUnit>(
                segments: const [
                  ButtonSegment(value: _WeightUnit.kg, label: Text('kg')),
                  ButtonSegment(value: _WeightUnit.lbs, label: Text('lbs')),
                ],
                selected: {unit},
                onSelectionChanged: (value) =>
                    setState(() => unit = value.first),
              ),
            ),
            const SizedBox(height: 10),
            _RestTimerCompact(
              seconds: restRemaining,
              total: widget.exercise.restSeconds,
              running: restRunning,
              onToggle: () => setState(() => restRunning = !restRunning),
              onAdd15: () => setState(() => restRemaining += 15),
            ),
            const SizedBox(height: 10),
            _PlatePreview(
                plates: plates, onTap: () => context.go('/plate-calculator')),
            const SizedBox(height: 10),
            // ── Overload hint (Hive last set) ───────────────────────
            Builder(builder: (context) {
              final lastSet = controller
                  .lastKnownSet(widget.exercise.exerciseId);
              if (lastSet == null) return const SizedBox.shrink();
              final suggested = _overload.suggestNextSet(lastSet);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OverloadHint(
                  lastSet: lastSet,
                  suggested: suggested,
                  formatWeight: formatWeight,
                ),
              );
            }),
            // ── Compact action bar: SAME | SMART+ | LOG SET ─────────
            Row(
              children: [
                Expanded(
                  child: _QuickSetButton(
                    label: 'SAME',
                    icon: Icons.replay_rounded,
                    onPressed: () => controller
                        .addSameAsLastSet(widget.exercise.exerciseId),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _QuickSetButton(
                    label: 'SMART+',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: () =>
                        controller.addSmartSet(widget.exercise.exerciseId),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: ForgePrimaryButton(
                    onPressed: () async {
                      final set = LoggedSet(
                        weight: inputWeightInKg(),
                        reps: int.tryParse(repsController.text) ?? 0,
                        rpe: double.tryParse(rpeController.text),
                      );
                      final isPr = controller
                          .isPr(widget.exercise.exerciseId, set);
                      controller.addSet(widget.exercise.exerciseId, set);
                      HapticFeedback.mediumImpact();
                      SystemSound.play(SystemSoundType.click);
                      startRestTimer();
                      if (isPr && context.mounted) {
                        await showPrCelebration(context);
                      }
                    },
                    icon: Icons.add_rounded,
                    label: 'LOG SET',
                    height: 44,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _equipmentIcon(String? equipment) {
    return switch (equipment) {
      'Barbell' => Icons.fitness_center_rounded,
      'Dumbbell' => Icons.sports_gymnastics_rounded,
      'Machine' => Icons.precision_manufacturing_rounded,
      'Cable' => Icons.cable_rounded,
      'Bodyweight' => Icons.accessibility_new_rounded,
      _ => Icons.fitness_center_rounded,
    };
  }

  Exercise? _exerciseMeta(List<Exercise> exercises, String id) {
    for (final exercise in exercises) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }
}

class _CompactIconAction extends StatelessWidget {
  const _CompactIconAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: IFColors.panel2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: IFColors.border),
        ),
        child: Icon(icon, color: IFColors.red, size: 19),
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
    final allSets = exercise.sets.asMap().entries.toList();
    final warmup =
        allSets.where((e) => e.value.type == SetType.warmup).toList();
    final working =
        allSets.where((e) => e.value.type != SetType.warmup).toList();
    final lastIndex = exercise.sets.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Column headers ─────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              SizedBox(width: 30, child: Text('SET', style: IFText.micro)),
              Expanded(child: Text('WEIGHT', style: IFText.micro)),
              SizedBox(
                  width: 44,
                  child: Text('REPS',
                      style: IFText.micro, textAlign: TextAlign.center)),
              SizedBox(
                  width: 40,
                  child: Text('RPE',
                      style: IFText.micro, textAlign: TextAlign.center)),
              SizedBox(width: 60),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Warm-up section (only when warmup sets exist) ──────────
        if (warmup.isNotEmpty) ...[
          const _SectionLabel(label: 'WARM UP'),
          const SizedBox(height: 4),
          for (final entry in warmup)
            _SetRow(
              index: entry.key + 1,
              set: entry.value,
              exerciseId: exercise.exerciseId,
              formatWeight: formatWeight,
              isActive: entry.key == lastIndex,
            ),
          const SizedBox(height: 6),
        ],

        // ── Working sets section ────────────────────────────────────
        const _SectionLabel(label: 'WORKING SETS'),
        const SizedBox(height: 4),
        for (final entry in working)
          _SetRow(
            index: entry.key + 1,
            set: entry.value,
            exerciseId: exercise.exerciseId,
            formatWeight: formatWeight,
            isActive: entry.key == lastIndex,
          ),
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
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w900),
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _RestTimerCompact extends StatelessWidget {
  const _RestTimerCompact(
      {required this.seconds,
      required this.total,
      required this.running,
      required this.onToggle,
      required this.onAdd15});

  final int seconds;
  final int total;
  final bool running;
  final VoidCallback onToggle;
  final VoidCallback onAdd15;

  @override
  Widget build(BuildContext context) {
    final label = seconds == 0
        ? '${total}s'
        : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    final progress = seconds == 0 ? 0.0 : (seconds / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: IFColors.panel2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IFColors.border),
      ),
      child: Row(
        children: [
          ForgeProgressRing(
            value: progress,
            size: 46,
            strokeWidth: 5,
            center:
                const Icon(Icons.timer_outlined, color: IFColors.red, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('REST TIMER', style: IFText.micro),
                Text(label, style: IFText.h2),
              ],
            ),
          ),
          IconButton(
              onPressed: onToggle,
              icon: Icon(
                  running ? Icons.pause_rounded : Icons.play_arrow_rounded)),
          _TinyTextAction(label: '+15s', onTap: onAdd15),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: IFColors.panel2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: IFColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calculate_rounded, color: IFColors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Plates/side: ${plates.isEmpty ? 'bar only' : plates.map((p) => p.g).join(' + ')}',
                style: IFText.bodyMuted,
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends ConsumerWidget {
  const _SetRow({
    required this.index,
    required this.set,
    required this.exerciseId,
    required this.formatWeight,
    this.isActive = false,
  });

  final int index;
  final LoggedSet set;
  final String exerciseId;
  final String Function(double kg) formatWeight;
  final bool isActive;

  static const _activeBg = Color(0xFF1A0606);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPr =
        ref.read(workoutControllerProvider.notifier).isPr(exerciseId, set);

    final borderColor = isActive
        ? IFColors.red
        : isPr
            ? IFColors.gold
            : IFColors.borderSoft;
    final borderWidth = isActive ? 1.0 : IFSpacing.borderWidth;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? _activeBg : IFColors.panel2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '$index',
                style: TextStyle(
                  color: isActive ? IFColors.red : IFColors.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                formatWeight(set.weight),
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '${set.reps}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                set.rpe?.toStringAsFixed(1) ?? '-',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: IFColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
            if (isPr)
              const Icon(Icons.emoji_events_rounded,
                  color: IFColors.gold, size: 16)
            else
              Icon(Icons.check_circle_rounded,
                  color: isActive ? IFColors.red : IFColors.textMuted,
                  size: 16),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  size: 18, color: IFColors.textFaint),
              onSelected: (action) {
                if (action == 'edit') {
                  _showEditSetDialog(context, ref);
                } else if (action == 'delete') {
                  ref
                      .read(workoutControllerProvider.notifier)
                      .deleteSet(exerciseId, index - 1);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSetDialog(BuildContext context, WidgetRef ref) async {
    final weightController = TextEditingController(text: set.weight.g);
    final repsController = TextEditingController(text: '${set.reps}');
    final rpeController = TextEditingController(text: set.rpe?.g ?? '');
    final notesController = TextEditingController(text: set.notes ?? '');
    final updated = await showModalBottomSheet<LoggedSet>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IFColors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: IFColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: Text('Edit set $index', style: IFText.h2)),
                  const Icon(Icons.edit_rounded, color: IFColors.red),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                      child: _SmallInput(
                          label: 'kg', controller: weightController)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _SmallInput(
                          label: 'reps', controller: repsController)),
                  const SizedBox(width: 8),
                  Expanded(
                      child:
                          _SmallInput(label: 'RPE', controller: rpeController)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                minLines: 1,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Set notes'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _QuickSetButton(
                      label: 'CANCEL',
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ForgePrimaryButton(
                      label: 'SAVE',
                      icon: Icons.check_rounded,
                      height: 46,
                      onPressed: () => Navigator.pop(
                        context,
                        LoggedSet(
                          weight: double.tryParse(weightController.text) ??
                              set.weight,
                          reps: int.tryParse(repsController.text) ?? set.reps,
                          rpe: double.tryParse(rpeController.text),
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                          type: set.type,
                          completedAt: set.completedAt,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    weightController.dispose();
    repsController.dispose();
    rpeController.dispose();
    notesController.dispose();
    if (updated != null) {
      ref
          .read(workoutControllerProvider.notifier)
          .updateSet(exerciseId, index - 1, updated);
    }
  }
}

class _OverloadHint extends StatelessWidget {
  const _OverloadHint({
    required this.lastSet,
    required this.suggested,
    required this.formatWeight,
  });

  final LoggedSet lastSet;
  final LoggedSet suggested;
  final String Function(double kg) formatWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: IFColors.panel2,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: IFColors.border, width: IFSpacing.borderWidth),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded,
              size: 13, color: IFColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Last: ${formatWeight(lastSet.weight)} × ${lastSet.reps} reps',
              style: IFText.micro,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded,
              size: 11, color: IFColors.green),
          const SizedBox(width: 4),
          Text(
            'try ${formatWeight(suggested.weight)}',
            style: const TextStyle(
              color: IFColors.green,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(label, style: IFText.micro),
    );
  }
}

class _QuickSetButton extends StatelessWidget {
  const _QuickSetButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: IFColors.panel2,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: IFColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: IFColors.red, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: IFColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyTextAction extends StatelessWidget {
  const _TinyTextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: IFColors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: IFColors.red.withValues(alpha: 0.26)),
        ),
        child: Text(
          label,
          style:
              const TextStyle(color: IFColors.red, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

extension _WeightFormat on num {
  String get g => this % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(2);
}
