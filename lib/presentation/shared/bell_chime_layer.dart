import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Large bell with oscillating swing and emanating music notes.
class BellChimeLayer extends StatelessWidget {
  const BellChimeLayer({
    super.key,
    required this.time,
    this.enabled = true,
    this.musicLevel = 0,
    this.accentLevel = 0,
  });

  final double time;
  final bool enabled;
  final double musicLevel;
  final double accentLevel;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _BellPainter(
            time: time,
            musicLevel: musicLevel,
            accentLevel: accentLevel,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BellPainter extends CustomPainter {
  _BellPainter({
    required this.time,
    required this.musicLevel,
    required this.accentLevel,
  });

  final double time;
  final double musicLevel;
  final double accentLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final bellCenter = Offset(size.width * .5, size.height * .25);
    _drawGlow(canvas, size, bellCenter);
    _drawBell(canvas, bellCenter);
    _drawClapper(canvas, bellCenter);
    _drawMusicNotes(canvas, size);
  }

  void _drawGlow(Canvas canvas, Size size, Offset center) {
    final glow =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF3C4).withValues(alpha: .25),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * .5),
          );
    canvas.drawRect(Offset.zero & size, glow);
  }

  void _drawBell(Canvas canvas, Offset center) {
    final accentBoost = .15 + accentLevel * .3;
    final sway = math.sin(time * 2.4) * accentBoost;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sway);
    final bellPath =
        Path()
          ..moveTo(0, -20)
          ..quadraticBezierTo(70, 20, 70, 100)
          ..arcToPoint(
            Offset(-70, 100),
            radius: const Radius.circular(100),
            clockwise: false,
          )
          ..quadraticBezierTo(-70, 20, 0, -20)
          ..close();
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [const Color(0xFFFFD77F), const Color(0xFFFFA95F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bellPath.getBounds());
    canvas.drawPath(bellPath, paint);
    canvas.drawPath(
      bellPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white.withValues(alpha: .6),
    );
    canvas.restore();
  }

  void _drawClapper(Canvas canvas, Offset center) {
    final sway = math.sin(time * 2.4 + math.pi / 8) * .2;
    canvas.save();
    canvas.translate(center.dx, center.dy + 70);
    canvas.rotate(sway);
    canvas.drawCircle(
      Offset.zero,
      14,
      Paint()..color = const Color(0xFF694A2B),
    );
    canvas.restore();
  }

  void _drawMusicNotes(Canvas canvas, Size size) {
    final notePaint = Paint()..color = Colors.white;
    for (var i = 0; i < 8; i++) {
      final progress = ((time * .4) + i / 8) % 1;
      final angle = progress * math.pi * 2;
      final radius = size.width * .3 + math.sin(progress * math.pi) * 60;
      final position = Offset(
        size.width / 2 + math.cos(angle) * radius,
        size.height * .25 + math.sin(angle) * radius * .5 - progress * 120,
      );
      final alpha = ((1 - progress) + musicLevel * .4 + accentLevel * .6)
          .clamp(0.0, 1.0);
      notePaint.color = Colors.white.withValues(alpha: alpha);
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(-angle / 2);
      final rect = Rect.fromCenter(center: Offset.zero, width: 14, height: 24);
      canvas.drawOval(rect, notePaint);
      canvas.drawCircle(Offset(rect.width / 2, -rect.height / 2), 4, notePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BellPainter oldDelegate) =>
      oldDelegate.time != time;
}
