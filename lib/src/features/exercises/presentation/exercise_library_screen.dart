import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_empty_state.dart';
import '../../../shared/widgets/forge_primary_button.dart';
import '../../../shared/widgets/forge_section_header.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String query = '';
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);

    return ForgeShell(
      title: 'Exercises',
      actions: [
        IconButton(
          onPressed: () => _showExerciseDialog(context),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: Icon(Icons.tune_rounded),
              labelText: 'Search exercises...',
            ),
            onChanged: (value) =>
                setState(() => query = value.trim().toLowerCase()),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in const [
                'All',
                'Chest',
                'Back',
                'Legs',
                'Shoulders',
                'Favorites',
                'Custom'
              ])
                ForgeChip(
                  label: item,
                  selected: filter == item,
                  onTap: () => setState(() => filter = item),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const ForgeSectionHeader(title: 'Equipment'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: const [
              _EquipmentTile(
                  label: 'Barbell', icon: Icons.fitness_center_rounded),
              _EquipmentTile(
                  label: 'Dumbbell', icon: Icons.sports_gymnastics_rounded),
              _EquipmentTile(
                  label: 'Machine',
                  icon: Icons.precision_manufacturing_rounded),
              _EquipmentTile(label: 'Cable', icon: Icons.cable_rounded),
              _EquipmentTile(
                  label: 'Bodyweight', icon: Icons.accessibility_new_rounded),
            ],
          ),
          const SizedBox(height: 16),
          ForgePrimaryButton(
            label: 'CUSTOM EXERCISE',
            icon: Icons.add_rounded,
            height: 48,
            onPressed: () => _showExerciseDialog(context),
          ),
          const SizedBox(height: 16),
          exercises.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => Text('Exercises unavailable: $error'),
            data: (items) {
              final visible = items.where(_matches).toList();
              if (visible.isEmpty) {
                return const ForgeEmptyState(
                    icon: Icons.search_rounded,
                    title: 'No exercises found.',
                    message: 'Adjust filters or create a custom exercise.');
              }

              return Column(
                children: [
                  for (final exercise in visible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ExerciseRow(
                        exercise: exercise,
                        icon: _equipmentIcon(exercise.equipment),
                        onFavorite: () async {
                          await ref
                              .read(exerciseRepositoryProvider)
                              .toggleFavorite(exercise);
                          ref.invalidate(exercisesProvider);
                        },
                        onEdit: exercise.isCustom
                            ? () =>
                                _showExerciseDialog(context, exercise: exercise)
                            : null,
                        onDelete: exercise.isCustom
                            ? () async {
                                await ref
                                    .read(exerciseRepositoryProvider)
                                    .deleteExercise(exercise.id);
                                ref.invalidate(exercisesProvider);
                              }
                            : null,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  bool _matches(Exercise exercise) {
    final textMatch = query.isEmpty ||
        exercise.name.toLowerCase().contains(query) ||
        exercise.primaryMuscle.toLowerCase().contains(query) ||
        exercise.equipment.toLowerCase().contains(query);

    final filterMatch = switch (filter) {
      'Chest' => exercise.primaryMuscle == 'Chest',
      'Back' => exercise.primaryMuscle == 'Back',
      'Legs' => ['Quads', 'Hamstrings', 'Glutes', 'Legs']
          .contains(exercise.primaryMuscle),
      'Shoulders' => exercise.primaryMuscle == 'Shoulders',
      'Favorites' => exercise.isFavorite,
      'Custom' => exercise.isCustom,
      _ => true,
    };

    return textMatch && filterMatch;
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

  Future<void> _showExerciseDialog(BuildContext context,
      {Exercise? exercise}) async {
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final muscleController =
        TextEditingController(text: exercise?.primaryMuscle ?? '');
    final equipmentController =
        TextEditingController(text: exercise?.equipment ?? '');

    final saved = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IFColors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
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
                  Expanded(
                      child: Text(
                          exercise == null
                              ? 'Custom Exercise'
                              : 'Edit Exercise',
                          style: IFText.h2)),
                  const Icon(Icons.fitness_center_rounded, color: IFColors.red),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 10),
              TextField(
                  controller: muscleController,
                  decoration:
                      const InputDecoration(labelText: 'Primary muscle')),
              const SizedBox(height: 10),
              TextField(
                  controller: equipmentController,
                  decoration: const InputDecoration(labelText: 'Equipment')),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ForgePrimaryButton(
                      label: 'SAVE',
                      icon: Icons.check_rounded,
                      height: 46,
                      onPressed: () {
                        final name = nameController.text.trim();
                        final muscle = muscleController.text.trim();
                        final equipment = equipmentController.text.trim();
                        if (name.isEmpty ||
                            muscle.isEmpty ||
                            equipment.isEmpty) {
                          return;
                        }
                        Navigator.pop(
                          context,
                          Exercise(
                            id: exercise?.id ?? const Uuid().v4(),
                            name: name,
                            primaryMuscle: muscle,
                            equipment: equipment,
                            isFavorite: exercise?.isFavorite ?? false,
                            isCustom: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    nameController.dispose();
    muscleController.dispose();
    equipmentController.dispose();

    if (saved != null) {
      await ref.read(exerciseRepositoryProvider).saveExercise(saved);
      ref.invalidate(exercisesProvider);
    }
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.icon,
    required this.onFavorite,
    this.onEdit,
    this.onDelete,
  });

  final Exercise exercise;
  final IconData icon;
  final VoidCallback onFavorite;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: IFColors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: IFColors.red.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: IFColors.red, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(exercise.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: IFText.cardTitle)),
                    if (exercise.isCustom)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: IFColors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: IFColors.red.withValues(alpha: 0.25)),
                        ),
                        child: const Text('CUSTOM',
                            style: TextStyle(
                                color: IFColors.red,
                                fontSize: 9,
                                fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${exercise.equipment} • ${exercise.primaryMuscle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: IFText.bodyMuted),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              exercise.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: exercise.isFavorite ? IFColors.gold : IFColors.textMuted,
            ),
            onPressed: onFavorite,
          ),
          if (exercise.isCustom)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (action) {
                if (action == 'edit') {
                  onEdit?.call();
                } else if (action == 'delete') {
                  onDelete?.call();
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
}

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: IFColors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: IFColors.red.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, color: IFColors.red, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: IFText.cardTitle)),
        ],
      ),
    );
  }
}
