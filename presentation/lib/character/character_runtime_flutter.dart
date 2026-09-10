import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pure-Flutter character presentation runtime used during the functional
/// sprints. It deliberately uses procedural vector painting instead of final
/// authored artwork. The public contract is semantic character state, so the
/// eventual authored asset/runtime can replace this painter without changing
/// application/domain code.
class CharacterRuntimeView extends StatefulWidget {
  final String characterId;
  final String state;
  final bool reducedMotion;
  final double width;
  final double height;

  const CharacterRuntimeView({
    super.key,
    required this.characterId,
    required this.state,
    this.reducedMotion = false,
    this.width = 180,
    this.height = 240,
  });

  @override
  State<CharacterRuntimeView> createState() => _CharacterRuntimeViewState();
}

class _CharacterRuntimeViewState extends State<CharacterRuntimeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (!widget.reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CharacterRuntimeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion != oldWidget.reducedMotion) {
      if (widget.reducedMotion) {
        _controller.stop();
      } else {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identity = CharacterIdentities.resolve(widget.characterId);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Semantics(
        container: true,
        label: '${identity.displayName} character',
        value: widget.state.toUpperCase(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _CharacterPainter(
                characterId: widget.characterId,
                state: widget.state.toUpperCase(),
                progress: widget.reducedMotion ? 0.35 : _controller.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  final String characterId;
  final String state;
  final double progress;

  const _CharacterPainter({
    required this.characterId,
    required this.state,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = _CharacterStyle.forId(characterId);
    final t = progress * math.pi * 2;
    final statePulse = math.sin(t * 2) * 0.5 + 0.5;
    final breathe = state == 'IDLE' || state == 'WORK' || state == 'COMMUNICATE'
        ? math.sin(t) * 2.2
        : 0.0;
    final weight = state == 'WORK' || state == 'IDLE'
        ? math.sin(t * 0.5) * 3.0
        : 0.0;
    final attention = state == 'RECEIVE' || state == 'HANDOFF'
        ? math.sin(t) * 1.5
        : 0.0;
    final speaking = state == 'COMMUNICATE' ? math.sin(t * 3) * 2.0 : 0.0;

    final center = Offset(size.width / 2 + weight, size.height * 0.53);
    final scale = math.min(size.width / 238, size.height / 286);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale, scale);

    _drawGround(canvas, c, statePulse);
    _drawLegs(canvas, c, weight);
    _drawTorso(canvas, c, breathe);
    _drawArms(canvas, c, state, speaking, attention);
    _drawNeckAndHead(canvas, c, breathe, attention, speaking);
    _drawHair(canvas, c, breathe, attention);
    _drawAccessory(canvas, c, statePulse);
    _drawExpression(canvas, c, state, speaking, attention);

    canvas.restore();
  }

  void _drawGround(Canvas canvas, _CharacterStyle c, double pulse) {
    final paint = Paint()..color = c.accent.withValues(alpha: 0.08 + pulse * 0.04);
    canvas.drawOval(
      const Rect.fromCenter(center: Offset(0, 116), width: 126, height: 20),
      paint,
    );
  }

  void _drawLegs(Canvas canvas, _CharacterStyle c, double weight) {
    final paint = Paint()..color = c.trousers;
    final left = Path()
      ..moveTo(-25, 48)
      ..lineTo(-8, 48)
      ..lineTo(-12 + weight * 0.25, 102)
      ..lineTo(-31, 102)
      ..close();
    final right = Path()
      ..moveTo(8, 48)
      ..lineTo(25, 48)
      ..lineTo(31 - weight * 0.25, 102)
      ..lineTo(12, 102)
      ..close();
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);

    final shoe = Paint()..color = c.dark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-36 - weight * 0.25, 97, 28, 12),
        const Radius.circular(6),
      ),
      shoe,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8 + weight * 0.25, 97, 28, 12),
        const Radius.circular(6),
      ),
      shoe,
    );
  }

  void _drawTorso(Canvas canvas, _CharacterStyle c, double breathe) {
    final paint = Paint()..color = c.body;
    final body = Path()
      ..moveTo(-42, -36 + breathe * 0.2)
      ..quadraticBezierTo(0, -48 - breathe * 0.15, 42, -36 + breathe * 0.2)
      ..lineTo(31, 50)
      ..quadraticBezierTo(0, 61, -31, 50)
      ..close();
    canvas.drawPath(body, paint);

    final trim = Paint()
      ..color = c.accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, -36), const Offset(0, 42), trim);
  }

  void _drawArms(
    Canvas canvas,
    _CharacterStyle c,
    String currentState,
    double speaking,
    double attention,
  ) {
    final leftAngle = currentState == 'COMMUNICATE' ? -0.25 + speaking * 0.02 : -0.08;
    final rightAngle = currentState == 'WORK' ? 0.34 + speaking * 0.02 : 0.08 + attention * 0.02;
    _drawArm(canvas, c, -1, leftAngle);
    _drawArm(canvas, c, 1, rightAngle);
  }

  void _drawArm(Canvas canvas, _CharacterStyle c, int side, double angle) {
    canvas.save();
    canvas.translate(side * 39.0, -25);
    canvas.rotate(side * angle);
    final skin = Paint()..color = c.skin;
    final sleeve = Paint()..color = c.body;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -4, 16, 48),
        const Radius.circular(8),
      ),
      sleeve,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, 39, 14, 30),
        const Radius.circular(7),
      ),
      skin,
    );
    canvas.restore();
  }

  void _drawNeckAndHead(
    Canvas canvas,
    _CharacterStyle c,
    double breathe,
    double attention,
    double speaking,
  ) {
    final skin = Paint()..color = c.skin;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-12, -61 + breathe * 0.1, 24, 22),
        const Radius.circular(8),
      ),
      skin,
    );

    canvas.save();
    canvas.translate(attention * 0.5, -79 + breathe * 0.2);
    canvas.rotate(attention * 0.006);
    canvas.drawOval(const Rect.fromCenter(center: Offset(0, 0), width: 78, height: 86), skin);

    final face = Paint()..color = c.face;
    canvas.drawOval(const Rect.fromCenter(center: Offset(0, 3), width: 68, height: 77), face);
    canvas.restore();

    if (speaking.abs() > 0.4) {
      final mouth = Paint()..color = c.dark.withValues(alpha: 0.75);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(attention * 0.5, -72), width: 10 + speaking.abs(), height: 4),
        mouth,
      );
    }
  }

  void _drawHair(Canvas canvas, _CharacterStyle c, double breathe, double attention) {
    final paint = Paint()..color = c.hair;
    switch (c.hairStyle) {
      case 'bun':
        canvas.drawCircle(const Offset(-27, -112), 14, paint);
        canvas.drawCircle(const Offset(27, -112), 14, paint);
        canvas.drawOval(const Rect.fromCenter(center: Offset(0, -105), width: 75, height: 48), paint);
      case 'visor':
        canvas.drawOval(const Rect.fromCenter(center: Offset(0, -106), width: 82, height: 35), paint);
        final visor = Paint()..color = c.accent.withValues(alpha: 0.65);
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-31, -103, 62, 13), const Radius.circular(7)),
          visor,
        );
      case 'long':
        canvas.drawOval(const Rect.fromCenter(center: Offset(0, -104), width: 83, height: 43), paint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-39, -104, 16, 72), const Radius.circular(8)),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(23, -104, 16, 72), const Radius.circular(8)),
          paint,
        );
      case 'messy':
        final path = Path()..moveTo(-42, -92);
        for (var i = 0; i < 9; i++) {
          final x = -42.0 + i * 10.5;
          path.lineTo(x, -112 - math.sin(i + breathe * 0.15) * 7 - attention.abs());
        }
        path.lineTo(42, -86);
        path.lineTo(-42, -86);
        path.close();
        canvas.drawPath(path, paint);
      default:
        canvas.drawOval(const Rect.fromCenter(center: Offset(0, -104), width: 82, height: 42), paint);
    }
  }

  void _drawAccessory(Canvas canvas, _CharacterStyle c, double pulse) {
    if (c.accessory == 'notebook') {
      final paint = Paint()..color = c.accent;
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(42, -7, 20, 28), const Radius.circular(3)),
        paint,
      );
    } else if (c.accessory == 'headphones') {
      final paint = Paint()
        ..color = c.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawArc(const Rect.fromLTWH(-49, -125, 98, 64), math.pi, math.pi, false, paint);
      canvas.drawCircle(const Offset(-47, -91), 7, paint);
      canvas.drawCircle(const Offset(47, -91), 7, paint);
    } else if (c.accessory == 'orb') {
      final orb = Paint()..color = c.accent.withValues(alpha: 0.45 + pulse * 0.3);
      canvas.drawCircle(const Offset(58, -54), 10 + pulse * 2, orb);
    } else if (c.accessory == 'star') {
      final paint = Paint()..color = c.accent;
      final path = Path();
      for (var i = 0; i < 10; i++) {
        final radius = i.isEven ? 11.0 : 4.5;
        final angle = -math.pi / 2 + i * math.pi / 5;
        final point = Offset(53 + math.cos(angle) * radius, -48 + math.sin(angle) * radius);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawExpression(
    Canvas canvas,
    _CharacterStyle c,
    String currentState,
    double speaking,
    double attention,
  ) {
    final eye = Paint()..color = c.dark;
    final eyeY = -78 + attention * 0.2;
    canvas.drawOval(Rect.fromCenter(center: Offset(-15, eyeY), width: 5, height: currentState == 'WARNING' ? 7 : 5), eye);
    canvas.drawOval(Rect.fromCenter(center: Offset(15, eyeY), width: 5, height: currentState == 'WARNING' ? 7 : 5), eye);

    if (currentState == 'WARNING') {
      final brow = Paint()
        ..color = c.dark
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-22, -89), const Offset(-9, -92), brow);
      canvas.drawLine(const Offset(9, -92), const Offset(22, -89), brow);
    }

    if (currentState == 'COMPLETE') {
      final smile = Paint()
        ..color = c.dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(const Rect.fromLTWH(-12, -77, 24, 18), 0.2, math.pi - 0.4, false, smile);
    }

    if (currentState == 'RECEIVE' || currentState == 'HANDOFF') {
      final focus = Paint()
        ..color = c.accent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(const Offset(0, -78), 34 + attention.abs(), focus);
    }

    if (speaking.abs() > 1.0) {
      final bubble = Paint()..color = c.accent.withValues(alpha: 0.18);
      canvas.drawCircle(const Offset(47, -117), 4 + speaking.abs(), bubble);
      canvas.drawCircle(const Offset(57, -124), 3 + speaking.abs() * 0.5, bubble);
    }
  }

  @override
  bool shouldRepaint(covariant _CharacterPainter oldDelegate) =>
      oldDelegate.characterId != characterId ||
      oldDelegate.state != state ||
      oldDelegate.progress != progress;
}

class _CharacterStyle {
  final Color skin;
  final Color face;
  final Color body;
  final Color trousers;
  final Color hair;
  final Color accent;
  final Color dark;
  final String hairStyle;
  final String accessory;

  const _CharacterStyle({
    required this.skin,
    required this.face,
    required this.body,
    required this.trousers,
    required this.hair,
    required this.accent,
    required this.dark,
    required this.hairStyle,
    required this.accessory,
  });

  static _CharacterStyle forId(String id) {
    switch (id.trim().toLowerCase()) {
      case 'dharen':
        return const _CharacterStyle(
          skin: Color(0xffc98964), face: Color(0xffffd7bc), body: Color(0xff8b5e3c),
          trousers: Color(0xff403d46), hair: Color(0xff34251f), accent: Color(0xffd98b43),
          dark: Color(0xff201b1a), hairStyle: 'messy', accessory: 'notebook',
        );
      case 'syvax':
        return const _CharacterStyle(
          skin: Color(0xffb87c63), face: Color(0xffffd4bd), body: Color(0xff344d63),
          trousers: Color(0xff252d36), hair: Color(0xff17232e), accent: Color(0xff62d8f5),
          dark: Color(0xff14202a), hairStyle: 'visor', accessory: 'headphones',
        );
      case 'sandre':
        return const _CharacterStyle(
          skin: Color(0xffa96f58), face: Color(0xffffcbb5), body: Color(0xff496d6d),
          trousers: Color(0xff343f43), hair: Color(0xff2d2522), accent: Color(0xff63b9a8),
          dark: Color(0xff1d2527), hairStyle: 'long', accessory: 'notebook',
        );
      case 'kaelen':
        return const _CharacterStyle(
          skin: Color(0xffbd805e), face: Color(0xffffd1b8), body: Color(0xff50575f),
          trousers: Color(0xff20252a), hair: Color(0xff1d1b1b), accent: Color(0xfff19a3e),
          dark: Color(0xff17191c), hairStyle: 'messy', accessory: 'headphones',
        );
      case 'anuka':
        return const _CharacterStyle(
          skin: Color(0xffd69a79), face: Color(0xffffdfcf), body: Color(0xfff0b9c8),
          trousers: Color(0xff343044), hair: Color(0xff2a2025), accent: Color(0xffbd7fe4),
          dark: Color(0xff221b27), hairStyle: 'bun', accessory: 'orb',
        );
      case 'vivren':
        return const _CharacterStyle(
          skin: Color(0xffc7957e), face: Color(0xffffd8c7), body: Color(0xffd5d0dc),
          trousers: Color(0xff36333e), hair: Color(0xffc8bdd9), accent: Color(0xffa68ad7),
          dark: Color(0xff26222d), hairStyle: 'long', accessory: 'notebook',
        );
      case 'tarkis':
        return const _CharacterStyle(
          skin: Color(0xffa96f56), face: Color(0xffffcdb6), body: Color(0xff34383f),
          trousers: Color(0xff171a1e), hair: Color(0xff171719), accent: Color(0xffee8b31),
          dark: Color(0xff111214), hairStyle: 'messy', accessory: 'star',
        );
      default:
        return const _CharacterStyle(
          skin: Color(0xffb98068), face: Color(0xffffd5c0), body: Color(0xff59636d),
          trousers: Color(0xff30343a), hair: Color(0xff24272b), accent: Color(0xff7aa9d8),
          dark: Color(0xff17191c), hairStyle: 'messy', accessory: 'notebook',
        );
    }
  }
}

class CharacterIdentity {
  final String id;
  final String displayName;
  final String role;

  const CharacterIdentity({
    required this.id,
    required this.displayName,
    required this.role,
  });
}

class CharacterIdentities {
  CharacterIdentities._();

  static const Map<String, CharacterIdentity> all = {
    'dharen': CharacterIdentity(id: 'dharen', displayName: 'Dharen', role: 'Context Architecture'),
    'vivren': CharacterIdentity(id: 'vivren', displayName: 'Vivren', role: 'Discernment'),
    'tarkis': CharacterIdentity(id: 'tarkis', displayName: 'Tarkis', role: 'Hypothesis + Evidence'),
    'sandre': CharacterIdentity(id: 'sandre', displayName: 'Sandre', role: 'Data Stewardship'),
    'pramon': CharacterIdentity(id: 'pramon', displayName: 'Pramon', role: 'Proof'),
    'syvax': CharacterIdentity(id: 'syvax', displayName: 'Syvax', role: 'Dialogue + Orchestration'),
    'bodhex': CharacterIdentity(id: 'bodhex', displayName: 'Bodhex', role: 'Insight'),
    'medrus': CharacterIdentity(id: 'medrus', displayName: 'Medrus', role: 'Knowledge'),
    'epistre': CharacterIdentity(id: 'epistre', displayName: 'Epistre', role: 'Transfer'),
    'manis': CharacterIdentity(id: 'manis', displayName: 'Manis', role: 'Deliberation'),
    'anuka': CharacterIdentity(id: 'anuka', displayName: 'Anuka', role: 'Adaptive Context'),
    'veridat': CharacterIdentity(id: 'veridat', displayName: 'Veridat', role: 'Verification'),
    'viveda': CharacterIdentity(id: 'viveda', displayName: 'Viveda', role: 'Knowledge Delivery'),
    'kaelen': CharacterIdentity(id: 'kaelen', displayName: 'Kaelen', role: 'Build + Experimentation'),
    'anukor': CharacterIdentity(id: 'anukor', displayName: 'Anukor', role: 'Context Transfer'),
  };

  static CharacterIdentity resolve(String id) =>
      all[id.trim().toLowerCase()] ??
      CharacterIdentity(id: id, displayName: id, role: 'Criterivox Agent');
}
