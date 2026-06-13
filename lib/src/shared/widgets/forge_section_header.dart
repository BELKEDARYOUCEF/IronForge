import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgeSectionHeader extends StatelessWidget {
  const ForgeSectionHeader({super.key, required this.title, this.action, this.onActionTap});

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: IFColors.text, fontSize: 18, fontWeight: FontWeight.w900)),
        const Spacer(),
        if (action != null) TextButton(onPressed: onActionTap, child: Text(action!)),
      ],
    );
  }
}
