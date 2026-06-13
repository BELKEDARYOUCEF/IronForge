import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgeGlow extends StatelessWidget {
  const ForgeGlow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: IFColors.red.withValues(alpha: 0.18), blurRadius: 28, spreadRadius: -12)]),
      child: child,
    );
  }
}
