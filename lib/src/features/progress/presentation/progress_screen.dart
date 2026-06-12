import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/sample_data.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../domain/progress_stats.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = ProgressStats(sampleHistory);

    return ForgeShell(
      title: 'Progress',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProgressCard(label: 'Total volume', value: '${(stats.totalVolume / 1000).toStringAsFixed(1)}t'),
          _ProgressCard(label: 'Completed sets', value: '${stats.totalSets}'),
          _ProgressCard(label: 'Bench E1RM', value: '${stats.bestE1rmFor('bench_press').toStringAsFixed(1)} kg'),
          const SizedBox(height: 12),
          const Text('Strength Curve', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            height: 180,
            decoration: BoxDecoration(color: forgePanel, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: const Text('fl_chart line chart goes here', style: TextStyle(color: forgeSteel)),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(color: forgeSteel)),
        trailing: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

