import 'package:flutter/material.dart';

class CharacterRuntimeView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Semantics(
        label: '$characterId character',
        value: state,
        child: CustomPaint(
          painter: _AccessibleCharacterPainter(state: state),
        ),
      ),
    );
  }
}

class _AccessibleCharacterPainter extends CustomPainter {
  final String state;

  const _AccessibleCharacterPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    paint.color = const Color(0xFF6B7280);
    canvas.drawCircle(center.translate(0, -45), 28, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, 20), width: 64, height: 110),
        const Radius.circular(18),
      ),
      paint,
    );
    paint.color = const Color(0xFF55B8FF);
    canvas.drawCircle(center.translate(0, 78), 6, paint);
  }

  @override
  bool shouldRepaint(covariant _AccessibleCharacterPainter oldDelegate) =>
      oldDelegate.state != state;
}
