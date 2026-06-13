import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  String trainingType = 'Powerbuilding';

  @override
  Widget build(BuildContext context) {
    return ForgeShell(
      title: 'Setup',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DropdownSetting(label: 'Goal', value: goal, values: const ['Strength', 'Hypertrophy', 'Fat loss', 'General fitness'], onChanged: (value) => setState(() => goal = value)),
          _DropdownSetting(label: 'Level', value: level, values: const ['Beginner', 'Intermediate', 'Advanced'], onChanged: (value) => setState(() => level = value)),
          _DropdownSetting(label: 'Units', value: units, values: const ['kg', 'lbs'], onChanged: (value) => setState(() => units = value)),
          StepperSetting(
            label: 'Training days per week',
            value: frequency,
            onChanged: (value) => setState(() => frequency = value.clamp(1, 7)),
          ),
          _DropdownSetting(label: 'Training type', value: trainingType, values: const ['Powerbuilding', 'Bodybuilding', 'Powerlifting', 'General strength'], onChanged: (value) => setState(() => trainingType = value)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await ref.read(userProfileRepositoryProvider).saveProfile(
                    UserProfile(
                      goal: goal,
                      level: level,
                      units: units,
                      frequencyPerWeek: frequency,
                      trainingType: trainingType,
                    ),
                  );
              ref.invalidate(userProfileProvider);
              if (context.mounted) context.go('/');
            },
            child: const Text('Save setup'),
          ),
        ],
      ),
    );
  }
}

class _DropdownSetting extends StatelessWidget {
  const _DropdownSetting({required this.label, required this.value, required this.values, required this.onChanged});

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final item in values) DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class StepperSetting extends StatelessWidget {
  const StepperSetting({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: () => onChanged(value - 1), icon: const Icon(Icons.remove)),
            Text('$value'),
            IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add)),
          ],
        ),
      ),
    );
  }
}
