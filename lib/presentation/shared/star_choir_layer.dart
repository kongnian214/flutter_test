import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Floating audio-reactive notes radiating from center (simulated intensity).
class StarChoirLayer extends StatelessWidget {
  const StarChoirLayer({
    super.key,
    required this.time,
    this.enabled = true,
    this.intensity = 0,
  });

  final double time;
  final bool enabled;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _StarChoirPainter(time: time, intensity: intensity),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _StarChoirPainter extends CustomPainter {
  _StarChoirPainter({required this.time, required this.intensity});

  final double time;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .35);
    _drawHalo(canvas, center, size);
    _drawRings(canvas, center);
    _drawNotes(canvas, center, size);
  }

  void _drawHalo(Canvas canvas, Offset center, Size size) {
    final paint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFBDE0FE).withValues(alpha: .2 + intensity * .3),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * .4),
          );
    canvas.drawCircle(center, size.width * .4, paint);
  }

  void _drawRings(Canvas canvas, Offset center) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white.withValues(alpha: .3);
    for (var i = 0; i < 3; i++) {
      final radius = 60 + i * 35 + math.sin(time * 2 + i) * 5;
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawNotes(Canvas canvas, Offset center, Size size) {
    final random = math.Random(42);
    final notePaint = Paint()..color = Colors.white;
    final count = 20;
    for (var i = 0; i < count; i++) {
      final seed = random.nextDouble();
      final angle = i / count * math.pi * 2 + time * .4;
      final radius = 40 + seed * (size.shortestSide * .35);
      final wave = (math.sin(time * 2 + seed * math.pi * 2) + 1) / 2;
      final noteIntensity = (wave * .7) + intensity * .3;
      final pos =
          center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      notePaint.color = Color.lerp(
        const Color(0xFF80FFEA),
        const Color(0xFFEFB0FF),
        noteIntensity,
      )!.withValues(alpha: .35 + noteIntensity * .65);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle / 2);
      final rect = Rect.fromCenter(center: Offset.zero, width: 18, height: 30);
      canvas.drawOval(rect, notePaint);
      canvas.drawCircle(Offset(rect.width / 2, -rect.height / 2), 5, notePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _StarChoirPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.intensity != intensity;
  }
}
