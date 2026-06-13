import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/if_text_styles.dart';

class ForgeEmptyState extends StatelessWidget {
  const ForgeEmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: IFColors.red),
            const SizedBox(height: 16),
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
