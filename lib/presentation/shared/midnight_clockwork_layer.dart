import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mechanical clockwork layer featuring rotating gears and spark pulses.
class MidnightClockworkLayer extends StatelessWidget {
  const MidnightClockworkLayer({
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
          painter: _ClockworkPainter(time: time),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ClockworkPainter extends CustomPainter {
  _ClockworkPainter({required this.time});

  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackdrop(canvas, size);
    _drawGears(canvas, size);
    _drawClockFace(canvas, size);
    _drawSparks(canvas, size);
  }

  void _drawBackdrop(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint =
        Paint()
          ..blendMode = BlendMode.srcOver
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF090C16).withValues(alpha: .45),
              const Color(0xFF1C2236).withValues(alpha: .45),
              const Color(0xFF0F192B).withValues(alpha: .45),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawGears(Canvas canvas, Size size) {
    final centers = [
      Offset(size.width * .25, size.height * .55),
      Offset(size.width * .5, size.height * .6),
      Offset(size.width * .75, size.height * .5),
    ];
    final radii = [90.0, 130.0, 70.0];
    final speeds = [0.8, -0.4, 1.2];
    for (var i = 0; i < centers.length; i++) {
      _drawGear(canvas, centers[i], radii[i], time * speeds[i], i.isEven);
    }
  }

  void _drawGear(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    bool glow,
  ) {
    final toothCount = 12;
    final gearPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = Colors.grey.shade300.withValues(alpha: .8);
    if (glow) {
      canvas.drawCircle(
        center,
        radius + 20,
        Paint()
          ..color = const Color(0xFF88F0FF).withValues(alpha: .1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
      );
    }
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final baseCircle = Rect.fromCircle(center: Offset.zero, radius: radius);
    canvas.drawArc(baseCircle, 0, math.pi * 2, false, gearPaint);
    for (var i = 0; i < toothCount; i++) {
      final angle = i / toothCount * math.pi * 2;
      final start = Offset(
        math.cos(angle) * (radius - 6),
        math.sin(angle) * (radius - 6),
      );
      final end = Offset(
        math.cos(angle) * (radius + 14),
        math.sin(angle) * (radius + 14),
      );
      canvas.drawLine(start, end, gearPaint);
    }
    canvas.restore();
  }

  void _drawClockFace(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .35);
    final radius = size.width * .2;
    final facePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = Colors.white.withValues(alpha: .7);
    final fillPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [const Color(0xFF1E2640), const Color(0xFF101528)],
          ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, facePaint);

    for (var i = 0; i < 12; i++) {
      final angle = math.pi / 2 - i * math.pi / 6;
      final start =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius - 10);
      final end =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius - 30);
      canvas.drawLine(start, end, facePaint);
    }

    final minuteAngle = math.pi / 2 - (time % 60) / 60 * math.pi * 2;
    final hourAngle = math.pi / 2 - (time % 3600) / 3600 * math.pi * 2;
    canvas.drawLine(
      center,
      center + Offset(math.cos(hourAngle), math.sin(hourAngle)) * (radius * .5),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      center,
      center +
          Offset(math.cos(minuteAngle), math.sin(minuteAngle)) * (radius * .8),
      Paint()
        ..color = const Color(0xFF8CE0FF)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawSparks(Canvas canvas, Size size) {
    final sparks = 20;
    final paint = Paint()..style = PaintingStyle.fill;
    final baseY = size.height * .6;
    for (var i = 0; i < sparks; i++) {
      final seed = (time * .5 + i) % 1;
      final x = size.width * (i / sparks);
      final y = baseY - math.sin(seed * math.pi) * 40;
      paint.color = Color.lerp(
        const Color(0xFFFFF176),
        const Color(0xFFFF8A65),
        seed,
      )!.withValues(alpha: (1 - seed) * .5);
      canvas.drawCircle(Offset(x, y), 4 + seed * 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClockworkPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
