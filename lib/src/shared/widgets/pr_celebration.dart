import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../core/if_text_styles.dart';

Future<void> showPrCelebration(BuildContext context) async {
  HapticFeedback.heavyImpact();
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: IFColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: IFColors.gold),
      ),
      title: const Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: IFColors.gold),
          SizedBox(width: 10),
          Text('PR FORGED', style: IFText.h2),
        ],
      ),
      content: const Text('New estimated max unlocked. Keep lifting.', style: IFText.bodyMuted),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('LOCK IT IN')),
      ],
    ),
  );
}
