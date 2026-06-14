import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/if_text_styles.dart';

class ForgeEmptyState extends StatelessWidget {
  const ForgeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 18 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 52 : 64,
              height: compact ? 52 : 64,
              decoration: BoxDecoration(
                color: IFColors.red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: IFColors.red.withValues(alpha: 0.32)),
              ),
              child: Icon(icon, size: compact ? 26 : 32, color: IFColors.red),
            ),
            SizedBox(height: compact ? 12 : 16),
            Text(title, style: IFText.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: IFText.bodyMuted, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
