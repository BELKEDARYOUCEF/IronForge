import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
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
        padding: const EdgeInsets.all(16),
        children: [
          ForgeCard(
            glow: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('IronForge Pro', style: IFText.hero),
                const SizedBox(height: 8),
                const Text('Premium systems are coming after the local app is fully battle-tested.', style: IFText.bodyMuted),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: IFColors.red.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
                  child: const Text('COMING SOON', style: TextStyle(color: IFColors.red, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ForgeCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(feature.$2, color: IFColors.red),
                  title: Text(feature.$1, style: IFText.cardTitle),
                  trailing: const Text('Coming soon', style: TextStyle(color: IFColors.textFaint)),
                ),
              ),
            ),
          const SizedBox(height: 10),
          const ElevatedButton(onPressed: null, child: Text('JOIN WAITLIST')),
        ],
      ),
    );
  }
}
