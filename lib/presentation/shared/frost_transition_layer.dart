import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Frost transition overlay that simulates crystalline spread and melt.
class FrostTransitionLayer extends StatelessWidget {
  const FrostTransitionLayer({
    super.key,
    required this.time,
    this.enabled = true,
  });

  final double time;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _FrostTransitionPainter(time: time),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _FrostTransitionPainter extends CustomPainter {
  _FrostTransitionPainter({required this.time});

  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = (math.sin(time * .6) + 1) / 2;
    final eased = Curves.easeInOutCubic.transform(progress);
    _paintBackdrop(canvas, size, eased);
    _paintCrystalMask(canvas, size, eased);
    _paintRimLight(canvas, size, eased);
  }

  void _paintBackdrop(Canvas canvas, Size size, double eased) {
    final overlay =
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF011627).withValues(alpha: .2 + eased * .2),
              const Color(0xFF184457).withValues(alpha: .35 + eased * .25),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, overlay);
  }

  void _paintCrystalMask(Canvas canvas, Size size, double eased) {
    final rng = math.Random(0xF57);
    final layer =
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFBFE6FF).withValues(alpha: .35 + eased * .4);
    final cracks =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFFECFFFF).withValues(alpha: .4 + eased * .3);

    for (var i = 0; i < 18; i++) {
      final center = Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height * .8,
      );
      final radius = lerpDouble(40, 180, rng.nextDouble())! * (eased + .25);
      final sides = 5 + rng.nextInt(4);
      final path = Path();
      for (var j = 0; j < sides; j++) {
        final angle = (math.pi * 2 * j / sides) + rng.nextDouble() * .2;
        final r = radius * (0.6 + rng.nextDouble() * .4);
        final point = Offset(
          center.dx + math.cos(angle) * r,
          center.dy + math.sin(angle) * r,
        );
        if (j == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, layer);

      for (var c = 0; c < 4; c++) {
        final crackLength = radius * (0.5 + rng.nextDouble() * .4);
        final crackAngle = rng.nextDouble() * math.pi * 2;
        final start =
            center +
            Offset(
              math.cos(crackAngle) * radius * .4,
              math.sin(crackAngle) * radius * .4,
            );
        final end =
            start +
            Offset(
              math.cos(crackAngle) * crackLength,
              math.sin(crackAngle) * crackLength,
            );
        canvas.drawLine(start, end, cracks);
      }
    }
  }

  void _paintRimLight(Canvas canvas, Size size, double eased) {
    final glowPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFE0F7FF).withValues(alpha: .45 * eased),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: size.shortestSide * .65,
            ),
          );
    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _FrostTransitionPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
