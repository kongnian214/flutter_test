import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Animated toy parade path with marching toys and spark bursts on collisions.
class ToyParadeLayer extends StatefulWidget {
  const ToyParadeLayer({super.key, required this.time, this.enabled = true});

  final double time;
  final bool enabled;

  @override
  State<ToyParadeLayer> createState() => _ToyParadeLayerState();
}

class _ToyParadeLayerState extends State<ToyParadeLayer> {
  final List<_ToyParticle> _particles = [];
  double _lastSpawn = 0;
  final math.Random _random = math.Random();

  @override
  void didUpdateWidget(ToyParadeLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time) {
      _particles.removeWhere((p) => widget.time - p.startTime > 3);
      if (widget.enabled && widget.time - _lastSpawn > 0.9) {
        _spawnParticle();
        _lastSpawn = widget.time;
      }
    }
  }

  void _spawnParticle() {
    _particles.add(
      _ToyParticle(
        startTime: widget.time,
        horizontalStart: _random.nextDouble(),
        speed: _random.nextDouble() * 0.08 + 0.04,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ToyParadePainter(
          time: widget.time,
          particles: List.unmodifiable(_particles),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ToyParadePainter extends CustomPainter {
  _ToyParadePainter({required this.time, required this.particles});

  final double time;
  final List<_ToyParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    _drawPath(canvas, size);
    _drawToys(canvas, size);
    _drawParticles(canvas, size);
  }

  void _drawPath(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..shader = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: .25),
              const Color(0xFF7BD2FF).withValues(alpha: .4),
            ],
          ).createShader(Offset.zero & size);
    final path = Path();
    final baseY = size.height * .65;
    path.moveTo(size.width * .1, baseY);
    path.cubicTo(
      size.width * .25,
      baseY - 40,
      size.width * .4,
      baseY + 60,
      size.width * .55,
      baseY - 20,
    );
    path.cubicTo(
      size.width * .7,
      baseY - 80,
      size.width * .85,
      baseY + 60,
      size.width * .95,
      baseY,
    );
    canvas.drawPath(path, paint);
  }

  void _drawToys(Canvas canvas, Size size) {
    final toyPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withValues(alpha: .6);
    const toyCount = 5;
    for (var i = 0; i < toyCount; i++) {
      final fraction = ((time * .1) + i / toyCount) % 1;
      final pos = _sampleCurve(size, fraction);
      final height = 34.0;
      final width = 24.0;
      toyPaint.color =
          Color.lerp(
            const Color(0xFFE57373),
            const Color(0xFF81D4FA),
            (i / toyCount),
          )!;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      final sway = math.sin(time * 4 + i) * 0.1;
      canvas.rotate(sway);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: width,
        height: height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        toyPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        strokePaint,
      );
      canvas.drawCircle(
        Offset(0, -height / 2 - 8),
        8,
        Paint()..color = Colors.white.withValues(alpha: .9),
      );
      canvas.restore();
    }
  }

  Offset _sampleCurve(Size size, double t) {
    final baseY = size.height * .65;
    final x = lerpDouble(size.width * .1, size.width * .95, t)!;
    final y =
        baseY + math.sin(t * math.pi * 2) * 60 + math.sin(t * math.pi * 4) * 20;
    return Offset(x, y);
  }

  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final particle in particles) {
      final age = time - particle.startTime;
      if (age < 0 || age > 3) continue;
      final progress = age / 3;
      final x =
          lerpDouble(
            size.width * particle.horizontalStart,
            size.width * (particle.horizontalStart + particle.speed),
            progress,
          )!;
      final y = size.height * .55 + math.sin(progress * math.pi) * 80;
      paint.color = Color.lerp(
        const Color(0xFFFFF59D),
        const Color(0xFFFF8A65),
        progress,
      )!.withValues(alpha: (1 - progress) * .6);
      canvas.drawCircle(Offset(x, y), 6 * (1 - progress) + 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ToyParadePainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.particles != particles;
  }
}

class _ToyParticle {
  _ToyParticle({
    required this.startTime,
    required this.horizontalStart,
    required this.speed,
  });

  final double startTime;
  final double horizontalStart;
  final double speed;
}
