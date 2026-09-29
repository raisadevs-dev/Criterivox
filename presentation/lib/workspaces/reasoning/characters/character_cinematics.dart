import 'dart:math' as math;

import 'package:flutter/material.dart';

enum S7CharacterState {
  idle,
  receive,
  work,
  communicate,
  handoff,
  complete,
}

class S7CharacterCinematics extends StatefulWidget {
  final String character;
  final S7CharacterState state;

  const S7CharacterCinematics({
    super.key,
    required this.character,
    required this.state,
  });

  @override
  State<S7CharacterCinematics> createState() => _S7CharacterCinematicsState();
}

class _S7CharacterCinematicsState extends State<S7CharacterCinematics>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _CharacterPainter(
            widget.character,
            widget.state,
            _controller.value,
          ),
          size: const Size(220, 260),
        );
      },
    );
  }
}

class _CharacterPainter extends CustomPainter {
  final String character;
  final S7CharacterState state;
  final double t;

  _CharacterPainter(
    this.character,
    this.state,
    this.t,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final bool vivren = character.toLowerCase() == 'vivren';

    final Color accent =
        vivren ? const Color(0xffb9a4ff) : const Color(0xffffbd72);

    final double pulse = 1.0 + 0.025 * math.sin(t * math.pi * 2.0);

    final Offset center = Offset(
      size.width / 2.0,
      size.height * 0.46,
    );

    final Paint aura = Paint()
      ..color = accent.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        24,
      );

    canvas.drawCircle(
      center,
      72.0 * pulse,
      aura,
    );

    final Paint body = Paint()
      ..color = accent.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, 38),
          width: 74.0,
          height: 110.0,
        ),
        const Radius.circular(28),
      ),
      body,
    );

    final Paint line = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(
      center.translate(0, -18),
      29.0,
      line,
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: center.translate(0, 20),
        width: 92.0,
        height: 125.0,
      ),
      math.pi * 0.15,
      math.pi * 0.7,
      false,
      line,
    );

    final bool isWorking =
        state == S7CharacterState.work || state == S7CharacterState.receive;

    final double motion = isWorking ? math.sin(t * math.pi * 4.0) * 8.0 : 0.0;

    canvas.drawLine(
      center.translate(-46, motion),
      center.translate(-70, 22.0 + motion),
      line,
    );

    canvas.drawLine(
      center.translate(46, motion),
      center.translate(70, 22.0 - motion),
      line,
    );

    final Paint eye = Paint()..color = accent;

    canvas.drawCircle(
      center.translate(-10, -18),
      3.0,
      eye,
    );

    canvas.drawCircle(
      center.translate(10, -18),
      3.0,
      eye,
    );

    final TextPainter label = TextPainter(
      text: TextSpan(
        text: vivren ? 'VIVREN' : 'TARKIS',
        style: TextStyle(
          color: accent,
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    label.paint(
      canvas,
      Offset(
        (size.width - label.width) / 2.0,
        size.height - 24.0,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CharacterPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.state != state ||
        oldDelegate.character != character;
  }
}
