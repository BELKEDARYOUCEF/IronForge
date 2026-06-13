import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/if_text_styles.dart';
import 'forge_card.dart';

class ForgeMetricTile extends StatelessWidget {
  const ForgeMetricTile({super.key, required this.label, required this.value, this.delta, this.icon, this.iconColor});

  final String label;
  final String value;
  final String? delta;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, color: iconColor ?? IFColors.red, size: 18),
          if (icon != null) const SizedBox(height: 8),
          Text(label.toUpperCase(), style: IFText.micro),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: IFColors.text)),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(delta!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: IFColors.green)),
          ],
        ],
      ),
    );
  }
}
