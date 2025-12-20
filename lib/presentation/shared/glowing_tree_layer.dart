import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Music-inspired glowing tree made of layered ribbons and pulsing ornaments.
class GlowingTreeLayer extends StatelessWidget {
  const GlowingTreeLayer({
    super.key,
    required this.time,
    this.enabled = true,
    this.musicLevel = 0,
  });

  final double time;
  final bool enabled;
  final double musicLevel;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _GlowingTreePainter(time: time, musicLevel: musicLevel),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GlowingTreePainter extends CustomPainter {
  _GlowingTreePainter({required this.time, required this.musicLevel});

  final double time;
  final double musicLevel;
  final math.Random _rng = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .72);
    _drawTreeBody(canvas, center, size);
    _drawRings(canvas, center, size);
    _drawOrnaments(canvas, center, size);
    _drawGlow(canvas, center, size);
  }

  void _drawTreeBody(Canvas canvas, Offset center, Size size) {
    final height = size.height * .55;
    final width = size.width * .35;
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF0F1D32),
              const Color(0xFF123A3F),
              const Color(0xFF0B1C2B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromCenter(
              center: center.translate(0, -height / 2),
              width: width,
              height: height,
            ),
          )
          ..style = PaintingStyle.fill;
    final path =
        Path()
          ..moveTo(center.dx, center.dy - height)
          ..lineTo(center.dx + width / 2, center.dy + height * .1)
          ..lineTo(center.dx + width * .3, center.dy + height * .3)
          ..lineTo(center.dx + width * .4, center.dy + height * .55)
          ..lineTo(center.dx + width * .25, center.dy + height * .8)
          ..lineTo(center.dx + width * .35, center.dy + height)
          ..lineTo(center.dx - width * .35, center.dy + height)
          ..lineTo(center.dx - width * .25, center.dy + height * .8)
          ..lineTo(center.dx - width * .4, center.dy + height * .55)
          ..lineTo(center.dx - width * .3, center.dy + height * .3)
          ..lineTo(center.dx - width / 2, center.dy + height * .1)
          ..close();
    canvas.drawPath(path, paint);

    final trunkPaint =
        Paint()
          ..color = const Color(0xFF5C3B2E)
          ..style = PaintingStyle.fill;
    final trunkRect = Rect.fromCenter(
      center: center.translate(0, height * .55),
      width: width * .18,
      height: height * .2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(trunkRect, Radius.circular(width * .05)),
      trunkPaint,
    );
  }

  void _drawRings(Canvas canvas, Offset center, Size size) {
    final baseWidth = size.width * .28;
    final height = size.height * .5;
    final ringPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 5; i++) {
      final t = i / 5;
      final beat = _beatValue(time, offset: i * .4);
      final width = baseWidth * (1 - t * .6);
      final y = center.dy - height * (1 - t) + height * .2;
      final rect = Rect.fromCenter(
        center: Offset(center.dx, y),
        width: width * (1 + beat * .2),
        height: width * .2,
      );
      ringPaint.shader = LinearGradient(
        colors: [
          const Color(0xFF61E8FF).withValues(alpha: .4 + beat * .5),
          const Color(0xFFEFFFBF).withValues(alpha: .7 + beat * .2),
        ],
      ).createShader(rect);
      canvas.drawArc(rect, -math.pi * .9, math.pi * 1.8, false, ringPaint);
    }
  }

  void _drawOrnaments(Canvas canvas, Offset center, Size size) {
    final ornaments = _generateOrnaments();
    final paint = Paint();
    for (final ornament in ornaments) {
      final beat = _beatValue(time, offset: ornament.phase);
      final radius = lerpDouble(2.5, 6, beat) ?? 4;
      final pos = Offset(
        center.dx + ornament.offset.dx * size.width * .18,
        center.dy - size.height * .35 + ornament.offset.dy * size.height * .5,
      );
      final color = Color.lerp(ornament.color, Colors.white, beat)!;
      paint
        ..color = color.withValues(alpha: .7 + beat * .3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(pos, radius * 1.6, paint);
      paint
        ..color = color
        ..maskFilter = null;
      canvas.drawCircle(pos, radius, paint);
    }
  }

  void _drawGlow(Canvas canvas, Offset center, Size size) {
    final glowPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF6EE4FF).withValues(alpha: .15),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: center.translate(0, -size.height * .2),
              radius: size.width * .4,
            ),
          )
          ..blendMode = BlendMode.plus;
    canvas.drawCircle(
      center.translate(0, -size.height * .2),
      size.width * .4,
      glowPaint,
    );
  }

  List<_TreeOrnament> _generateOrnaments() {
    return List<_TreeOrnament>.generate(24, (index) {
      final phase = _rng.nextDouble() * math.pi * 2;
      final dx = _rng.nextDouble() * 2 - 1;
      final dy = _rng.nextDouble();
      final color =
          HSVColor.fromAHSV(
            1,
            lerpDouble(120, 320, _rng.nextDouble())!,
            .6 + _rng.nextDouble() * .3,
            .9,
          ).toColor();
      return _TreeOrnament(offset: Offset(dx, dy), color: color, phase: phase);
    });
  }

  double _beatValue(double t, {double offset = 0}) {
    final wave = (math.sin((t + offset) * 4) + 1) / 2;
    final easedAudio = math.pow(musicLevel, 1.2).toDouble();
    final mix = lerpDouble(wave, easedAudio, .65) ?? wave;
    return math.pow(mix, 2).toDouble();
  }

  @override
  bool shouldRepaint(covariant _GlowingTreePainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

class _TreeOrnament {
  const _TreeOrnament({
    required this.offset,
    required this.color,
    required this.phase,
  });

  final Offset offset;
  final Color color;
  final double phase;
}
