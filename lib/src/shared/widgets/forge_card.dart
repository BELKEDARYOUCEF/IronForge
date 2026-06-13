import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgeCard extends StatelessWidget {
  const ForgeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor,
    this.glow = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final bool glow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: IFColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? IFColors.borderSoft),
        boxShadow: glow
            ? [BoxShadow(color: IFColors.red.withValues(alpha: 0.22), blurRadius: 22, spreadRadius: -10)]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: content);
  }
}
