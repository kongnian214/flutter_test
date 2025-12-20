import 'dart:math' as math;

import 'package:flutter/material.dart';

class MeteorShowerLayer extends StatelessWidget {
  final double time;
  final bool enabled;

  const MeteorShowerLayer({
    super.key,
    required this.time,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: enabled ? 1 : 0,
          child: CustomPaint(painter: _MeteorPainter(time)),
        ),
      ),
    );
  }
}

class _MeteorPainter extends CustomPainter {
  final double time;

  _MeteorPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final random = math.Random(77);
    final count = 8;
    final paint =
        Paint()
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    for (int i = 0; i < count; i++) {
      final seed = random.nextDouble();
      final speed = 40 + seed * 60;
      final distance = size.width + size.height;
      final progress = (time * speed + seed * distance) % distance;
      final start = Offset(
        size.width - progress * .6,
        size.height * (.2 + seed * .6),
      );
      final length = 80 + seed * 120;
      final angle = -math.pi / 4;
      final end = start + Offset(math.cos(angle), math.sin(angle)) * length;
      final opacity = (1 - progress / distance).clamp(0.0, 1.0);
      final baseColor =
          Color.lerp(const Color(0xFF9BFFF9), const Color(0xFFFF8BD1), seed)!;
      paint.color = baseColor.withValues(alpha: opacity * .8);
      canvas.drawLine(start, end, paint);
      final glowPaint =
          Paint()
            ..color = baseColor.withValues(alpha: opacity * .35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawLine(start, end, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeteorPainter oldDelegate) =>
      oldDelegate.time != time;
}
