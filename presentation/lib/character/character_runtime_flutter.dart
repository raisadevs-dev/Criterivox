import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'character_visual_profile.dart';

/// Primary procedural character renderer.
/// CharacterVisualProfile is the single source of visual identity. This
/// renderer contains drawing behavior only and never owns per-character
/// colors, clothing, hair, or accessory definitions.
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
    if (widget.reducedMotion) {
      _controller.stop();
    } else if (oldWidget.reducedMotion) {
      _controller.repeat();
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
    final profile = CharacterVisualProfile.forId(widget.characterId);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Semantics(
        container: true,
        label: '${identity.displayName} character',
        value: widget.state.toUpperCase(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            painter: _CharacterPainter(
              profile: profile,
              state: widget.state.toUpperCase(),
              progress: widget.reducedMotion ? .35 : _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  final CharacterVisualProfile? profile;
  final String state;
  final double progress;

  const _CharacterPainter({
    required this.profile,
    required this.state,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final character = profile;
    if (character == null) {
      return;
    }

    final t = progress * math.pi * 2;
    final breathe =
        (state == 'IDLE' || state == 'WORK' || state == 'COMMUNICATE')
            ? math.sin(t) * 2.2
            : 0.0;
    final weight = (state == 'WORK' || state == 'IDLE')
        ? math.sin(t * .5) * 3.0
        : 0.0;
    final attention = (state == 'RECEIVE' || state == 'HANDOFF')
        ? math.sin(t) * 1.5
        : 0.0;
    final gesture = state == 'COMMUNICATE' ? math.sin(t * 2.2) : 0.0;
    final pulse = math.sin(t * 2) * .5 + .5;
    final scale = math.min(size.width / 238.0, size.height / 286.0).toDouble();

    canvas.save();
    canvas.translate(size.width / 2 + weight, size.height * .53);
    canvas.scale(scale);

    _ground(canvas, character, pulse);
    _legs(canvas, character, weight);
    _torso(canvas, character, breathe);
    _arms(canvas, character, state, gesture, attention);
    _head(canvas, character, breathe, attention, gesture);
    _hair(canvas, character, t, breathe, attention);
    _clothingDetails(canvas, character, state, breathe);
    _accessory(canvas, character, state, t, pulse);
    _face(canvas, character, state, gesture, attention);

    canvas.restore();
  }

  void _ground(Canvas canvas, CharacterVisualProfile character, double pulse) {
    final paint = Paint()
      ..color = character.accent.withValues(alpha: .07 + pulse * .04);
    canvas.drawOval(
      const Rect.fromCenter(center: Offset(0, 116), width: 126, height: 20),
      paint,
    );
  }

  void _legs(Canvas canvas, CharacterVisualProfile character, double weight) {
    final trousers = Paint()..color = character.trousers;
    final left = Path()
      ..moveTo(-25, 48)
      ..lineTo(-8, 48)
      ..lineTo(-12 + weight * .25, 102)
      ..lineTo(-31, 102)
      ..close();
    final right = Path()
      ..moveTo(8, 48)
      ..lineTo(25, 48)
      ..lineTo(31 - weight * .25, 102)
      ..lineTo(12, 102)
      ..close();

    canvas.drawPath(left, trousers);
    canvas.drawPath(right, trousers);

    final shoe = Paint()..color = character.dark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-36 - weight * .25, 97, 28, 13),
        const Radius.circular(6),
      ),
      shoe,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8 + weight * .25, 97, 28, 13),
        const Radius.circular(6),
      ),
      shoe,
    );
  }

  void _torso(Canvas canvas, CharacterVisualProfile character, double breathe) {
    final bodyPaint = Paint()..color = character.body;
    final body = Path()
      ..moveTo(-42, -36 + breathe * .2)
      ..quadraticBezierTo(0, -48 - breathe * .15, 42, -36 + breathe * .2)
      ..lineTo(31, 50)
      ..quadraticBezierTo(0, 61, -31, 50)
      ..close();
    canvas.drawPath(body, bodyPaint);

    final trim = Paint()
      ..color = character.accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, -36), const Offset(0, 42), trim);
  }

  void _arms(
    Canvas canvas,
    CharacterVisualProfile character,
    String state,
    double gesture,
    double attention,
  ) {
    final left = state == 'COMMUNICATE'
        ? -.28 + gesture * .16
        : state == 'HANDOFF'
            ? -.32
            : -.08;
    final right = state == 'WORK'
        ? .35 + gesture * .12
        : state == 'COMMUNICATE'
            ? .25 + gesture * .12
            : .08 + attention * .02;

    _arm(canvas, character, -1, left, state, gesture);
    _arm(canvas, character, 1, right, state, gesture);
  }

  void _arm(
    Canvas canvas,
    CharacterVisualProfile character,
    int side,
    double angle,
    String state,
    double gesture,
  ) {
    canvas.save();
    canvas.translate(side * 39.0, -25.0);
    canvas.rotate(side * angle);

    final sleeve = Paint()..color = character.body;
    final skin = Paint()..color = character.skin;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -4, 16, 43),
        const Radius.circular(8),
      ),
      sleeve,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, 36, 14, 27),
        const Radius.circular(7),
      ),
      skin,
    );

    final handY = 63.0 + (state == 'COMMUNICATE' ? gesture * 3.0 : 0.0);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, handY), width: 13, height: 10),
      skin,
    );

    if (state == 'COMMUNICATE') {
      final finger = Paint()
        ..color = character.skin
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        const Offset(0, 64),
        Offset(side * 3.0, 74.0 + gesture * 2.0),
        finger,
      );
    }

    canvas.restore();
  }

  void _head(
    Canvas canvas,
    CharacterVisualProfile character,
    double breathe,
    double attention,
    double gesture,
  ) {
    final skin = Paint()..color = character.skin;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-12, -61 + breathe * .1, 24, 22),
        const Radius.circular(8),
      ),
      skin,
    );

    canvas.save();
    canvas.translate(attention * .5, -79 + breathe * .2);
    canvas.rotate(attention * .006 + gesture * .006);
    canvas.drawOval(
      const Rect.fromCenter(center: Offset(0, 0), width: 78, height: 86),
      skin,
    );
    canvas.drawOval(
      const Rect.fromCenter(center: Offset(0, 3), width: 68, height: 77),
      Paint()..color = character.face,
    );
    canvas.restore();
  }

  void _hair(
    Canvas canvas,
    CharacterVisualProfile character,
    double time,
    double breathe,
    double attention,
  ) {
    final paint = Paint()..color = character.hair;
    final sway = math.sin(time) * 1.8 + attention * .4;

    switch (character.hairStyle) {
      case CharacterHairStyle.bun:
        canvas.drawCircle(Offset(-27 + sway, -112), 14, paint);
        canvas.drawCircle(Offset(27 + sway, -112), 14, paint);
        canvas.drawOval(
          const Rect.fromCenter(center: Offset(0, -105), width: 75, height: 48),
          paint,
        );
      case CharacterHairStyle.visor:
        canvas.drawOval(
          const Rect.fromCenter(center: Offset(0, -106), width: 82, height: 35),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-31, -103, 62, 13),
            const Radius.circular(7),
          ),
          Paint()..color = character.accent.withValues(alpha: .65),
        );
      case CharacterHairStyle.longHair:
        canvas.drawOval(
          const Rect.fromCenter(center: Offset(0, -104), width: 83, height: 43),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-39 + sway, -104, 16, 72),
            const Radius.circular(8),
          ),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(23 + sway, -104, 16, 72),
            const Radius.circular(8),
          ),
          paint,
        );
      case CharacterHairStyle.messy:
        final path = Path()..moveTo(-42, -92);
        for (var i = 0; i < 9; i++) {
          final x = -42.0 + i * 10.5;
          path.lineTo(x, -112 - math.sin(i + time * .18) * 7 - attention.abs());
        }
        path
          ..lineTo(42, -86)
          ..lineTo(-42, -86)
          ..close();
        canvas.drawPath(path, paint);
      default:
        canvas.drawOval(
          const Rect.fromCenter(center: Offset(0, -104), width: 82, height: 42),
          paint,
        );
    }
  }

  void _clothingDetails(
    Canvas canvas,
    CharacterVisualProfile character,
    String state,
    double breathe,
  ) {
    final line = Paint()
      ..color = character.accent.withValues(alpha: .8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    switch (character.clothing) {
      case CharacterClothing.jacket:
        canvas.drawLine(const Offset(-31, -30), const Offset(-24, 42), line);
        canvas.drawLine(const Offset(31, -30), const Offset(24, 42), line);
      case CharacterClothing.collar:
        final paint = Paint()..color = character.accent;
        final left = Path()
          ..moveTo(-18, -38)
          ..lineTo(-3, -25)
          ..lineTo(-13, -18)
          ..close();
        final right = Path()
          ..moveTo(18, -38)
          ..lineTo(3, -25)
          ..lineTo(13, -18)
          ..close();
        canvas.drawPath(left, paint);
        canvas.drawPath(right, paint);
      case CharacterClothing.hoodie:
        canvas.drawArc(
          const Rect.fromLTWH(-32, -51, 64, 42),
          math.pi,
          math.pi,
          false,
          line,
        );
      case CharacterClothing.utility:
        canvas.drawLine(const Offset(-31, -30), const Offset(-24, 42), line);
        canvas.drawLine(const Offset(31, -30), const Offset(24, 42), line);
        canvas.drawRect(const Rect.fromLTWH(-25, -2, 15, 18), line);
        canvas.drawRect(const Rect.fromLTWH(10, -2, 15, 18), line);
      case CharacterClothing.layered:
        canvas.drawArc(
          const Rect.fromLTWH(-34, -48, 68, 50),
          0,
          math.pi,
          false,
          line,
        );
        canvas.drawLine(const Offset(-28, -28), const Offset(-23, 40), line);
        canvas.drawLine(const Offset(28, -28), const Offset(23, 40), line);
    }
  }

  void _accessory(
    Canvas canvas,
    CharacterVisualProfile character,
    String state,
    double time,
    double pulse,
  ) {
    final bob = math.sin(time * 1.5) * 2.0;

    switch (character.accessory) {
      case CharacterAccessory.notebook:
        final paint = Paint()..color = character.accent;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(42, -7 + bob, 22, 29),
            const Radius.circular(3),
          ),
          paint,
        );
        canvas.drawLine(
          Offset(47, -2 + bob),
          Offset(59, -2 + bob),
          Paint()
            ..color = character.dark
            ..strokeWidth = 1.5,
        );
      case CharacterAccessory.headphones:
        final paint = Paint()
          ..color = character.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawArc(
          const Rect.fromLTWH(-49, -125, 98, 64),
          math.pi,
          math.pi,
          false,
          paint,
        );
        canvas.drawCircle(const Offset(-47, -91), 7, paint);
        canvas.drawCircle(const Offset(47, -91), 7, paint);
      case CharacterAccessory.orb:
        final paint = Paint()
          ..color = character.accent.withValues(alpha: .42 + pulse * .3);
        canvas.drawCircle(Offset(58, -54 + bob), 10 + pulse * 2, paint);
      case CharacterAccessory.badge:
        canvas.drawCircle(
          Offset(27, 2 + bob),
          8,
          Paint()..color = character.accent,
        );
      case CharacterAccessory.none:
        break;
    }
  }

  void _face(
    Canvas canvas,
    CharacterVisualProfile character,
    String state,
    double gesture,
    double attention,
  ) {
    final eye = Paint()..color = character.dark;
    final y = -78 + attention * .2;
    final blink = math.sin(progress * math.pi * 4).abs() > .985;

    if (!blink) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(-15, y), width: 5, height: state == 'WARNING' ? 7 : 5),
        eye,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(15, y), width: 5, height: state == 'WARNING' ? 7 : 5),
        eye,
      );
    }

    if (state == 'WARNING') {
      final paint = Paint()
        ..color = character.dark
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-22, -89), const Offset(-9, -92), paint);
      canvas.drawLine(const Offset(9, -92), const Offset(22, -89), paint);
    }

    if (state == 'COMPLETE') {
      final paint = Paint()
        ..color = character.dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(
        const Rect.fromLTWH(-12, -77, 24, 18),
        .2,
        math.pi - .4,
        false,
        paint,
      );
    }

    if (state == 'RECEIVE' || state == 'HANDOFF') {
      canvas.drawCircle(
        const Offset(0, -78),
        34 + attention.abs(),
        Paint()
          ..color = character.accent.withValues(alpha: .28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (state == 'COMMUNICATE') {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -70),
          width: 9 + gesture.abs() * 4,
          height: 3 + gesture.abs(),
        ),
        Paint()..color = character.dark.withValues(alpha: .7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CharacterPainter old) {
    return old.profile?.characterId != profile?.characterId ||
        old.state != state ||
        old.progress != progress;
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
    'dharen': CharacterIdentity(
      id: 'dharen',
      displayName: 'Dharen',
      role: 'Context Architecture',
    ),
    'vivren': CharacterIdentity(
      id: 'vivren',
      displayName: 'Vivren',
      role: 'Discernment',
    ),
    'tarkis': CharacterIdentity(
      id: 'tarkis',
      displayName: 'Tarkis',
      role: 'Hypothesis + Evidence',
    ),
    'sandre': CharacterIdentity(
      id: 'sandre',
      displayName: 'Sandre',
      role: 'Data Stewardship',
    ),
    'pramon': CharacterIdentity(
      id: 'pramon',
      displayName: 'Pramon',
      role: 'Proof',
    ),
    'syvax': CharacterIdentity(
      id: 'syvax',
      displayName: 'Syvax',
      role: 'Dialogue + Orchestration',
    ),
    'bodhex': CharacterIdentity(
      id: 'bodhex',
      displayName: 'Bodhex',
      role: 'Insight',
    ),
    'medrus': CharacterIdentity(
      id: 'medrus',
      displayName: 'Medrus',
      role: 'Knowledge',
    ),
    'epistre': CharacterIdentity(
      id: 'epistre',
      displayName: 'Epistre',
      role: 'Transfer',
    ),
    'manis': CharacterIdentity(
      id: 'manis',
      displayName: 'Manis',
      role: 'Deliberation',
    ),
    'anuka': CharacterIdentity(
      id: 'anuka',
      displayName: 'Anuka',
      role: 'Adaptive Context',
    ),
    'veridat': CharacterIdentity(
      id: 'veridat',
      displayName: 'Veridat',
      role: 'Verification',
    ),
    'viveda': CharacterIdentity(
      id: 'viveda',
      displayName: 'Viveda',
      role: 'Knowledge Delivery',
    ),
    'kaelen': CharacterIdentity(
      id: 'kaelen',
      displayName: 'Kaelen',
      role: 'Build + Experimentation',
    ),
    'anukor': CharacterIdentity(
      id: 'anukor',
      displayName: 'Anukor',
      role: 'Context Transfer',
    ),
  };

  static CharacterIdentity resolve(String id) {
    return all[id.trim().toLowerCase()] ??
        CharacterIdentity(
          id: id,
          displayName: id,
          role: 'Criterivox Agent',
        );
  }
}
