import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_shell.dart';

class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ForgeShell(
      title: 'AI Coach',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ForgeCard(
            glow: true,
            borderColor: IFColors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.psychology_alt_rounded, color: IFColors.blue), SizedBox(width: 8), Text('INSIGHT', style: IFText.label)]),
                const SizedBox(height: 12),
                const Text('Your bench press has been stuck for 3 weeks. Consider a deload or variation.', style: IFText.h3),
                const SizedBox(height: 14),
                ElevatedButton(onPressed: () {}, child: const Text('VIEW RECOMMENDATION')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const ForgeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RECOVERY', style: IFText.label),
                SizedBox(height: 10),
                Text('82%', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: IFColors.green)),
                Text('Good to go', style: IFText.h3),
                SizedBox(height: 10),
                _ComingSoonRow(icon: Icons.bedtime_rounded, label: 'Sleep'),
                _ComingSoonRow(icon: Icons.monitor_heart_rounded, label: 'HRV'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const ForgeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VOLUME ANALYSIS', style: IFText.label),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MiniBar(height: 40),
                    _MiniBar(height: 62),
                    _MiniBar(height: 84),
                    _MiniBar(height: 58),
                    _MiniBar(height: 74),
                  ],
                ),
                SizedBox(height: 14),
                Text('High volume on legs. Consider reducing leg volume by 15%.', style: IFText.bodyMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonRow extends StatelessWidget {
  const _ComingSoonRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: IFColors.textMuted),
      title: Text(label),
      trailing: const Text('Coming soon', style: TextStyle(color: IFColors.textFaint)),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(width: 34, height: height, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: IFColors.red, borderRadius: BorderRadius.circular(6)));
  }
}
