import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../shared/widgets/forge_shell.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const features = [
      'Unlimited workout history',
      'Advanced analytics and AI insights',
      'Cloud sync across devices',
      'CSV, Health, Fit, and Strava export',
      'Custom themes and widgets',
      'PR Hunter notifications',
    ];

    return ForgeShell(
      title: 'IronForge Pro',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Unlock the full forge.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('\$6.99/mo or \$49.99/year', style: TextStyle(color: forgeSteel)),
          const SizedBox(height: 20),
          for (final feature in features) _PremiumLine(text: feature),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text('START PRO')),
        ],
      ),
    );
  }
}

class _PremiumLine extends StatelessWidget {
  const _PremiumLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: forgeElectric),
      title: Text(text),
    );
  }
}
