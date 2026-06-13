import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_theme.dart';
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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search exercises'),
            onChanged: (value) => setState(() => query = value.trim().toLowerCase()),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final item in const ['All', 'Barbell', 'Chest', 'Back', 'Favorites', 'Custom'])
                ChoiceChip(
                  label: Text(item),
                  selected: filter == item,
                  onSelected: (_) => setState(() => filter = item),
                ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showExerciseDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add custom exercise'),
          ),
          const SizedBox(height: 12),
          exercises.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => Text('Exercises unavailable: $error'),
            data: (items) {
              final visible = items.where(_matches).toList();
              if (visible.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: Text('No exercises found.', style: TextStyle(color: forgeSteel))),
                );
              }

              return Column(
                children: [
                  for (final exercise in visible)
                    Card(
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(exercise.isFavorite ? Icons.star : Icons.star_border, color: forgeElectric),
                          onPressed: () async {
                            await ref.read(exerciseRepositoryProvider).toggleFavorite(exercise);
                            ref.invalidate(exercisesProvider);
                          },
                        ),
                        title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('${exercise.primaryMuscle} • ${exercise.equipment}${exercise.isCustom ? ' • Custom' : ''}'),
                        trailing: exercise.isCustom
                            ? PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
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
                              )
                            : const Icon(Icons.fitness_center),
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
      'Barbell' => exercise.equipment == 'Barbell',
      'Chest' => exercise.primaryMuscle == 'Chest',
      'Back' => exercise.primaryMuscle == 'Back',
      'Favorites' => exercise.isFavorite,
      'Custom' => exercise.isCustom,
      _ => true,
    };

    return textMatch && filterMatch;
  }

  Future<void> _showExerciseDialog(BuildContext context, {Exercise? exercise}) async {
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final muscleController = TextEditingController(text: exercise?.primaryMuscle ?? '');
    final equipmentController = TextEditingController(text: exercise?.equipment ?? '');

    final saved = await showDialog<Exercise>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(exercise == null ? 'Custom exercise' : 'Edit exercise'),
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
        );
      },
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
