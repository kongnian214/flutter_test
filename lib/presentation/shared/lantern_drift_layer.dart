import 'dart:math' as math;

import 'package:flutter/material.dart';

class LanternDriftLayer extends StatelessWidget {
  final double time;
  final bool enabled;

  const LanternDriftLayer({
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
          duration: const Duration(milliseconds: 300),
          child: CustomPaint(painter: _LanternPainter(time)),
        ),
      ),
    );
  }
}

class _LanternPainter extends CustomPainter {
  final double time;

  _LanternPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }
    final random = math.Random(18);
    final paint =
        Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    for (int i = 0; i < 12; i++) {
      final seed = random.nextDouble();
      final x = seed * size.width;
      final speed = 8 + seed * 18;
      final baseHeight = size.height * (.3 + seed * .4);
      final travelDistance = size.height + baseHeight;
      final fallProgress =
          travelDistance == 0
              ? 0
              : (time * speed + seed * travelDistance) % travelDistance;
      final y = size.height - fallProgress;
      final radius = 8 + seed * 16;

      final baseColor =
          Color.lerp(
            const Color(0xFFFFD07F),
            const Color(0xFFFF6B6B),
            (seed + time * .05) % 1,
          )!;
      paint.color = baseColor.withValues(alpha: .35);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LanternPainter oldDelegate) =>
      oldDelegate.time != time;
}
