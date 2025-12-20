import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Long-press driven ribbon portal that spins open and emits sparks.
class RibbonPortalLayer extends StatefulWidget {
  const RibbonPortalLayer({
    super.key,
    required this.time,
    this.enabled = true,
  });

  final double time;
  final bool enabled;

  @override
  State<RibbonPortalLayer> createState() => _RibbonPortalLayerState();
}

class _RibbonPortalLayerState extends State<RibbonPortalLayer>
    with SingleTickerProviderStateMixin {
  final math.Random _random = math.Random();
  final List<_PortalSpark> _sparks = [];
  late final AnimationController _controller;
  Offset _center = Offset.zero;
  bool _isActive = false;

  static const _sparkLifetime = 2.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0,
      upperBound: 1,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RibbonPortalLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time) {
      final cutoff = widget.time - _sparkLifetime;
      _sparks.removeWhere((spark) => spark.startTime < cutoff);
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _center = details.localPosition;
      _isActive = true;
    });
    _controller.forward();
    _spawnSparks(count: 12);
  }

  void _handleLongPressMove(LongPressMoveUpdateDetails details) {
    if (!widget.enabled) return;
    setState(() => _center = details.localPosition);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (!_isActive) return;
    _controller.reverse();
    _spawnSparks(count: 20);
    setState(() => _isActive = false);
  }

  void _spawnSparks({int count = 8}) {
    final now = widget.time;
    for (var i = 0; i < count; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = lerpDouble(60, 130, _random.nextDouble())!;
      _sparks.add(
        _PortalSpark(
          angle: angle,
          speed: speed,
          startTime: now,
          startPosition: _center,
          hue: _random.nextDouble(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _handleLongPressStart,
      onLongPressMoveUpdate: _handleLongPressMove,
      onLongPressEnd: _handleLongPressEnd,
      onLongPressCancel: () => _handleLongPressEnd(LongPressEndDetails()),
      behavior: HitTestBehavior.translucent,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _RibbonPortalPainter(
            progress: _controller.value,
            center: _center,
            time: widget.time,
            sparks: List.unmodifiable(_sparks),
            active: _isActive,
            enabled: widget.enabled,
          ),
        ),
      ),
    );
  }
}

class _PortalSpark {
  const _PortalSpark({
    required this.angle,
    required this.speed,
    required this.startTime,
    required this.startPosition,
    required this.hue,
  });

  final double angle;
  final double speed;
  final double startTime;
  final Offset startPosition;
  final double hue;
}

class _RibbonPortalPainter extends CustomPainter {
  _RibbonPortalPainter({
    required this.progress,
    required this.center,
    required this.time,
    required this.sparks,
    required this.active,
    required this.enabled,
  }) : ribbonPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..strokeCap = StrokeCap.round;

  final double progress;
  final Offset center;
  final double time;
  final List<_PortalSpark> sparks;
  final bool active;
  final bool enabled;
  final Paint ribbonPaint;

  static const _sparkLifetime = _RibbonPortalLayerState._sparkLifetime;

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) return;
    final clamped = Curves.easeOutBack.transform(progress.clamp(0, 1));
    final radius = lerpDouble(80, size.shortestSide * .45, clamped) ?? 0;
    final ribbonCount = 4;
    final baseAngle = time * .6;

    for (var i = 0; i < ribbonCount; i++) {
      final localProgress = (clamped * (1 - i * .1)).clamp(0.0, 1.0);
      if (localProgress <= 0) continue;
      final sweep = math.pi * (1.2 - i * .12) * localProgress;
      final startAngle = baseAngle + i * .9;
      final rect = Rect.fromCircle(center: center, radius: radius * localProgress);
      ribbonPaint.shader = SweepGradient(
        colors: [
          const Color(0xFFFD6FD7).withValues(alpha: .6),
          const Color(0xFF94D2FF).withValues(alpha: .8),
          const Color(0xFF9CFFFA).withValues(alpha: .6),
        ],
      ).createShader(rect);
      canvas.drawArc(rect, startAngle, sweep, false, ribbonPaint);
    }

    _paintSparks(canvas);
    if (active) {
      final pulse = (math.sin(time * 6) + 1) * .25 + .5;
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF8CEBFF).withValues(alpha: .2 + pulse * .2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
      canvas.drawCircle(center, radius * .6 * clamped, glowPaint);
    }
  }

  void _paintSparks(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final spark in sparks) {
      final age = time - spark.startTime;
      if (age < 0 || age > _sparkLifetime) continue;
      final t = age / _sparkLifetime;
      final distance = spark.speed * Curves.easeOut.transform(t);
      final position = spark.startPosition +
          Offset(math.cos(spark.angle), math.sin(spark.angle)) * distance;
      paint.color = HSVColor.fromAHSV(
        (1 - t) * .8,
        lerpDouble(290, 200, spark.hue)!,
        .75,
        1,
      ).toColor();
      canvas.drawCircle(position, lerpDouble(3.5, 0.5, t) ?? 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RibbonPortalPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.center != center ||
        oldDelegate.time != time ||
        oldDelegate.sparks != sparks ||
        oldDelegate.active != active ||
        oldDelegate.enabled != enabled;
  }
}
