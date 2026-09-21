import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'visual_character_contract.dart';

class ProceduralCharacterView extends StatefulWidget {
  final VisualCharacterDefinition character;
  final CharacterOperationalState operationalState;
  final CharacterAttentionState attentionState;
  final double scale;

  const ProceduralCharacterView({
    super.key,
    required this.character,
    this.operationalState = CharacterOperationalState.idle,
    this.attentionState = CharacterAttentionState.quiet,
    this.scale = 1,
  });

  @override
  State<ProceduralCharacterView> createState() =>
      _ProceduralCharacterViewState();
}

class _ProceduralCharacterViewState extends State<ProceduralCharacterView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size(180 * widget.scale, 260 * widget.scale),
          painter: _CharacterPainter(
            definition: widget.character,
            operationalState: widget.operationalState,
            attentionState: widget.attentionState,
            phase: _controller.value,
          ),
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  final VisualCharacterDefinition definition;
  final CharacterOperationalState operationalState;
  final CharacterAttentionState attentionState;
  final double phase;

  const _CharacterPainter({
    required this.definition,
    required this.operationalState,
    required this.attentionState,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / 180, size.height / 260);
    final cx = size.width / 2;
    final breath = math.sin(phase * math.pi * 2) * 2.0 * s;
    final focus = attentionState == CharacterAttentionState.focused ||
        attentionState == CharacterAttentionState.busy;
    final active = operationalState != CharacterOperationalState.idle;

    final shadow = Paint()..color = Colors.black.withValues(alpha: .22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height - 12 * s),
        width: 92 * s,
        height: 18 * s,
      ),
      shadow,
    );

    final body = Paint()..color = const Color(0xFF172033);
    final bodyAccent = Paint()..color = definition.accent;
    final skin = Paint()..color = const Color(0xFFF1D3C4);
    final dark = Paint()..color = const Color(0xFF0A0E18);

    final torso = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        cx - 43 * s,
        116 * s + breath,
        86 * s,
        100 * s,
      ),
      Radius.circular(28 * s),
    );
    canvas.drawRRect(torso, body);

    final shoulderGlow = Paint()
      ..color = definition.accent.withValues(alpha: active ? .22 : .10)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * s);
    canvas.drawCircle(Offset(cx, 145 * s + breath), 30 * s, shoulderGlow);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 55 * s, 168 * s + breath),
        width: 28 * s,
        height: 72 * s,
      ),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 55 * s, 168 * s + breath),
        width: 28 * s,
        height: 72 * s,
      ),
      body,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 26 * s, 218 * s),
        width: 32 * s,
        height: 52 * s,
      ),
      dark,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 26 * s, 218 * s),
        width: 32 * s,
        height: 52 * s,
      ),
      dark,
    );

    canvas.drawCircle(Offset(cx, 78 * s + breath), 39 * s, skin);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, 70 * s + breath),
        width: 78 * s,
        height: 72 * s,
      ),
      math.pi,
      math.pi,
      false,
      dark,
    );

    final eyePaint = Paint()..color = focus ? definition.accent : Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 14 * s, 84 * s + breath),
        width: 7 * s,
        height: 4 * s,
      ),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 14 * s, 84 * s + breath),
        width: 7 * s,
        height: 4 * s,
      ),
      eyePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, 150 * s + breath),
          width: 18 * s,
          height: 42 * s,
        ),
        Radius.circular(8 * s),
      ),
      bodyAccent,
    );

    _paintAccessory(canvas, cx, breath, s);

    if (active || attentionState == CharacterAttentionState.needsUser) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * s
        ..color = definition.accent.withValues(alpha: .55);
      final pulse = 48 * s + (math.sin(phase * math.pi * 2) + 1) * 4 * s;
      canvas.drawCircle(Offset(cx, 78 * s + breath), pulse, ring);
    }
  }

  void _paintAccessory(Canvas canvas, double cx, double breath, double s) {
    final glow = Paint()
      ..color = definition.accent.withValues(alpha: .28)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 * s);

    if (definition.accessory.contains('orb')) {
      canvas.drawCircle(Offset(cx + 61 * s, 116 * s + breath), 18 * s, glow);
      canvas.drawCircle(
        Offset(cx + 61 * s, 116 * s + breath),
        11 * s,
        Paint()..color = const Color(0xFF0D1525),
      );
      canvas.drawCircle(
        Offset(cx + 61 * s, 116 * s + breath),
        4 * s,
        Paint()..color = definition.accent,
      );
      return;
    }

    final rect = Rect.fromCenter(
      center: Offset(cx + 51 * s, 142 * s + breath),
      width: 28 * s,
      height: 38 * s,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(6 * s)),
      glow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(6 * s)),
      Paint()..color = const Color(0xFF111A2B),
    );
    canvas.drawRect(
      Rect.fromLTWH(
        rect.left + 6 * s,
        rect.top + 8 * s,
        rect.width - 12 * s,
        2 * s,
      ),
      Paint()..color = definition.accent,
    );
  }

  @override
  bool shouldRepaint(covariant _CharacterPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.operationalState != operationalState ||
      oldDelegate.attentionState != attentionState ||
      oldDelegate.definition != definition;
}
