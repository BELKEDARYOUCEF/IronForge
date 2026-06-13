import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_empty_state.dart';
import '../../../shared/widgets/forge_section_header.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String query = '';
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);

    return ForgeShell(
      title: 'Exercises',
      actions: [IconButton(onPressed: () => _showExerciseDialog(context), icon: const Icon(Icons.add_rounded))],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), suffixIcon: Icon(Icons.tune_rounded), labelText: 'Search exercises...'),
            onChanged: (value) => setState(() => query = value.trim().toLowerCase()),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in const ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Favorites', 'Custom'])
                ForgeChip(label: item, selected: filter == item, onTap: () => setState(() => filter = item)),
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
              _EquipmentTile(label: 'Barbell', icon: Icons.fitness_center_rounded),
              _EquipmentTile(label: 'Dumbbell', icon: Icons.sports_gymnastics_rounded),
              _EquipmentTile(label: 'Machine', icon: Icons.precision_manufacturing_rounded),
              _EquipmentTile(label: 'Cable', icon: Icons.cable_rounded),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: () => _showExerciseDialog(context), icon: const Icon(Icons.add_rounded), label: const Text('CUSTOM EXERCISE')),
          const SizedBox(height: 14),
          exercises.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => Text('Exercises unavailable: $error'),
            data: (items) {
              final visible = items.where(_matches).toList();
              if (visible.isEmpty) {
                return const ForgeEmptyState(icon: Icons.search_rounded, title: 'No exercises found.', message: 'Adjust filters or create a custom exercise.');
              }

              return Column(
                children: [
                  for (final exercise in visible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ForgeCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(_equipmentIcon(exercise.equipment), color: IFColors.red),
                          title: Text(exercise.name, style: IFText.cardTitle),
                          subtitle: Text('${exercise.primaryMuscle} • ${exercise.equipment}${exercise.isCustom ? ' • Custom' : ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(exercise.isFavorite ? Icons.star_rounded : Icons.star_border_rounded, color: exercise.isFavorite ? IFColors.gold : IFColors.textMuted),
                                onPressed: () async {
                                  await ref.read(exerciseRepositoryProvider).toggleFavorite(exercise);
                                  ref.invalidate(exercisesProvider);
                                },
                              ),
                              if (exercise.isCustom)
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded),
                                  onSelected: (action) async {
                                    if (action == 'edit') {
                                      await _showExerciseDialog(context, exercise: exercise);
                                    } else if (action == 'delete') {
                                      await ref.read(exerciseRepositoryProvider).deleteExercise(exercise.id);
                                      ref.invalidate(exercisesProvider);
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
      'Legs' => ['Quads', 'Hamstrings', 'Glutes', 'Legs'].contains(exercise.primaryMuscle),
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

  Future<void> _showExerciseDialog(BuildContext context, {Exercise? exercise}) async {
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final muscleController = TextEditingController(text: exercise?.primaryMuscle ?? '');
    final equipmentController = TextEditingController(text: exercise?.equipment ?? '');

    final saved = await showDialog<Exercise>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise == null ? 'Custom Exercise' : 'Edit Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: muscleController, decoration: const InputDecoration(labelText: 'Primary muscle')),
            TextField(controller: equipmentController, decoration: const InputDecoration(labelText: 'Equipment')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final muscle = muscleController.text.trim();
              final equipment = equipmentController.text.trim();
              if (name.isEmpty || muscle.isEmpty || equipment.isEmpty) return;
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
            child: const Text('Save'),
          ),
        ],
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

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      child: Row(
        children: [
          Icon(icon, color: IFColors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: IFText.cardTitle)),
        ],
      ),
    );
  }
}
