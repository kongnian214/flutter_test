import 'dart:math' as math;

import 'package:flutter/material.dart';

class FireworkBurstLayer extends StatelessWidget {
  final double time;
  final List<FireworkSeed> seeds;

  const FireworkBurstLayer({
    super.key,
    required this.time,
    required this.seeds,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(painter: _FireworkPainter(time, List.of(seeds))),
      ),
    );
  }
}

class _FireworkPainter extends CustomPainter {
  final double time;
  final List<FireworkSeed> seeds;

  static const _duration = 2.5;

  _FireworkPainter(this.time, this.seeds);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    for (final seed in seeds) {
      final progress = (time - seed.startTime) / _duration;
      if (progress < 0 || progress > 1) continue;
      final center = Offset(
        size.width * seed.horizontalFactor,
        size.height * .5,
      );
      final radius = Curves.easeOut.transform(progress) * size.height * .4;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      paint
        ..color =
            Color.lerp(
              const Color(0xFFFFF6A6).withValues(alpha: .8),
              const Color(0xFFFF4B91).withValues(alpha: .2),
              progress,
            )!
        ..strokeWidth = 2 + (1 - progress) * 2;
      canvas.drawCircle(center, radius, paint);

      final sparkPaint =
          Paint()
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 2
            ..color = Colors.white.withValues(alpha: opacity);
      for (int i = 0; i < 12; i++) {
        final angle = (math.pi * 2 / 12) * i;
        final sparkRadius = radius * .6;
        final start =
            center + Offset(math.cos(angle), math.sin(angle)) * sparkRadius;
        final end =
            start +
            Offset(math.cos(angle), math.sin(angle)) * (20 + progress * 20);
        canvas.drawLine(start, end, sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworkPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.seeds != seeds;
}

class FireworkSeed {
  final double startTime;
  final double horizontalFactor;

  const FireworkSeed({required this.startTime, required this.horizontalFactor});
}
