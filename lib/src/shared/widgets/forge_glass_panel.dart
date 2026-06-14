import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgeGlassPanel extends StatelessWidget {
  const ForgeGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: IFColors.panel.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor ?? IFColors.borderSoft),
          ),
          child: child,
        ),
      ),
    );
  }
}
