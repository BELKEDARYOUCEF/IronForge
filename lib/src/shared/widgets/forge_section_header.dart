import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/if_text_styles.dart';

class ForgeSectionHeader extends StatelessWidget {
  const ForgeSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: IFText.h2),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: IFText.micro),
              ],
            ],
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              foregroundColor: IFColors.red,
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}
