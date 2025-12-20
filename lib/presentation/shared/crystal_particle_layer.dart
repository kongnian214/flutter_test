import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// Gesture-driven particle layer that leaves shimmering crystal trails.
class CrystalParticleLayer extends StatefulWidget {
  const CrystalParticleLayer({
    super.key,
    required this.time,
    this.enabled = true,
  });

  final double time;
  final bool enabled;

  @override
  State<CrystalParticleLayer> createState() => _CrystalParticleLayerState();
}

class _CrystalParticleLayerState extends State<CrystalParticleLayer> {
  static const _lifetime = 2.6;
  final math.Random _random = math.Random();
  final List<_CrystalShard> _shards = [];
  double _lastEmit = 0;

  @override
  void didUpdateWidget(CrystalParticleLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time) {
      final cutoff = widget.time - _lifetime;
      _shards.removeWhere((shard) => shard.startTime < cutoff);
    }
  }

  void _onPointer(PointerEvent event) {
    if (!widget.enabled) return;
    if (event is PointerDownEvent || event is PointerMoveEvent) {
      if (widget.time - _lastEmit > .015) {
        _spawnShard(event.localPosition);
        _lastEmit = widget.time;
      }
    }
  }

  void _spawnShard(Offset position) {
    final angle = _random.nextDouble() * math.pi * 2;
    final radius =
        lerpDouble(10, 24, _random.nextDouble()) ?? (_random.nextDouble() * 8);
    final shimmer = _random.nextDouble();
    _shards.add(
      _CrystalShard(
        position: position,
        startTime: widget.time,
        rotation: angle,
        radius: radius,
        shimmer: shimmer,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointer,
      onPointerMove: _onPointer,
      behavior: HitTestBehavior.translucent,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _CrystalPainter(
            shards: List.unmodifiable(_shards),
            now: widget.time,
            enabled: widget.enabled,
          ),
        ),
      ),
    );
  }
}

class _CrystalShard {
  const _CrystalShard({
    required this.position,
    required this.startTime,
    required this.rotation,
    required this.radius,
    required this.shimmer,
  });

  final Offset position;
  final double startTime;
  final double rotation;
  final double radius;
  final double shimmer;
}

class _CrystalPainter extends CustomPainter {
  _CrystalPainter({
    required this.shards,
    required this.now,
    required this.enabled,
  });

  final List<_CrystalShard> shards;
  final double now;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled || shards.isEmpty) return;
    final paint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    for (final shard in shards) {
      final age = now - shard.startTime;
      if (age.isNegative) continue;
      final t = (age / _CrystalParticleLayerState._lifetime).clamp(0.0, 1.0);
      if (t >= 1) continue;
      final fade = Curves.easeOutExpo.transform(1 - t);
      final scale = Curves.easeOut.transform(math.min(t * 1.3, 1));
      final color = Color.lerp(
        const Color(0xFF7AE3FF),
        const Color(0xFFDBFFFD),
        shard.shimmer,
      )!;
      final alpha = (fade * 0.9).clamp(0.0, 1.0);
      final rect = Rect.fromCenter(
        center: shard.position,
        width: shard.radius * 1.8,
        height: shard.radius * (1.4 + shard.shimmer * .6),
      );

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(shard.rotation);
      final scaledRect = Rect.fromCenter(
        center: Offset.zero,
        width: rect.width * scale,
        height: rect.height * scale,
      );
      final rrect = RRect.fromRectAndRadius(
        scaledRect,
        Radius.circular(rect.width * .45),
      );

      glowPaint.color = color.withValues(alpha: alpha * .4);
      canvas.drawRRect(rrect, glowPaint);

      paint.shader = LinearGradient(
        colors: [
          color.withValues(alpha: alpha),
          Colors.white.withValues(alpha: alpha),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rrect.outerRect);
      canvas.drawRRect(rrect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CrystalPainter oldDelegate) {
    return oldDelegate.shards != shards ||
        oldDelegate.now != now ||
        oldDelegate.enabled != enabled;
  }
}
