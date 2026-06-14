import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_primary_button.dart';
import '../../../shared/widgets/forge_shell.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const features = [
      ('Cloud Sync', Icons.cloud_sync_rounded),
      ('Advanced Analytics', Icons.query_stats_rounded),
      ('AI Coach', Icons.psychology_alt_rounded),
      ('Progress Photos', Icons.photo_camera_back_rounded),
      ('CSV Export', Icons.file_download_rounded),
      ('Wearables', Icons.watch_rounded),
    ];

    return ForgeShell(
      title: 'IronForge Pro',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          ForgeCard(
            glow: true,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('IronForge Pro', style: IFText.hero),
                const SizedBox(height: 8),
                const Text(
                    'Premium systems are coming after the local app is fully battle-tested.',
                    style: IFText.bodyMuted),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: IFColors.red.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border:
                        Border.all(color: IFColors.red.withValues(alpha: 0.28)),
                  ),
                  child: const Text('COMING SOON',
                      style: TextStyle(
                          color: IFColors.red, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PremiumFeatureRow(label: feature.$1, icon: feature.$2),
            ),
          const SizedBox(height: 10),
          const ForgePrimaryButton(
              label: 'JOIN WAITLIST',
              icon: Icons.lock_rounded,
              onPressed: null),
        ],
      ),
    );
  }
}

class _PremiumFeatureRow extends StatelessWidget {
  const _PremiumFeatureRow({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: IFColors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: IFColors.red.withValues(alpha: 0.24)),
            ),
            child: Icon(icon, color: IFColors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: IFText.cardTitle)),
          const Text('Coming soon',
              style: TextStyle(
                  color: IFColors.textFaint, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
