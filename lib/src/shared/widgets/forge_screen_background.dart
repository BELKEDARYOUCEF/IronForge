import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgeScreenBackground extends StatelessWidget {
  const ForgeScreenBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: IFColors.black,
        gradient: RadialGradient(
          center: const Alignment(0, -1.08),
          radius: 1.15,
          colors: [
            IFColors.redDark.withValues(alpha: 0.16),
            IFColors.black2.withValues(alpha: 0.48),
            IFColors.black,
          ],
          stops: const [0, 0.38, 1],
        ),
      ),
      child: child,
    );
  }
}
