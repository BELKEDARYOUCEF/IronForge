import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/sample_data.dart';
import '../../../shared/widgets/forge_shell.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ForgeShell(
      title: 'Exercises',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search 1000+ exercises'),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('Barbell')),
              Chip(label: Text('Chest')),
              Chip(label: Text('Back')),
              Chip(label: Text('Favorites')),
            ],
          ),
          const SizedBox(height: 12),
          for (final exercise in sampleExercises)
            Card(
              child: ListTile(
                leading: Icon(exercise.isFavorite ? Icons.star : Icons.fitness_center, color: forgeElectric),
                title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${exercise.primaryMuscle} • ${exercise.equipment}'),
                trailing: const Icon(Icons.play_circle_outline),
              ),
            ),
        ],
      ),
    );
  }
}
