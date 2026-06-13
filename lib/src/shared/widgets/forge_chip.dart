import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgeChip extends StatelessWidget {
  const ForgeChip({super.key, required this.label, this.selected = false, this.icon, this.onTap});

  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? IFColors.red : IFColors.panel2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? IFColors.red : IFColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : IFColors.textMuted),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(color: selected ? Colors.white : IFColors.textMuted, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
