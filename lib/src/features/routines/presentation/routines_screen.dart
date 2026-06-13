import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_empty_state.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../data/routine_repository.dart';
import '../domain/routine.dart';

class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen> {
  String tab = 'My Programs';

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routinesProvider);

    return ForgeShell(
      title: 'Programs',
      actions: [IconButton(onPressed: () => _showRoutineDialog(context, ref), icon: const Icon(Icons.add_rounded))],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final item in const ['My Programs', 'Explore']) ForgeChip(label: item, selected: tab == item, onTap: () => setState(() => tab = item)),
            ],
          ),
          const SizedBox(height: 16),
          if (tab == 'Explore') ...[
            for (final program in const [
              ('PPL 6 Day Split', 'Intermediate • 6 days/week', Icons.local_fire_department_rounded),
              ('5x5 Strength', 'Beginner • 3 days/week', Icons.fitness_center_rounded),
              ('Upper / Lower', 'Intermediate • 4 days/week', Icons.swap_vert_rounded),
              ('Bro Split', 'All levels • 5 days/week', Icons.emoji_events_rounded),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProgramCard(title: program.$1, subtitle: program.$2, icon: program.$3),
              ),
          ] else ...[
            ElevatedButton.icon(onPressed: () => _showRoutineDialog(context, ref), icon: const Icon(Icons.add_rounded), label: const Text('BUILD CUSTOM PROGRAM')),
            const SizedBox(height: 12),
            routines.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) => Text('Programs unavailable: $error'),
              data: (items) {
                if (items.isEmpty) {
                  return ForgeEmptyState(
                    icon: Icons.rocket_launch_rounded,
                    title: 'Create your first program.',
                    message: 'Build a routine with progression rules and keep it offline.',
                    action: OutlinedButton.icon(onPressed: () => _showRoutineDialog(context, ref), icon: const Icon(Icons.add_rounded), label: const Text('NEW PROGRAM')),
                  );
                }

                return Column(
                  children: [
                    for (final routine in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ForgeCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [IFColors.redDark, IFColors.black2]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.rocket_launch_rounded, color: IFColors.text),
                            ),
                            title: Text(routine.name, style: IFText.cardTitle),
                            subtitle: Text('${routine.daysPerWeek} days/week • ${routine.progressionLabel}'),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded),
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
                      ),
                  ],
                );
              },
            ),
          ],
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
      builder: (context) => AlertDialog(
        title: Text(routine == null ? 'New Program' : 'Edit Program'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: daysController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Days per week')),
            TextField(controller: stepController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Progression step kg')),
            TextField(controller: notesController, minLines: 1, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
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
      ),
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

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: 132,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [IFColors.redDark, IFColors.panel, IFColors.black]),
        ),
        child: Row(
          children: [
            Icon(icon, color: IFColors.text, size: 42),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: IFText.h2),
                  const SizedBox(height: 6),
                  Text(subtitle, style: IFText.bodyMuted),
                  const SizedBox(height: 8),
                  const ForgeChip(label: 'Auto progression', icon: Icons.auto_awesome_rounded),
                ],
              ),
            ),
            const Icon(Icons.star_border_rounded, color: IFColors.gold),
          ],
        ),
      ),
    );
  }
}
