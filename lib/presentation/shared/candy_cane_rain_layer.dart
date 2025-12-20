import 'dart:math' as math;

import 'package:flutter/material.dart';

class CandyCaneRainLayer extends StatelessWidget {
  final double time;
  final bool enabled;

  const CandyCaneRainLayer({
    super.key,
    required this.time,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: CustomPaint(painter: _CandyCanePainter(time)),
        ),
      ),
    );
  }
}

class _CandyCanePainter extends CustomPainter {
  final double time;

  _CandyCanePainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final random = math.Random(36);
    const caneCount = 18;
    for (int i = 0; i < caneCount; i++) {
      final seed = random.nextDouble();
      final x = seed * size.width;
      final speed = 20 + seed * 30;
      final travel = size.height + 100;
      final progress = (time * speed + seed * travel) % travel;
      final y = progress - 100;
      final angle = math.sin(time * .6 + seed * 5) * .25;
      final scale = .85 + seed * .5;
      final sway = math.sin(time * .8 + seed * 8) * 20;
      _drawCandyCane(
        canvas,
        Offset(x + sway, y),
        angle,
        scale,
        1 - (progress / travel),
      );
    }
  }

  void _drawCandyCane(
    Canvas canvas,
    Offset position,
    double angle,
    double scale,
    double ambient,
  ) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    canvas.scale(scale);

    final stemPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: .9)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    final accentPaint =
        Paint()
          ..color = const Color(0xFFFF4B91).withValues(alpha: .9)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    final glowPaint =
        Paint()
          ..color = const Color(0xFFFFD8A8).withValues(alpha: ambient * .25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // glow halo.
    canvas.drawCircle(Offset.zero, 28, glowPaint);

    // stem line
    canvas.drawLine(const Offset(0, -12), const Offset(0, 24), stemPaint);
    // hook arc
    final hookRect = Rect.fromCircle(center: const Offset(0, -12), radius: 14);
    canvas.drawArc(hookRect, math.pi, math.pi / 2, false, stemPaint);

    // stripes along cane
    for (double offset = -10; offset < 30; offset += 8) {
      final start = Offset(0, offset);
      final end = start + const Offset(6, 6);
      canvas.drawLine(start, end, accentPaint);
    }

    // stripes on hook
    canvas.drawArc(
      hookRect.inflate(-4),
      math.pi,
      math.pi / 2,
      false,
      accentPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CandyCanePainter oldDelegate) =>
      oldDelegate.time != time;
}
