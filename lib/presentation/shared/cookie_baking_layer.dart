import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Cozy cookie baking vignette with wooden table, cookies, and rising steam.
class CookieBakingLayer extends StatelessWidget {
  const CookieBakingLayer({super.key, required this.time, this.enabled = true});

  final double time;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _CookieBakingPainter(time: time),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _CookieBakingPainter extends CustomPainter {
  _CookieBakingPainter({required this.time});

  final double time;
  final math.Random _rng = math.Random(24);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackdrop(canvas, size);
    _drawTable(canvas, size);
    _drawCookies(canvas, size);
    _drawSteam(canvas, size);
    _drawGlow(canvas, size);
  }

  void _drawBackdrop(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..blendMode = BlendMode.srcOver
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF3F1F0D).withValues(alpha: .55),
              const Color(0xFF8B4A1B).withValues(alpha: .55),
              const Color(0xFFC57C3B).withValues(alpha: .55),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawTable(Canvas canvas, Size size) {
    final tableHeight = size.height * .35;
    final rect = Rect.fromLTWH(
      0,
      size.height - tableHeight,
      size.width,
      tableHeight,
    );
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [const Color(0xFF8B5A2B), const Color(0xFF6C4420)],
          ).createShader(rect);
    canvas.drawRect(rect, paint);

    final plankPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black.withValues(alpha: .15);
    final planks = 5;
    for (var i = 1; i < planks; i++) {
      final y = rect.top + rect.height / planks * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), plankPaint);
    }
  }

  void _drawCookies(Canvas canvas, Size size) {
    final cookies = [
      _CookieSpot(Offset(.3, .78), 46),
      _CookieSpot(Offset(.55, .74), 52),
      _CookieSpot(Offset(.7, .82), 40),
      _CookieSpot(Offset(.45, .86), 34),
      _CookieSpot(Offset(.2, .84), 38),
    ];
    final cookiePaint = Paint()..style = PaintingStyle.fill;
    final chocPaint =
        Paint()
          ..color = const Color(0xFF3D2210)
          ..style = PaintingStyle.fill;

    for (final cookie in cookies) {
      final center = Offset(
        size.width * cookie.offset.dx,
        size.height * cookie.offset.dy,
      );
      final radius = cookie.radius;
      cookiePaint.shader = RadialGradient(
        colors: [
          const Color(0xFFE0B07C),
          const Color(0xFFC88A55),
          const Color(0xFFB8743B),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, cookiePaint);

      final chips = 7 + _rng.nextInt(4);
      for (var i = 0; i < chips; i++) {
        final angle = i / chips * math.pi * 2 + _rng.nextDouble() * 0.4;
        final dist = radius * (.4 + _rng.nextDouble() * .4);
        final pos =
            center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);
        canvas.drawCircle(pos, radius * .08, chocPaint);
      }
    }
  }

  void _drawSteam(Canvas canvas, Size size) {
    final steamPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
    final steamSources = [
      Offset(size.width * .32, size.height * .78),
      Offset(size.width * .58, size.height * .74),
      Offset(size.width * .7, size.height * .82),
    ];
    for (var i = 0; i < steamSources.length; i++) {
      final phase = time * .5 + i;
      final opacity = (.4 + .3 * math.sin(phase)).clamp(0.1, .7);
      steamPaint.color = Colors.white.withValues(alpha: opacity);
      final rect = Rect.fromCircle(
        center:
            steamSources[i] +
            Offset(math.sin(phase) * 20, -120 - math.cos(phase * 1.2) * 20),
        radius: lerpDouble(120, 160, (math.sin(phase * .8) + 1) / 2)!,
      );
      canvas.drawOval(rect, steamPaint);
    }
  }

  void _drawGlow(Canvas canvas, Size size) {
    final glowPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFE0B2).withValues(alpha: .35),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .5, size.height * .75),
              radius: size.width * .5,
            ),
          );
    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _CookieBakingPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

class _CookieSpot {
  const _CookieSpot(this.offset, this.radius);

  final Offset offset;
  final double radius;
}
