import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgeProgressRing extends StatelessWidget {
  const ForgeProgressRing({
    super.key,
    required this.value,
    this.size = 160,
    this.strokeWidth = 12,
    this.center,
    this.color = IFColors.red,
    this.backgroundColor = IFColors.panel3,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Widget? center;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _ForgeProgressRingPainter(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              color: color,
              backgroundColor: backgroundColor,
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _ForgeProgressRingPainter extends CustomPainter {
  const _ForgeProgressRingPainter({
    required this.value,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  final double value;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = strokeWidth / 2;
    final arcRect = rect.deflate(inset);
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [color, IFColors.redGlow, color],
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2, false, backgroundPaint);
    if (value > 0) {
      canvas.drawArc(
          arcRect, -math.pi / 2, math.pi * 2 * value, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ForgeProgressRingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
