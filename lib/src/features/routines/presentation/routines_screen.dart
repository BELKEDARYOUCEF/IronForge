import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_theme.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../data/routine_repository.dart';
import '../domain/routine.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);

    return ForgeShell(
      title: 'Routines',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            onPressed: () => _showRoutineDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('BUILD CUSTOM ROUTINE'),
          ),
          const SizedBox(height: 12),
          routines.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => Text('Routines unavailable: $error'),
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text('Create your first routine.', style: TextStyle(color: forgeSteel)),
                  ),
                );
              }

              return Column(
                children: [
                  for (final routine in items)
                    Card(
                      child: ListTile(
                        title: Text(routine.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text('${routine.daysPerWeek} days/week • ${routine.progressionLabel}'),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (action) async {
                            if (action == 'edit') {
                              await _showRoutineDialog(context, ref, routine: routine);
                            } else if (action == 'delete') {
                              await ref.read(routineRepositoryProvider).deleteRoutine(routine.id);
                              ref.invalidate(routinesProvider);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
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

  Future<void> _showRoutineDialog(BuildContext context, WidgetRef ref, {Routine? routine}) async {
    final nameController = TextEditingController(text: routine?.name ?? '');
    final daysController = TextEditingController(text: '${routine?.daysPerWeek ?? 3}');
    final stepController = TextEditingController(text: '${routine?.progressionStepKg ?? 2.5}');
    final notesController = TextEditingController(text: routine?.notes ?? '');

    final saved = await showDialog<Routine>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(routine == null ? 'New routine' : 'Edit routine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Days per week'),
              ),
              TextField(
                controller: stepController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Progression step kg'),
              ),
              TextField(
                controller: notesController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(
                  context,
                  Routine(
                    id: routine?.id ?? const Uuid().v4(),
                    name: name,
                    daysPerWeek: int.tryParse(daysController.text) ?? 3,
                    progressionStepKg: double.tryParse(stepController.text) ?? 2.5,
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
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
    daysController.dispose();
    stepController.dispose();
    notesController.dispose();

    if (saved != null) {
      await ref.read(routineRepositoryProvider).saveRoutine(saved);
      ref.invalidate(routinesProvider);
    }
  }
}
