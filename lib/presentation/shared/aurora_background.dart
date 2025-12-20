import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuroraBackground extends StatelessWidget {
  final Animation<double> animation;
  final bool enabled;

  const AuroraBackground({
    super.key,
    required this.animation,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return AnimatedOpacity(
              opacity: enabled ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: CustomPaint(painter: _AuroraPainter(animation.value)),
            );
          },
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double progress;

  _AuroraPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: const [Color(0xFF08111F), Color(0xFF0B1F36), Color(0xFF132F42)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = gradient);

    for (int i = 0; i < 3; i++) {
      final wavePaint =
          Paint()
            ..shader = RadialGradient(
              colors: [
                Color.lerp(
                  const Color(0xFF5FFBF1),
                  const Color(0xFFFF4B91),
                  (progress + i * .2) % 1,
                )!,
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * (.2 + i * .35), size.height * .2),
                radius: size.width * (.4 + i * .1),
              ),
            )
            ..blendMode = BlendMode.screen;

      final path = Path();
      final amplitude = 80 + i * 20;
      for (double x = 0; x <= size.width; x += 20) {
        final y =
            size.height * .2 +
            math.sin(
                  (x / size.width * 2 * math.pi) +
                      progress * math.pi * (1.2 + i * .4),
                ) *
                amplitude;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
      path.close();
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
