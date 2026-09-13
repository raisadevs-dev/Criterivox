import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:presentation/character/character_identity.dart';

/// Flutter-side visual runtime for a Criterivox character.
///
/// This class is intentionally presentation-only:
/// - Character identity comes from CharacterIdentities.
/// - Runtime truth/state is supplied through [characterId] and [state].
/// - Rendering is performed entirely by Flutter's CustomPainter.
/// - No computational or persistence responsibilities live here.
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
    this.width = 180.0,
    this.height = 240.0,
  });

  @override
  State<CharacterRuntimeView> createState() =>
      _CharacterRuntimeViewState();
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
    final normalizedState = widget.state.trim().toUpperCase();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Semantics(
        container: true,
        label: '${identity.displayName} character',
        value: normalizedState,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _CharacterPainter(
                characterId: widget.characterId,
                state: normalizedState,
                progress: widget.reducedMotion
                    ? 0.35
                    : _controller.value,
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
    final character = _CharacterStyle.forId(characterId);

    final double t = progress * math.pi * 2.0;

    final double breathe = _isBreathingState(state)
        ? math.sin(t) * 2.2
        : 0.0;

    final double weight =
        (state == 'WORK' || state == 'IDLE')
            ? math.sin(t * 0.5) * 3.0
            : 0.0;

    final double attention =
        (state == 'RECEIVE' || state == 'HANDOFF')
            ? math.sin(t) * 1.5
            : 0.0;

    final double gesture =
        state == 'COMMUNICATE'
            ? math.sin(t * 2.2)
            : 0.0;

    final double pulse = math.sin(t * 2.0) * 0.5 + 0.5;

    final double scale = math.min(
      size.width / 238.0,
      size.height / 286.0,
    );

    canvas.save();

    canvas.translate(
      size.width / 2.0 + weight,
      size.height * 0.53,
    );

    canvas.scale(scale);

    _ground(canvas, character, pulse);
    _legs(canvas, character, weight);
    _torso(canvas, character, breathe);
    _arms(
      canvas,
      character,
      state,
      gesture,
      attention,
    );
    _head(
      canvas,
      character,
      breathe,
      attention,
      gesture,
    );
    _hair(
      canvas,
      character,
      t,
      breathe,
      attention,
    );
    _clothingDetails(
      canvas,
      character,
      state,
      breathe,
    );
    _accessory(
      canvas,
      character,
      state,
      t,
      pulse,
    );
    _face(
      canvas,
      character,
      state,
      gesture,
      attention,
    );

    canvas.restore();
  }

  bool _isBreathingState(String value) {
    return value == 'IDLE' ||
        value == 'WORK' ||
        value == 'COMMUNICATE';
  }

  void _ground(
    Canvas canvas,
    _CharacterStyle character,
    double pulse,
  ) {
    final paint = Paint()
      ..color = character.accent.withValues(
        alpha: 0.07 + pulse * 0.04,
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0.0, 116.0),
        width: 126.0,
        height: 20.0,
      ),
      paint,
    );
  }

  void _legs(
    Canvas canvas,
    _CharacterStyle character,
    double weight,
  ) {
    final trousers = Paint()
      ..color = character.trousers;

    final leftLeg = Path()
      ..moveTo(-25.0, 48.0)
      ..lineTo(-8.0, 48.0)
      ..lineTo(-12.0 + weight * 0.25, 102.0)
      ..lineTo(-31.0, 102.0)
      ..close();

    final rightLeg = Path()
      ..moveTo(8.0, 48.0)
      ..lineTo(25.0, 48.0)
      ..lineTo(31.0 - weight * 0.25, 102.0)
      ..lineTo(12.0, 102.0)
      ..close();

    canvas.drawPath(leftLeg, trousers);
    canvas.drawPath(rightLeg, trousers);

    final shoe = Paint()
      ..color = character.dark;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -36.0 - weight * 0.25,
          97.0,
          28.0,
          13.0,
        ),
        const Radius.circular(6.0),
      ),
      shoe,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          8.0 + weight * 0.25,
          97.0,
          28.0,
          13.0,
        ),
        const Radius.circular(6.0),
      ),
      shoe,
    );
  }

  void _torso(
    Canvas canvas,
    _CharacterStyle character,
    double breathe,
  ) {
    final bodyPaint = Paint()
      ..color = character.body;

    final body = Path()
      ..moveTo(
        -42.0,
        -36.0 + breathe * 0.2,
      )
      ..quadraticBezierTo(
        0.0,
        -48.0 - breathe * 0.15,
        42.0,
        -36.0 + breathe * 0.2,
      )
      ..lineTo(31.0, 50.0)
      ..quadraticBezierTo(
        0.0,
        61.0,
        -31.0,
        50.0,
      )
      ..close();

    canvas.drawPath(body, bodyPaint);

    final trim = Paint()
      ..color = character.accent.withValues(alpha: 0.8)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      const Offset(0.0, -36.0),
      const Offset(0.0, 42.0),
      trim,
    );
  }

  void _arms(
    Canvas canvas,
    _CharacterStyle character,
    String state,
    double gesture,
    double attention,
  ) {
    final double leftAngle = state == 'COMMUNICATE'
        ? -0.28 + gesture * 0.16
        : state == 'HANDOFF'
            ? -0.32
            : -0.08;

    final double rightAngle = state == 'WORK'
        ? 0.35 + gesture * 0.12
        : state == 'COMMUNICATE'
            ? 0.25 + gesture * 0.12
            : 0.08 + attention * 0.02;

    _arm(
      canvas,
      character,
      -1,
      leftAngle,
      state,
      gesture,
    );

    _arm(
      canvas,
      character,
      1,
      rightAngle,
      state,
      gesture,
    );
  }

  void _arm(
    Canvas canvas,
    _CharacterStyle character,
    int side,
    double angle,
    String state,
    double gesture,
  ) {
    canvas.save();

    canvas.translate(
      side.toDouble() * 39.0,
      -25.0,
    );

    canvas.rotate(
      side.toDouble() * angle,
    );

    final sleeve = Paint()
      ..color = character.body;

    final skin = Paint()
      ..color = character.skin;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          -8.0,
          -4.0,
          16.0,
          43.0,
        ),
        const Radius.circular(8.0),
      ),
      sleeve,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          -7.0,
          36.0,
          14.0,
          27.0,
        ),
        const Radius.circular(7.0),
      ),
      skin,
    );

    final double handY = 63.0 +
        (state == 'COMMUNICATE'
            ? gesture * 3.0
            : 0.0);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0.0, handY),
        width: 13.0,
        height: 10.0,
      ),
      skin,
    );

    if (state == 'COMMUNICATE') {
      final finger = Paint()
        ..color = character.skin
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        const Offset(0.0, 64.0),
        Offset(
          side.toDouble() * 3.0,
          74.0 + gesture * 2.0,
        ),
        finger,
      );
    }

    canvas.restore();
  }

  void _head(
    Canvas canvas,
    _CharacterStyle character,
    double breathe,
    double attention,
    double gesture,
  ) {
    final skin = Paint()
      ..color = character.skin;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -12.0,
          -61.0 + breathe * 0.1,
          24.0,
          22.0,
        ),
        const Radius.circular(8.0),
      ),
      skin,
    );

    canvas.save();

    canvas.translate(
      attention * 0.5,
      -79.0 + breathe * 0.2,
    );

    canvas.rotate(
      attention * 0.006 + gesture * 0.006,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 78.0,
        height: 86.0,
      ),
      skin,
    );

    final facePaint = Paint()
      ..color = character.face;

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0.0, 3.0),
        width: 68.0,
        height: 77.0,
      ),
      facePaint,
    );

    canvas.restore();
  }

  void _hair(
    Canvas canvas,
    _CharacterStyle character,
    double time,
    double breathe,
    double attention,
  ) {
    final paint = Paint()
      ..color = character.hair;

    final double sway =
        math.sin(time) * 1.8 +
        attention * 0.4 +
        breathe * 0.1;

    switch (character.hairStyle) {
      case 'bun':
        canvas.drawCircle(
          Offset(-27.0 + sway, -112.0),
          14.0,
          paint,
        );

        canvas.drawCircle(
          Offset(27.0 + sway, -112.0),
          14.0,
          paint,
        );

        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(0.0, -105.0),
            width: 75.0,
            height: 48.0,
          ),
          paint,
        );
        break;

      case 'visor':
        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(0.0, -106.0),
            width: 82.0,
            height: 35.0,
          ),
          paint,
        );

        final visorPaint = Paint()
          ..color = character.accent.withValues(
            alpha: 0.65,
          );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(
              -31.0,
              -103.0,
              62.0,
              13.0,
            ),
            const Radius.circular(7.0),
          ),
          visorPaint,
        );
        break;

      case 'long':
        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(0.0, -104.0),
            width: 83.0,
            height: 43.0,
          ),
          paint,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              -39.0 + sway,
              -104.0,
              16.0,
              72.0,
            ),
            const Radius.circular(8.0),
          ),
          paint,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              23.0 + sway,
              -104.0,
              16.0,
              72.0,
            ),
            const Radius.circular(8.0),
          ),
          paint,
        );
        break;

      case 'messy':
        final path = Path()
          ..moveTo(-42.0, -92.0);

        for (int i = 0; i < 9; i++) {
          final double x = -42.0 + i * 10.5;

          path.lineTo(
            x,
            -112.0 -
                math.sin(
                  i + time * 0.18,
                ) *
                    7.0 -
                attention.abs(),
          );
        }

        path
          ..lineTo(42.0, -86.0)
          ..lineTo(-42.0, -86.0)
          ..close();

        canvas.drawPath(path, paint);
        break;

      default:
        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(0.0, -104.0),
            width: 82.0,
            height: 42.0,
          ),
          paint,
        );
    }
  }

  void _clothingDetails(
    Canvas canvas,
    _CharacterStyle character,
    String state,
    double breathe,
  ) {
    final line = Paint()
      ..color = character.accent.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    if (character.clothing == 'jacket') {
      canvas.drawLine(
        const Offset(-31.0, -30.0),
        Offset(-24.0, 42.0 + breathe * 0.2),
        line,
      );

      canvas.drawLine(
        const Offset(31.0, -30.0),
        Offset(24.0, 42.0 + breathe * 0.2),
        line,
      );
    }

    if (character.clothing == 'collar') {
      final collarPaint = Paint()
        ..color = character.accent;

      final left = Path()
        ..moveTo(-18.0, -38.0)
        ..lineTo(-3.0, -25.0)
        ..lineTo(-13.0, -18.0)
        ..close();

      final right = Path()
        ..moveTo(18.0, -38.0)
        ..lineTo(3.0, -25.0)
        ..lineTo(13.0, -18.0)
        ..close();

      canvas.drawPath(left, collarPaint);
      canvas.drawPath(right, collarPaint);
    }

    if (character.clothing == 'scarf') {
      final scarfPaint = Paint()
        ..color = character.accent;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(
            -8.0,
            -40.0,
            16.0,
            72.0,
          ),
          const Radius.circular(6.0),
        ),
        scarfPaint,
      );
    }

    if (character.clothing == 'hoodie') {
      canvas.drawArc(
        const Rect.fromLTWH(
          -32.0,
          -51.0,
          64.0,
          42.0,
        ),
        math.pi,
        math.pi,
        false,
        line,
      );
    }

    if (state == 'WARNING') {
      final warningLine = Paint()
        ..color = character.accent.withValues(
          alpha: 0.5,
        )
        ..strokeWidth = 1.5;

      canvas.drawLine(
        Offset(-20.0, 47.0 + breathe * 0.2),
        Offset(20.0, 47.0 + breathe * 0.2),
        warningLine,
      );
    }
  }

  void _accessory(
    Canvas canvas,
    _CharacterStyle character,
    String state,
    double time,
    double pulse,
  ) {
    final double bob = math.sin(time * 1.5) * 2.0;

    switch (character.accessory) {
      case 'notebook':
        final notebookPaint = Paint()
          ..color = character.accent;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              42.0,
              -7.0 + bob,
              22.0,
              29.0,
            ),
            const Radius.circular(3.0),
          ),
          notebookPaint,
        );

        final notebookLine = Paint()
          ..color = character.dark
          ..strokeWidth = 1.5;

        canvas.drawLine(
          Offset(47.0, -2.0 + bob),
          Offset(59.0, -2.0 + bob),
          notebookLine,
        );

        canvas.drawLine(
          Offset(47.0, 3.0 + bob),
          Offset(59.0, 3.0 + bob),
          notebookLine,
        );
        break;

      case 'headphones':
        final headphones = Paint()
          ..color = character.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

        canvas.drawArc(
          const Rect.fromLTWH(
            -49.0,
            -125.0,
            98.0,
            64.0,
          ),
          math.pi,
          math.pi,
          false,
          headphones,
        );

        canvas.drawCircle(
          const Offset(-47.0, -91.0),
          7.0,
          headphones,
        );

        canvas.drawCircle(
          const Offset(47.0, -91.0),
          7.0,
          headphones,
        );
        break;

      case 'orb':
        final orb = Paint()
          ..color = character.accent.withValues(
            alpha: 0.42 + pulse * 0.3,
          );

        canvas.drawCircle(
          Offset(
            58.0,
            -54.0 + bob,
          ),
          10.0 + pulse * 2.0,
          orb,
        );
        break;

      case 'star':
        final starPaint = Paint()
          ..color = character.accent;

        final starPath = Path();

        for (int i = 0; i < 10; i++) {
          final double radius =
              i.isEven ? 11.0 : 4.5;

          final double angle =
              -math.pi / 2.0 +
              i * math.pi / 5.0;

          final Offset point = Offset(
            53.0 + math.cos(angle) * radius,
            -48.0 +
                math.sin(angle) * radius +
                bob,
          );

          if (i == 0) {
            starPath.moveTo(
              point.dx,
              point.dy,
            );
          } else {
            starPath.lineTo(
              point.dx,
              point.dy,
            );
          }
        }

        starPath.close();
        canvas.drawPath(starPath, starPaint);
        break;

      case 'badge':
        final badgePaint = Paint()
          ..color = character.accent;

        canvas.drawCircle(
          Offset(27.0, 2.0 + bob),
          8.0,
          badgePaint,
        );
        break;

      case 'glasses':
        final glasses = Paint()
          ..color = character.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawOval(
          const Rect.fromLTWH(
            -27.0,
            -88.0,
            22.0,
            14.0,
          ),
          glasses,
        );

        canvas.drawOval(
          const Rect.fromLTWH(
            5.0,
            -88.0,
            22.0,
            14.0,
          ),
          glasses,
        );

        canvas.drawLine(
          const Offset(-5.0, -81.0),
          const Offset(5.0, -81.0),
          glasses,
        );
        break;
    }

    if (state == 'COMPLETE' && character.accessory == 'badge') {
      final shine = Paint()
        ..color = Colors.white.withValues(alpha: 0.45);

      canvas.drawCircle(
        Offset(24.5, -0.5 + bob),
        2.0,
        shine,
      );
    }
  }

  void _face(
    Canvas canvas,
    _CharacterStyle character,
    String state,
    double gesture,
    double attention,
  ) {
    final eyePaint = Paint()
      ..color = character.dark;

    final double eyeY =
        -78.0 + attention * 0.2;

    final bool blink =
        math.sin(progress * math.pi * 4.0).abs() >
            0.985;

    if (!blink) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(-15.0, eyeY),
          width: 5.0,
          height: state == 'WARNING'
              ? 7.0
              : 5.0,
        ),
        eyePaint,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(15.0, eyeY),
          width: 5.0,
          height: state == 'WARNING'
              ? 7.0
              : 5.0,
        ),
        eyePaint,
      );
    }

    if (state == 'WARNING') {
      final warningFace = Paint()
        ..color = character.dark
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        const Offset(-22.0, -89.0),
        const Offset(-9.0, -92.0),
        warningFace,
      );

      canvas.drawLine(
        const Offset(9.0, -92.0),
        const Offset(22.0, -89.0),
        warningFace,
      );
    }

    if (state == 'COMPLETE') {
      final smile = Paint()
        ..color = character.dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawArc(
        const Rect.fromLTWH(
          -12.0,
          -77.0,
          24.0,
          18.0,
        ),
        0.2,
        math.pi - 0.4,
        false,
        smile,
      );
    }

    if (state == 'RECEIVE' ||
        state == 'HANDOFF') {
      final attentionRing = Paint()
        ..color = character.accent.withValues(
          alpha: 0.28,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(
        const Offset(0.0, -78.0),
        34.0 + attention.abs(),
        attentionRing,
      );
    }

    if (state == 'COMMUNICATE') {
      final mouth = Paint()
        ..color = character.dark.withValues(
          alpha: 0.7,
        );

      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(0.0, -70.0),
          width: 9.0 + gesture.abs() * 4.0,
          height: 3.0 + gesture.abs(),
        ),
        mouth,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _CharacterPainter oldDelegate,
  ) {
    return oldDelegate.characterId != characterId ||
        oldDelegate.state != state ||
        oldDelegate.progress != progress;
  }
}

/// Visual style definition for each Criterivox character.
///
/// This is deliberately separate from [CharacterIdentities]:
/// identity answers "who is this?", while style answers "how is this
/// character rendered in Flutter?"
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
  final String clothing;

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
    required this.clothing,
  });

  static _CharacterStyle forId(String id) {
    switch (id.trim().toLowerCase()) {
      case 'dharen':
        return const _CharacterStyle(
          skin: Color(0xffc98964),
          face: Color(0xffffd7bc),
          body: Color(0xff8b5e3c),
          trousers: Color(0xff403d46),
          hair: Color(0xff34251f),
          accent: Color(0xffd98b43),
          dark: Color(0xff201b1a),
          hairStyle: 'messy',
          accessory: 'notebook',
          clothing: 'jacket',
        );

      case 'syvax':
        return const _CharacterStyle(
          skin: Color(0xffb87c63),
          face: Color(0xffffd4bd),
          body: Color(0xff344d63),
          trousers: Color(0xff252d36),
          hair: Color(0xff17232e),
          accent: Color(0xff62d8f5),
          dark: Color(0xff14202a),
          hairStyle: 'visor',
          accessory: 'headphones',
          clothing: 'hoodie',
        );

      case 'sandre':
        return const _CharacterStyle(
          skin: Color(0xffa96f58),
          face: Color(0xffffcbb5),
          body: Color(0xff496d6d),
          trousers: Color(0xff343f43),
          hair: Color(0xff2d2522),
          accent: Color(0xff63b9a8),
          dark: Color(0xff1d2527),
          hairStyle: 'long',
          accessory: 'badge',
          clothing: 'collar',
        );

      case 'kaelen':
        return const _CharacterStyle(
          skin: Color(0xffbd805e),
          face: Color(0xffffd1b8),
          body: Color(0xff50575f),
          trousers: Color(0xff20252a),
          hair: Color(0xff1d1b1b),
          accent: Color(0xfff19a3e),
          dark: Color(0xff17191c),
          hairStyle: 'messy',
          accessory: 'headphones',
          clothing: 'jacket',
        );

      case 'anuka':
        return const _CharacterStyle(
          skin: Color(0xffd69a79),
          face: Color(0xffffdfcf),
          body: Color(0xfff0b9c8),
          trousers: Color(0xff343044),
          hair: Color(0xff2a2025),
          accent: Color(0xffbd7fe4),
          dark: Color(0xff221b27),
          hairStyle: 'bun',
          accessory: 'orb',
          clothing: 'hoodie',
        );

      case 'vivren':
        return const _CharacterStyle(
          skin: Color(0xffc7957e),
          face: Color(0xffffd8c7),
          body: Color(0xffd5d0dc),
          trousers: Color(0xff36333e),
          hair: Color(0xffc8bdd9),
          accent: Color(0xffa68ad7),
          dark: Color(0xff26222d),
          hairStyle: 'long',
          accessory: 'glasses',
          clothing: 'scarf',
        );

      case 'tarkis':
        return const _CharacterStyle(
          skin: Color(0xffa96f56),
          face: Color(0xffffcdb6),
          body: Color(0xff34383f),
          trousers: Color(0xff171a1e),
          hair: Color(0xff171719),
          accent: Color(0xffee8b31),
          dark: Color(0xff111214),
          hairStyle: 'messy',
          accessory: 'star',
          clothing: 'hoodie',
        );

      default:
        return const _CharacterStyle(
          skin: Color(0xffb98068),
          face: Color(0xffffd5c0),
          body: Color(0xff59636d),
          trousers: Color(0xff30343a),
          hair: Color(0xff24272b),
          accent: Color(0xff7aa9d8),
          dark: Color(0xff17191c),
          hairStyle: 'messy',
          accessory: 'notebook',
          clothing: 'jacket',
        );
    }
  }
}
