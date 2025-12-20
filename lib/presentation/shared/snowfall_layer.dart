import 'dart:math' as math;

import 'package:flutter/material.dart';

class SnowfallLayer extends StatelessWidget {
  final double time;
  final double density;
  final bool enabled;
  final Offset wind;

  const SnowfallLayer({
    super.key,
    required this.time,
    required this.density,
    required this.enabled,
    this.wind = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: CustomPaint(
            painter: _SnowPainter(time: time, density: density, wind: wind),
          ),
        ),
      ),
    );
  }
}

class _SnowPainter extends CustomPainter {
  final double time;
  final double density;
  final Offset wind;

  const _SnowPainter({
    required this.time,
    required this.density,
    required this.wind,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }
    final count = (160 * density).clamp(40, 220).toInt();
    final random = math.Random(2024);
    final paint = Paint()..color = Colors.white.withValues(alpha: .85);

    for (int i = 0; i < count; i++) {
      final seed = random.nextDouble();
      final speed = 15 + seed * 55;
      final drift = math.sin(time * (.3 + seed) + i) * 25 + wind.dx * 40;
      final rawX = (seed * size.width + drift) % size.width;
      final x = rawX.isNegative ? rawX + size.width : rawX;
      final y =
          (time * (speed + wind.dy * 60) + seed * size.height) % size.height;
      final radius = 1.2 + seed * 2.5;
      final alpha = (.3 + math.sin(time + i) * .1 + seed * .4).clamp(0.0, 1.0);
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.density != density ||
      oldDelegate.wind != wind;
}
