import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/if_spacing.dart';

class ForgeCard extends StatelessWidget {
  const ForgeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(IFSpacing.paddingCard),
    this.borderColor,
    this.backgroundColor,
    this.glow = false,
    this.selected = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool glow;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const radius = IFSpacing.radiusCard;
    final effectiveBorder =
        borderColor ?? (selected ? IFColors.red : IFColors.borderSoft);
    final content = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (selected ? IFColors.panel2 : IFColors.panel),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: effectiveBorder, width: IFSpacing.borderWidth),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: IFColors.red.withValues(alpha: selected ? 0.28 : 0.18),
                  blurRadius: 28,
                  spreadRadius: -14,
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
