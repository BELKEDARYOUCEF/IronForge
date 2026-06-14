import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_chip.dart';
import '../../../shared/widgets/forge_primary_button.dart';
import '../../../shared/widgets/forge_section_header.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../data/user_profile_repository.dart';
import '../domain/user_profile.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String goal = 'Strength';
  String level = 'Intermediate';
  String units = 'kg';
  int frequency = 4;
  String trainingType = 'PPL';

  @override
  Widget build(BuildContext context) {
    return ForgeShell(
      title: 'Setup',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          const Text('Forge your setup', style: IFText.hero),
          const SizedBox(height: 8),
          const Text('Choose the baseline. You can edit it anytime.',
              style: IFText.bodyMuted),
          const SizedBox(height: 20),
          _ChoiceGroup(
              label: 'Goal',
              value: goal,
              values: const [
                'Strength',
                'Hypertrophy',
                'Powerbuilding',
                'Fat Loss'
              ],
              onChanged: (value) => setState(() => goal = value)),
          _ChoiceGroup(
              label: 'Level',
              value: level,
              values: const ['Beginner', 'Intermediate', 'Advanced'],
              onChanged: (value) => setState(() => level = value)),
          _ChoiceGroup(
              label: 'Units',
              value: units,
              values: const ['kg', 'lbs'],
              onChanged: (value) => setState(() => units = value)),
          _FrequencyPicker(
              value: frequency,
              onChanged: (value) => setState(() => frequency = value)),
          _ChoiceGroup(
              label: 'Training type',
              value: trainingType,
              values: const ['PPL', 'Upper/Lower', 'Full Body', 'Bro Split'],
              onChanged: (value) => setState(() => trainingType = value)),
          const SizedBox(height: 20),
          ForgePrimaryButton(
            label: 'FINISH SETUP',
            icon: Icons.check_rounded,
            onPressed: () async {
              await ref.read(userProfileRepositoryProvider).saveProfile(
                    UserProfile(
                        goal: goal,
                        level: level,
                        units: units,
                        frequencyPerWeek: frequency,
                        trainingType: trainingType),
                  );
              ref.invalidate(userProfileProvider);
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  const _ChoiceGroup(
      {required this.label,
      required this.value,
      required this.values,
      required this.onChanged});

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ForgeSectionHeader(title: label),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in values)
                ForgeChip(
                    label: item,
                    selected: value == item,
                    onTap: () => onChanged(item)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FrequencyPicker extends StatelessWidget {
  const _FrequencyPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: ForgeCard(
        child: Row(
          children: [
            const Expanded(
                child: Text('Training days per week', style: IFText.cardTitle)),
            IconButton(
                onPressed: () => onChanged((value - 1).clamp(3, 6)),
                icon: const Icon(Icons.remove_rounded)),
            Text('$value', style: IFText.h2),
            IconButton(
                onPressed: () => onChanged((value + 1).clamp(3, 6)),
                icon: const Icon(Icons.add_rounded)),
          ],
        ),
      ),
    );
  }
}
