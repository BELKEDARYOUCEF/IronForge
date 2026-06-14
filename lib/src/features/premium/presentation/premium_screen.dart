import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_spacing.dart';
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
            padding: const EdgeInsets.all(IFSpacing.paddingCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('IronForge Pro', style: IFText.hero),
                const SizedBox(height: 8),
                const Text(
                    'Premium systems are coming after the local app is fully battle-tested.',
                    style: IFText.bodyMuted),
                const SizedBox(height: IFSpacing.spacingBlock),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: IFColors.red.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: IFColors.red.withValues(alpha: 0.28),
                        width: IFSpacing.borderWidth),
                  ),
                  child: const Text('COMING SOON',
                      style: TextStyle(
                          color: IFColors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6)),
                ),
              ],
            ),
          ),
          const SizedBox(height: IFSpacing.spacingBlock),
          for (final feature in features)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: IFSpacing.spacingBlock),
              child: _PremiumFeatureRow(label: feature.$1, icon: feature.$2),
            ),
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
      padding: const EdgeInsets.all(IFSpacing.paddingCard),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: IFColors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(IFSpacing.radiusInput),
              border: Border.all(
                  color: IFColors.red.withValues(alpha: 0.24),
                  width: IFSpacing.borderWidth),
            ),
            child: Icon(icon, color: IFColors.red, size: 19),
          ),
          const SizedBox(width: IFSpacing.spacingBlock),
          Expanded(child: Text(label, style: IFText.cardTitle)),
          const Text('Coming soon',
              style: TextStyle(
                  color: IFColors.textFaint, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
