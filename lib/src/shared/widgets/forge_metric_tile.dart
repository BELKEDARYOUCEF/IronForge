import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/if_text_styles.dart';
import 'forge_card.dart';

class ForgeMetricTile extends StatelessWidget {
  const ForgeMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  final String label;
  final String value;
  final String? delta;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: (iconColor ?? IFColors.red).withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: (iconColor ?? IFColors.red).withValues(alpha: 0.22)),
              ),
              child: Icon(icon, color: iconColor ?? IFColors.red, size: 17),
            ),
          if (icon != null) const SizedBox(height: 9),
          Text(label.toUpperCase(), style: IFText.micro),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: IFColors.text)),
          ),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(delta!,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: IFColors.green)),
          ],
        ],
      ),
    );
  }
}
