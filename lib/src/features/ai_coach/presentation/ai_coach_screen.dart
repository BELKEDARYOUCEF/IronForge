import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_primary_button.dart';
import '../../../shared/widgets/forge_shell.dart';

class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ForgeShell(
      title: 'AI Coach',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          ForgeCard(
            glow: true,
            borderColor: IFColors.blue,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_alt_rounded, color: IFColors.blue),
                    SizedBox(width: 8),
                    Text('INSIGHT', style: IFText.label),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                    'Your bench press has been stuck for 3 weeks. Consider a deload or variation.',
                    style: IFText.h3),
                const SizedBox(height: 14),
                ForgePrimaryButton(
                  label: 'VIEW RECOMMENDATION',
                  icon: Icons.auto_awesome_rounded,
                  height: 46,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const ForgeCard(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('RECOVERY', style: IFText.label)),
                    _ComingSoonPill(),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('82%',
                        style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: IFColors.green)),
                    SizedBox(width: 10),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Good to go', style: IFText.h3),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _ComingSoonRow(icon: Icons.bedtime_rounded, label: 'Sleep'),
                _ComingSoonRow(icon: Icons.monitor_heart_rounded, label: 'HRV'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const ForgeCard(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VOLUME ANALYSIS', style: IFText.label),
                SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MiniBar(height: 40),
                    _MiniBar(height: 62),
                    _MiniBar(height: 84),
                    _MiniBar(height: 58),
                    _MiniBar(height: 74),
                    _MiniBar(height: 48),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                    'High volume on legs. Consider reducing leg volume by 15%.',
                    style: IFText.bodyMuted),
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
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: IFColors.panel2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IFColors.borderSoft),
      ),
      child: Row(
        children: [
          Icon(icon, color: IFColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: IFText.cardTitle)),
          const Text('Coming soon',
              style: TextStyle(
                  color: IFColors.textFaint, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ComingSoonPill extends StatelessWidget {
  const _ComingSoonPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: IFColors.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: IFColors.blue.withValues(alpha: 0.25)),
      ),
      child: const Text(
        'COMING SOON',
        style: TextStyle(
            color: IFColors.blue, fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: height,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [IFColors.redGlow, IFColors.redDark],
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
