import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_theme.dart';
import '../../../shared/widgets/forge_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ForgeShell(
      title: 'IronForge',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Forge today. Beat last week.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const Text(
            'Last bench: 100 kg x 8. PR range: 102.5 kg x 8.',
            style: TextStyle(color: forgeSteel, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/workout'),
            child: const Text('START WORKOUT'),
          ),
          const SizedBox(height: 16),
          _StatGrid(),
          const SizedBox(height: 16),
          const _NavTile(label: 'Progress', route: '/progress'),
          const _NavTile(label: 'Exercise Library', route: '/exercises'),
          const _NavTile(label: 'Routines', route: '/routines'),
          const _NavTile(label: 'Premium', route: '/premium'),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: const [
        _StatCard(label: 'Streak', value: '6 days'),
        _StatCard(label: 'Week Volume', value: '18.4t'),
        _StatCard(label: 'PRs', value: '3'),
        _StatCard(label: 'Consistency', value: '91%'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(color: forgeSteel)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(route),
      ),
    );
  }
}
