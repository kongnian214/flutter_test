import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Trails layer mimicking aurora motion blur when the camera moves.
class AuroraTrailsLayer extends StatelessWidget {
  const AuroraTrailsLayer({super.key, required this.time, this.enabled = true});

  final double time;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _AuroraTrailPainter(time: time),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _AuroraTrailPainter extends CustomPainter {
  _AuroraTrailPainter({required this.time});

  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGradient(canvas, size);
    _drawTrails(canvas, size);
  }

  void _drawGradient(Canvas canvas, Size size) {
    final gradient =
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF0A1630),
              const Color(0xFF142F56),
              const Color(0xFF1F4A67),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, gradient);
  }

  void _drawTrails(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final random = math.Random(3);
    for (var i = 0; i < 30; i++) {
      final seed = random.nextDouble();
      final baseY = size.height * (.2 + seed * .6);
      final amplitude = 20 + seed * 60;
      final phaseShift = i * .3;
      final opacity = (.2 + seed * .5).clamp(0.1, .6);
      final thickness = 2 + seed * 4;
      final hue = lerpDouble(160, 260, seed)!;
      paint
        ..strokeWidth = thickness
        ..color = HSVColor.fromAHSV(opacity, hue, .7, 1).toColor();
      final path = Path();
      path.moveTo(0, baseY);
      for (var x = 0; x <= size.width.toInt(); x += 10) {
        final dx = x.toDouble();
        final offset =
            math.sin((dx / size.width) * math.pi * 4 + time + phaseShift) *
            amplitude;
        final dy = baseY + offset;
        if (x == 0) {
          path.moveTo(dx, dy);
        } else {
          path.lineTo(dx, dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraTrailPainter oldDelegate) =>
      oldDelegate.time != time;
}
