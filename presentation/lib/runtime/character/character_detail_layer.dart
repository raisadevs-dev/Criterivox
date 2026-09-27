import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'character_visual_profile.dart';

/// Generated vector detail pass. It is intentionally asset-free: every frame
/// is derived from CharacterVisualProfile and runtime state.
class CharacterDetailLayer extends StatelessWidget {
  final CharacterVisualProfile profile;
  final String state;
  final double progress;
  const CharacterDetailLayer(
      {super.key,
      required this.profile,
      required this.state,
      required this.progress});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(
          size: Size.infinite,
          painter: _DetailPainter(
              profile: profile, state: state.toUpperCase(), progress: progress),
        ),
      );
}

class _DetailPainter extends CustomPainter {
  final CharacterVisualProfile profile;
  final String state;
  final double progress;
  const _DetailPainter(
      {required this.profile, required this.state, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scale = math.min(size.width / 238, size.height / 286);
    final t = progress * math.pi * 2;
    final pulse = .5 + .5 * math.sin(t * 2);
    canvas.save();
    canvas.translate(size.width / 2, size.height * .53);
    canvas.scale(scale);
    _signature(canvas, t, pulse);
    _stateRing(canvas, t, pulse);
    _facialHighlight(canvas);
    canvas.restore();
  }

  void _signature(Canvas canvas, double t, double pulse) {
    final p = Paint()..color = profile.accent.withValues(alpha: .72);
    final glow = Paint()
      ..color = profile.accent.withValues(alpha: .12 + pulse * .12);
    final drift = math.sin(t * .7) * 2.5;
    switch (profile.characterId) {
      case 'syvax':
        canvas.drawCircle(const Offset(0, -132), 3 + pulse, glow);
        canvas.drawCircle(const Offset(0, -132), 1.2, p);
        break;
      case 'anuka':
        for (var i = 0; i < 3; i++) {
          final a = t * .4 + i * math.pi * 2 / 3;
          canvas.drawCircle(
              Offset(58 + math.cos(a) * 12, -54 + math.sin(a) * 12 + drift),
              2.2,
              p);
        }
        break;
      case 'sandre':
        canvas.drawCircle(Offset(27, 2 + drift), 2.2, p);
        canvas.drawCircle(Offset(27, 2 + drift), 10 + pulse * 2, glow);
        break;
      case 'dharen':
        canvas.drawLine(
            const Offset(50, 0), Offset(50, 16 + drift), p..strokeWidth = 2);
        break;
      case 'kaelen':
        canvas.drawCircle(const Offset(-47, -91), 8 + pulse * 2, glow);
        canvas.drawCircle(const Offset(47, -91), 8 + pulse * 2, glow);
        break;
      case 'vivren':
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(0, -78), radius: 48),
          -1.1,
          2.2,
          false,
          p..strokeWidth = 1.6,
        );
        break;
      case 'tarkis':
        canvas.drawLine(const Offset(48, -6), Offset(62, -18 + drift), p..strokeWidth = 2);
        canvas.drawLine(const Offset(48, -6), Offset(58, 5 + drift), p..strokeWidth = 2);
        break;
      case 'pramon':
        canvas.drawRect(const Rect.fromLTWH(43, -10, 19, 27), p..style = PaintingStyle.stroke..strokeWidth = 2);
        break;
      case 'bodhex':
        canvas.drawCircle(Offset(55, 2 + drift), 7 + pulse * 2, glow);
        canvas.drawLine(Offset(48, 2 + drift), Offset(62, 2 + drift), p..strokeWidth = 2);
        break;
      case 'manis':
        canvas.drawArc(
          const Rect.fromLTWH(45, -8, 16, 14),
          math.pi * 1.1,
          math.pi * 1.5,
          false,
          p..strokeWidth = 2,
        );
        break;
      case 'viveda':
        canvas.drawRect(const Rect.fromLTWH(43, -8, 22, 28), p..style = PaintingStyle.stroke..strokeWidth = 2);
        canvas.drawLine(const Offset(48, -1), const Offset(60, -1), p..strokeWidth = 1.5);
        canvas.drawLine(const Offset(48, 5), const Offset(58, 5), p..strokeWidth = 1.5);
        break;
      case 'anukor':
        canvas.drawCircle(Offset(55, 1 + drift), 8, glow);
        canvas.drawCircle(Offset(55, 1 + drift), 5, p..style = PaintingStyle.stroke..strokeWidth = 1.8);
        break;
      case 'medrus':
        canvas.drawCircle(Offset(55, 2 + drift), 8 + pulse, glow);
        canvas.drawLine(const Offset(55, -7), Offset(55, 11 + drift), p..strokeWidth = 2);
        break;
      case 'epistre':
        canvas.drawCircle(Offset(53, 1 + drift), 10, p..style = PaintingStyle.stroke..strokeWidth = 1.8);
        canvas.drawLine(Offset(53, -9 + drift), Offset(53, 11 + drift), p..strokeWidth = 1.4);
        canvas.drawLine(Offset(43, 1 + drift), Offset(63, 1 + drift), p..strokeWidth = 1.4);
        break;
      case 'veridat':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(42, -6 + drift, 24, 17),
            const Radius.circular(4),
          ),
          p..style = PaintingStyle.stroke..strokeWidth = 2,
        );
        break;
    }
  }

  void _stateRing(Canvas canvas, double t, double pulse) {
    if (state == 'IDLE') return;
    final alpha = state == 'WARNING' ? .32 : .16;
    final p = Paint()
      ..color = profile.accent.withValues(alpha: alpha + pulse * .08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = state == 'WARNING' ? 2.5 : 1.7;
    final radius = 43 + math.sin(t * 1.4) * 2.5;
    canvas.drawCircle(const Offset(0, -78), radius, p);
    if (state == 'WARNING') {
      canvas.drawArc(
          Rect.fromCircle(center: const Offset(0, -78), radius: radius + 6),
          t,
          1.35,
          false,
          p);
    }
    if (state == 'COMPLETE') {
      canvas.drawArc(
          Rect.fromCircle(center: const Offset(0, -78), radius: radius + 5),
          -t,
          math.pi * 1.4,
          false,
          p);
    }
  }

  void _facialHighlight(Canvas canvas) {
    canvas.drawOval(const Rect.fromLTWH(-24, -101, 14, 9),
        Paint()..color = Colors.white.withValues(alpha: .11));
  }

  @override
  bool shouldRepaint(covariant _DetailPainter old) =>
      old.profile != profile || old.state != state || old.progress != progress;
}
