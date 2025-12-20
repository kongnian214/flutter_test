import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/blessing_message.dart';

class MagicDustLayer extends StatelessWidget {
  final double time;
  final bool enabled;
  final BlessingMessage message;

  const MagicDustLayer({
    super.key,
    required this.time,
    required this.enabled,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: enabled ? 1 : 0,
          child: CustomPaint(
            painter: _MagicDustPainter(time, message),
          ),
        ),
      ),
    );
  }
}

class _MagicDustPainter extends CustomPainter {
  final double time;
  final BlessingMessage message;

  _MagicDustPainter(this.time, this.message);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final random = math.Random(912);
    final paint = Paint();
    const count = 160;
    for (int i = 0; i < count; i++) {
      final seed = random.nextDouble();
      final orbitRadius = size.width * (.1 + seed * .4);
      final orbitSpeed = (.5 + seed) * .6;
      final orbitAngle = time * orbitSpeed + seed * math.pi * 2;
      final center = Offset(size.width * .5, size.height * .45);
      final position =
          center +
          Offset(math.cos(orbitAngle), math.sin(orbitAngle)) * orbitRadius;
      final sparkle = (math.sin(time * 4 + i) + 1) / 2;
      final color =
          Color.lerp(const Color(0xFFFFF1B5), const Color(0xFFFF80F2), seed)!;
      paint.color = color.withValues(alpha: .3 + sparkle * .7);
      canvas.drawCircle(position, 1.5 + sparkle * 2.5, paint);
    }

    final messagePainter = TextPainter(
      textDirection: TextDirection.ltr,
      ellipsis: '…',
      maxLines: 4,
    );
    final headlineStyle = TextStyle(
      color: Colors.white.withValues(alpha: .6 + math.sin(time * .5) * .2),
      fontSize: 20,
      letterSpacing: 1.4,
    );
    final bodyStyle = TextStyle(
      color: Colors.white.withValues(alpha: .85),
      fontSize: 30,
      fontWeight: FontWeight.w600,
      height: 1.3,
    );
    final signatureStyle = TextStyle(
      color: Colors.white.withValues(alpha: .65),
      fontSize: 18,
      letterSpacing: 1.2,
    );
    final maxWidth = size.width * .8;
    final bodySpan = TextSpan(
      text: '${message.headline}\n',
      style: headlineStyle,
      children: [
        TextSpan(text: '${message.content}\n', style: bodyStyle),
        TextSpan(text: message.signatureLine, style: signatureStyle),
      ],
    );
    messagePainter
      ..text = bodySpan
      ..textAlign = TextAlign.center
      ..layout(maxWidth: maxWidth);
    final offset = Offset(
      (size.width - messagePainter.width) / 2,
      size.height * .48 - messagePainter.height / 2,
    );
    messagePainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _MagicDustPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.message != message;
}
