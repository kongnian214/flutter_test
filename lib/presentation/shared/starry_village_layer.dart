import 'dart:math' as math;

import 'package:flutter/material.dart';

class StarryVillageLayer extends StatelessWidget {
  final double time;
  final bool enabled;

  const StarryVillageLayer({
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
          child: CustomPaint(painter: _VillagePainter(time)),
        ),
      ),
    );
  }
}

class _HouseBlueprint {
  final double xFactor;
  final double width;
  final double height;
  final int windowColumns;
  final int windowRows;
  final bool hasChimney;

  const _HouseBlueprint({
    required this.xFactor,
    required this.width,
    required this.height,
    required this.windowColumns,
    required this.windowRows,
    this.hasChimney = false,
  });
}

class _VillagePainter extends CustomPainter {
  final double time;
  static const _houses = [
    _HouseBlueprint(
      xFactor: .02,
      width: 70,
      height: 80,
      windowColumns: 2,
      windowRows: 2,
    ),
    _HouseBlueprint(
      xFactor: .18,
      width: 90,
      height: 110,
      windowColumns: 3,
      windowRows: 3,
      hasChimney: true,
    ),
    _HouseBlueprint(
      xFactor: .42,
      width: 80,
      height: 95,
      windowColumns: 2,
      windowRows: 3,
    ),
    _HouseBlueprint(
      xFactor: .60,
      width: 110,
      height: 130,
      windowColumns: 3,
      windowRows: 3,
      hasChimney: true,
    ),
    _HouseBlueprint(
      xFactor: .80,
      width: 75,
      height: 85,
      windowColumns: 2,
      windowRows: 2,
    ),
  ];

  const _VillagePainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _drawStars(canvas, size);
    _drawHills(canvas, size);
    _drawVillage(canvas, size);
  }

  void _drawStars(Canvas canvas, Size size) {
    final random = math.Random(7);
    final starPaint = Paint();
    for (int i = 0; i < 45; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * .5;
      final twinkle =
          .3 + .7 * math.max(0, math.sin(time * 1.2 + i * .75)).abs();
      starPaint.color = Colors.white.withValues(alpha: twinkle);
      canvas.drawCircle(Offset(x, y), .7 + random.nextDouble(), starPaint);
    }
  }

  void _drawHills(Canvas canvas, Size size) {
    final basePaint = Paint()..color = const Color(0xFF07192A);
    final hillHeight = size.height * .35;
    final path =
        Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height - hillHeight);
    for (double x = 0; x <= size.width; x += 30) {
      final y =
          size.height -
          hillHeight -
          math.sin((x / size.width * 3 * math.pi) + time * .2) * 12;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, basePaint);
  }

  void _drawVillage(Canvas canvas, Size size) {
    final ground = size.height - 20;
    final housePaint = Paint();
    final roofPaint = Paint()..color = const Color(0xFF0C2B3E);
    int windowSeed = 0;

    for (final house in _houses) {
      final left = size.width * house.xFactor;
      final rect = Rect.fromLTWH(
        left,
        ground - house.height,
        house.width,
        house.height,
      );
      housePaint.color = const Color(
        0xFF0E2030,
      ).withValues(alpha: .85 + math.sin(time + left) * .05);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        housePaint,
      );

      final roofPath =
          Path()
            ..moveTo(rect.left - 6, rect.top + 10)
            ..lineTo(rect.center.dx, rect.top - 25)
            ..lineTo(rect.right + 6, rect.top + 10)
            ..close();
      canvas.drawPath(roofPath, roofPaint);

      if (house.hasChimney) {
        final chimney = Rect.fromLTWH(rect.right - 18, rect.top - 30, 12, 30);
        canvas.drawRRect(
          RRect.fromRectAndRadius(chimney, const Radius.circular(4)),
          roofPaint,
        );
        _drawSmoke(canvas, chimney.topCenter);
      }

      _drawWindows(canvas, rect, house, windowSeed);
      windowSeed += house.windowColumns * house.windowRows;
    }
  }

  void _drawWindows(
    Canvas canvas,
    Rect rect,
    _HouseBlueprint house,
    int seedBase,
  ) {
    final columnSpacing = rect.width / (house.windowColumns + 1);
    final rowSpacing = rect.height / (house.windowRows + 1);
    final windowSize = Size(12, 14);
    final paint = Paint();

    for (int row = 0; row < house.windowRows; row++) {
      for (int col = 0; col < house.windowColumns; col++) {
        final center = Offset(
          rect.left + columnSpacing * (col + 1),
          rect.top + rowSpacing * (row + 1),
        );
        final windowRect = Rect.fromCenter(
          center: center,
          width: windowSize.width,
          height: windowSize.height,
        );
        final flicker =
            .5 +
            .5 * math.sin(time * 1.5 + seedBase * .6 + row * .9 + col * 1.2);
        final on = flicker > .25;
        paint.color =
            on
                ? const Color(0xFFFFF6C1).withValues(alpha: .85 + flicker * .15)
                : const Color(0xFF091321);
        canvas.drawRRect(
          RRect.fromRectAndRadius(windowRect, const Radius.circular(3)),
          paint,
        );
        seedBase++;
      }
    }
  }

  void _drawSmoke(Canvas canvas, Offset origin) {
    final smokePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: .15)
          ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final t = (time * .3 + i * .4) % 1;
      final offsetX = math.sin(time * .2 + i) * 6;
      final center = origin + Offset(offsetX, -t * 50 - i * 10);
      canvas.drawCircle(center, 10 - i * 2.0, smokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VillagePainter oldDelegate) =>
      oldDelegate.time != time;
}
