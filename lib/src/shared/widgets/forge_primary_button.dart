import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgePrimaryButton extends StatelessWidget {
  const ForgePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: IFColors.red.withValues(alpha: 0.24),
                    blurRadius: 24,
                    spreadRadius: -12,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: Material(
          color: disabled ? IFColors.panel3 : IFColors.red,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: disabled
                        ? IFColors.border
                        : IFColors.redGlow.withValues(alpha: 0.35)),
                gradient: disabled
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          IFColors.redGlow,
                          IFColors.red,
                          IFColors.redDark
                        ],
                      ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Icon(icon ?? Icons.play_arrow_rounded,
                      color: disabled ? IFColors.textFaint : Colors.white,
                      size: 21),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: disabled ? IFColors.textFaint : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
