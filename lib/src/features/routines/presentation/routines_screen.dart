import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_spacing.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_empty_state.dart';
import '../../../shared/widgets/forge_primary_button.dart';
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
      actions: [
        IconButton(
          onPressed: () => _showRoutineDialog(context, ref),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in const ['My Programs', 'Explore'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ForgeChip(
                      label: item,
                      selected: tab == item,
                      onTap: () => setState(() => tab = item),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: IFSpacing.spacingBlock),
          if (tab == 'Explore') ...[
            for (final program in _explorePrograms)
              Padding(
                padding:
                    const EdgeInsets.only(bottom: IFSpacing.spacingBlock),
                child: _ProgramCard(program: program),
              ),
          ] else ...[
            ForgePrimaryButton(
              label: 'BUILD CUSTOM PROGRAM',
              icon: Icons.add_rounded,
              height: 46,
              onPressed: () => _showRoutineDialog(context, ref),
            ),
            const SizedBox(height: IFSpacing.spacingBlock),
            routines.when(
              loading: () =>
                  const LinearProgressIndicator(color: IFColors.red),
              error: (error, stackTrace) =>
                  Text('Programs unavailable: $error'),
              data: (items) {
                if (items.isEmpty) {
                  return ForgeEmptyState(
                    icon: Icons.rocket_launch_rounded,
                    title: 'Create your first program.',
                    message:
                        'Build a routine with progression rules and keep it offline.',
                    action: ForgePrimaryButton(
                      label: 'NEW PROGRAM',
                      icon: Icons.add_rounded,
                      onPressed: () => _showRoutineDialog(context, ref),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final routine in items)
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: IFSpacing.spacingBlock),
                        child: _RoutineCard(
                          routine: routine,
                          onEdit: () => _showRoutineDialog(context, ref,
                              routine: routine),
                          onDelete: () async {
                            await ref
                                .read(routineRepositoryProvider)
                                .deleteRoutine(routine.id);
                            ref.invalidate(routinesProvider);
                          },
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

  Future<void> _showRoutineDialog(BuildContext context, WidgetRef ref,
      {Routine? routine}) async {
    final nameController = TextEditingController(text: routine?.name ?? '');
    final daysController =
        TextEditingController(text: '${routine?.daysPerWeek ?? 3}');
    final stepController =
        TextEditingController(text: '${routine?.progressionStepKg ?? 2.5}');
    final notesController = TextEditingController(text: routine?.notes ?? '');

    final saved = await showModalBottomSheet<Routine>(
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
                          routine == null ? 'New Program' : 'Edit Program',
                          style: IFText.h2)),
                  const Icon(Icons.rocket_launch_rounded, color: IFColors.red),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 10),
              TextField(
                  controller: daysController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Days per week')),
              const SizedBox(height: 10),
              TextField(
                  controller: stepController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Progression step kg')),
              const SizedBox(height: 10),
              TextField(
                  controller: notesController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes')),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CANCEL'))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ForgePrimaryButton(
                      label: 'SAVE',
                      icon: Icons.check_rounded,
                      height: 46,
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        Navigator.pop(
                          context,
                          Routine(
                            id: routine?.id ?? const Uuid().v4(),
                            name: name,
                            daysPerWeek:
                                int.tryParse(daysController.text) ?? 3,
                            progressionStepKg:
                                double.tryParse(stepController.text) ?? 2.5,
                            notes: notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
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
    daysController.dispose();
    stepController.dispose();
    notesController.dispose();

    if (saved != null) {
      await ref.read(routineRepositoryProvider).saveRoutine(saved);
      ref.invalidate(routinesProvider);
    }
  }
}

const _explorePrograms = [
  _ExploreProgram(
      'PPL 6 Day Split',
      'Intermediate · 6 days/week',
      'POPULAR',
      Icons.local_fire_department_rounded,
      [IFColors.redDark, IFColors.panel, IFColors.black]),
  _ExploreProgram(
      '5x5 Strength',
      'Beginner · 3 days/week',
      'STRENGTH',
      Icons.fitness_center_rounded,
      [IFColors.panel3, IFColors.redDark, IFColors.black]),
  _ExploreProgram(
      'Upper / Lower',
      'Intermediate · 4 days/week',
      'BALANCED',
      Icons.swap_vert_rounded,
      [IFColors.blue, IFColors.panel, IFColors.black]),
  _ExploreProgram(
      'Bro Split',
      'Advanced · 5 days/week',
      'VOLUME',
      Icons.emoji_events_rounded,
      [IFColors.gold, IFColors.redDark, IFColors.black]),
];

class _ExploreProgram {
  const _ExploreProgram(
      this.title, this.subtitle, this.badge, this.icon, this.colors);

  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final List<Color> colors;
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});

  final _ExploreProgram program;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(IFSpacing.paddingCard),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(IFSpacing.radiusCard),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: program.colors),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: Icon(program.icon, color: IFColors.text, size: 28),
            ),
            const SizedBox(width: IFSpacing.spacingBlock),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(program.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: IFText.h2)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: IFColors.black.withValues(alpha: 0.32),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(program.badge,
                            style: const TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(program.subtitle, style: IFText.bodyMuted),
                  const SizedBox(height: 6),
                  const ForgeChip(
                      label: 'Auto progression',
                      icon: Icons.auto_awesome_rounded),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.star_border_rounded, color: IFColors.gold),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.onEdit,
    required this.onDelete,
  });

  final Routine routine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      padding: const EdgeInsets.all(IFSpacing.paddingCard),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [IFColors.red, IFColors.redDark]),
              borderRadius: BorderRadius.circular(IFSpacing.radiusInput),
            ),
            child: const Icon(Icons.rocket_launch_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: IFSpacing.spacingBlock),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(routine.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: IFText.cardTitle),
                const SizedBox(height: 3),
                Text(
                    '${routine.daysPerWeek} days/week · ${routine.progressionLabel}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: IFText.micro),
                if (routine.notes != null) ...[
                  const SizedBox(height: 3),
                  Text(routine.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: IFText.bodyMuted),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_border_rounded,
              color: IFColors.gold, size: 22),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            onSelected: (action) {
              if (action == 'edit') {
                onEdit();
              } else if (action == 'delete') {
                onDelete();
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
