import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../core/if_text_styles.dart';
import 'forge_card.dart';
import 'forge_primary_button.dart';

Future<void> showPrCelebration(BuildContext context) async {
  HapticFeedback.heavyImpact();
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ForgeCard(
        glow: true,
        borderColor: IFColors.gold,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: IFColors.gold.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(color: IFColors.gold.withValues(alpha: 0.38)),
              ),
              child: const Icon(Icons.emoji_events_rounded, color: IFColors.gold, size: 34),
            ),
            const SizedBox(height: 14),
            const Text('PR FORGED', style: IFText.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
              'New estimated max unlocked. Keep lifting.',
              style: IFText.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ForgePrimaryButton(
              label: 'LOCK IT IN',
              icon: Icons.check_rounded,
              height: 46,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ),
  );
}
