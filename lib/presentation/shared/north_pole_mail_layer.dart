import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/blessing_message.dart';

/// Animated mail envelopes drifting down with fox trails referencing North Pole Mail.
class NorthPoleMailLayer extends StatefulWidget {
  const NorthPoleMailLayer({
    super.key,
    required this.time,
    this.enabled = true,
    required this.messages,
    required this.featured,
    required this.messageRevision,
  });

  final double time;
  final bool enabled;
  final List<BlessingMessage> messages;
  final BlessingMessage featured;
  final int messageRevision;

  @override
  State<NorthPoleMailLayer> createState() => _NorthPoleMailLayerState();
}

class _NorthPoleMailLayerState extends State<NorthPoleMailLayer> {
  final math.Random _random = math.Random();
  final List<_MailParticle> _mails = [];
  double _lastSpawn = 0;
  int _cycleIndex = 0;

  @override
  void didUpdateWidget(NorthPoleMailLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time) {
      final cutoff = widget.time - 6;
      _mails.removeWhere((mail) => mail.startTime < cutoff);
      if (widget.enabled && widget.time - _lastSpawn > 1.8) {
        _spawnMail();
        _lastSpawn = widget.time;
      }
    }
    if (widget.enabled &&
        widget.messageRevision != oldWidget.messageRevision) {
      _spawnMail(forceMessage: widget.featured);
    }
  }

  void _spawnMail({BlessingMessage? forceMessage}) {
    final pool = widget.messages.isNotEmpty
        ? widget.messages
        : <BlessingMessage>[widget.featured];
    final message =
        forceMessage ??
        pool[_cycleIndex++ % pool.length];
    _mails.add(
      _MailParticle(
        startTime: widget.time,
        x: _random.nextDouble(),
        wobble: _random.nextDouble() * 0.6 + 0.2,
        foxTrail: _random.nextBool(),
        message: message,
        highlight: forceMessage != null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();
    return RepaintBoundary(
      child: CustomPaint(
        painter: _MailPainter(
          time: widget.time,
          mails: List.unmodifiable(_mails),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _MailPainter extends CustomPainter {
  _MailPainter({required this.time, required this.mails});

  final double time;
  final List<_MailParticle> mails;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSnowGlow(canvas, size);
    for (final mail in mails) {
      _drawEnvelope(canvas, size, mail);
      if (mail.foxTrail) {
        _drawFoxTrail(canvas, size, mail);
      }
    }
  }

  void _drawSnowGlow(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFD0F1FF).withValues(alpha: .15),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height * .3),
              radius: size.width * .6,
            ),
          );
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawEnvelope(Canvas canvas, Size size, _MailParticle mail) {
    final age = time - mail.startTime;
    final progress = (age / 6).clamp(0.0, 1.0);
    final x =
        size.width * mail.x +
        math.sin(progress * math.pi * 2) * 40 * mail.wobble;
    final y = -60 + progress * (size.height + 120);
    final rotation = math.sin(progress * math.pi) * 0.4;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);
    final rect = Rect.fromCenter(center: Offset.zero, width: 80, height: 50);
    final paint =
        Paint()
          ..color = const Color(
            0xFFFDF7ED,
          ).withValues(alpha: 1 - progress * .1);
    if (mail.highlight) {
      final glow =
          Paint()
            ..shader = RadialGradient(
              colors: [
                const Color(0xFFFFF0C2).withValues(alpha: .5),
                Colors.transparent,
              ],
            ).createShader(rect.inflate(16));
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(12), const Radius.circular(12)),
        glow,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
    final fold =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFE0C2A2);
    canvas.drawLine(
      Offset(-rect.width / 2, 0),
      Offset(rect.width / 2, 0),
      fold,
    );
    canvas.drawLine(
      Offset(-rect.width / 2, 0),
      Offset(0, rect.height / 2),
      fold,
    );
    canvas.drawLine(
      Offset(rect.width / 2, 0),
      Offset(0, rect.height / 2),
      fold,
    );
    final stampPaint = Paint()..color = const Color(0xFFEE6C4D);
    canvas.drawCircle(
      Offset(rect.width / 2 - 12, -rect.height / 2 + 12),
      8,
      stampPaint,
    );
    _drawMessageLabel(canvas, rect, mail.message);
    canvas.restore();
  }

  void _drawMessageLabel(Canvas canvas, Rect rect, BlessingMessage message) {
    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 4,
      ellipsis: '…',
    );
    painter.text = TextSpan(
      text: '${message.headline}\n',
      style: const TextStyle(
        color: Color(0xFFB07D4D),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      children: [
        TextSpan(
          text: message.content,
          style: const TextStyle(
            color: Color(0xFF5B4533),
            fontSize: 11,
          ),
        ),
        TextSpan(
          text: '\n${message.signatureLine}',
          style: const TextStyle(
            color: Color(0xFF7C5944),
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
    painter.layout(maxWidth: rect.width - 18);
    painter.paint(
      canvas,
      Offset(-rect.width / 2 + 9, -rect.height / 2 + 6),
    );
  }

  void _drawFoxTrail(Canvas canvas, Size size, _MailParticle mail) {
    final age = time - mail.startTime;
    final progress = (age / 6).clamp(0.0, 1.0);
    final path = Path();
    final x = size.width * mail.x;
    final startY = -40 + progress * size.height * .6;
    path.moveTo(x - 20, startY);
    path.quadraticBezierTo(x - 60, startY + 60, x - 10, startY + 120);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(
            0xFFFFD07A,
          ).withValues(alpha: (1 - progress) * .6);
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(x - 5, startY + 120),
      10,
      Paint()
        ..color = const Color(0xFFFFA45C).withValues(alpha: (1 - progress)),
    );
  }

  @override
  bool shouldRepaint(covariant _MailPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.mails != mails;
  }
}

class _MailParticle {
  _MailParticle({
    required this.startTime,
    required this.x,
    required this.wobble,
    required this.foxTrail,
    required this.message,
    required this.highlight,
  });

  final double startTime;
  final double x;
  final double wobble;
  final bool foxTrail;
  final BlessingMessage message;
  final bool highlight;
}
