import 'package:flutter/material.dart';

import '../../../shared/widgets/forge_shell.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const routines = ['Push Pull Legs', 'Upper Lower', 'Strong 5x5', 'Powerbuilding', 'Bro Split'];

    return ForgeShell(
      title: 'Routines',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('BUILD CUSTOM ROUTINE'),
          ),
          const SizedBox(height: 12),
          for (final routine in routines)
            Card(
              child: ListTile(
                title: Text(routine, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Auto progression ready'),
                trailing: const Icon(Icons.drag_indicator),
              ),
            ),
        ],
      ),
    );
  }
}

