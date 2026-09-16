import 'package:flutter/material.dart';

/// Presentation-only costume/accessory layer for S8 characters.
///
/// The canonical CharacterRuntimeView remains responsible for the base figure.
/// This painter adds the reference-specific wardrobe, neck pieces, insignia,
/// tools and small visual cues without introducing image assets or computation.
class S8CharacterDetails extends StatelessWidget {
  final String characterId;
  final String state;
  final double width;
  final double height;

  const S8CharacterDetails({
    super.key,
    required this.characterId,
    required this.state,
    this.width = 220,
    this.height = 245,
  });

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(
          size: Size(width, height),
          painter: _S8CharacterDetailsPainter(
            characterId: characterId.toLowerCase(),
            state: state.toUpperCase(),
          ),
        ),
      );
}

class _S8CharacterDetailsPainter extends CustomPainter {
  final String characterId;
  final String state;

  const _S8CharacterDetailsPainter({required this.characterId, required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / 220).clamp(0.55, 1.4);
    canvas.save();
    canvas.translate(size.width / 2, size.height * .53);
    canvas.scale(scale);

    switch (characterId) {
      case 'medrus':
        _medrus(canvas);
        break;
      case 'epistre':
        _epistre(canvas);
        break;
      case 'veridat':
        _veridat(canvas);
        break;
    }

    canvas.restore();
  }

  Paint _fill(Color color) => Paint()..color = color;
  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _coatPanel(Canvas c, Path path, Color fill, Color trim) {
    c.drawPath(path, _fill(fill));
    c.drawPath(path, _stroke(trim.withValues(alpha: .72), 1.8));
  }

  void _medrus(Canvas c) {
    const outer = Color(0xFFE8E0D1);
    const dark = Color(0xFF171C25);
    const trim = Color(0xFFD5B06D);
    const blue = Color(0xFF2CCCF5);

    // Layered long field coat, matching the practical black/cream reference.
    _coatPanel(c, Path()
      ..moveTo(-43, -35)..lineTo(-29, -31)..lineTo(-20, 49)
      ..lineTo(-45, 94)..lineTo(-57, 87)..lineTo(-48, 15)..close(), outer, trim);
    _coatPanel(c, Path()
      ..moveTo(43, -35)..lineTo(29, -31)..lineTo(20, 49)
      ..lineTo(45, 94)..lineTo(57, 87)..lineTo(48, 15)..close(), outer, trim);

    // Dark bodysuit / inner vest and functional waist band.
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-29, -34, 58, 82), const Radius.circular(13)), _fill(dark));
    c.drawLine(const Offset(-27, 28), const Offset(27, 28), _stroke(trim, 2));
    c.drawLine(const Offset(-28, 35), const Offset(28, 35), _stroke(Colors.white24, 1));

    // High neck cloth / scarf with layered tails.
    c.drawPath(Path()..moveTo(-17,-57)..lineTo(0,-45)..lineTo(17,-57)..lineTo(11,-30)..lineTo(0,-22)..lineTo(-11,-30)..close(), _fill(Color(0xFF252C37)));
    c.drawPath(Path()..moveTo(-7,-43)..lineTo(0,-36)..lineTo(7,-43)..lineTo(4,-15)..lineTo(0,-7)..lineTo(-4,-15)..close(), _fill(Color(0xFFB8A78A)));

    // Glasses frame and small bridge cue.
    final lens = _stroke(const Color(0xFF202A38), 2.2);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-29,-86,25,13), const Radius.circular(4)), lens);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(4,-86,25,13), const Radius.circular(4)), lens);
    c.drawLine(const Offset(-4,-80), const Offset(4,-80), lens);

    // Signature blue/gold research pendant.
    c.drawLine(const Offset(0,-27), const Offset(0,1), _stroke(trim, 2));
    c.drawPath(Path()..moveTo(0,-2)..lineTo(7,5)..lineTo(0,12)..lineTo(-7,5)..close(), _fill(blue));
    c.drawPath(Path()..moveTo(0,-2)..lineTo(7,5)..lineTo(0,12)..lineTo(-7,5)..close(), _stroke(trim, 1.5));

    // Wrist device / experiment marker.
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(33, 18, 13, 7), const Radius.circular(3)), _fill(Color(0xFF202936)));
    c.drawCircle(const Offset(39.5,21.5), 1.8, _fill(blue));

    // Tablet / evidence slate appears during work, receive or handoff.
    if (state == 'WORK' || state == 'RECEIVE' || state == 'HANDOFF') _tablet(c, Offset(31, 45), 30, 19, blue);
  }

  void _epistre(Canvas c) {
    const outer = Color(0xFFE9E0D1);
    const dark = Color(0xFF191C25);
    const trim = Color(0xFFD4B06F);
    const violet = Color(0xFFB98BFF);

    // Scholarly layered coat and long drape.
    _coatPanel(c, Path()
      ..moveTo(-42,-35)..lineTo(-28,-32)..lineTo(-17,46)
      ..lineTo(-42,92)..lineTo(-58,84)..lineTo(-49,12)..close(), outer, trim);
    _coatPanel(c, Path()
      ..moveTo(42,-35)..lineTo(28,-32)..lineTo(17,46)
      ..lineTo(42,92)..lineTo(58,84)..lineTo(49,12)..close(), outer, trim);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-28,-35,56,84), const Radius.circular(12)), _fill(dark));

    // Soft neck wrap / scholarly stole.
    c.drawPath(Path()..moveTo(-20,-56)..quadraticBezierTo(0,-43,20,-56)..lineTo(13,-28)..lineTo(0,-20)..lineTo(-13,-28)..close(), _fill(Color(0xFFD8CCBC)));
    c.drawLine(const Offset(-11,-31), const Offset(-6,31), _stroke(trim.withValues(alpha:.8), 1.5));
    c.drawLine(const Offset(11,-31), const Offset(6,31), _stroke(trim.withValues(alpha:.8), 1.5));

    // Fine glasses and hair ornament cue.
    final frame = _stroke(const Color(0xFF252A33), 1.9);
    c.drawOval(Rect.fromLTWH(-29,-86,25,14), frame);
    c.drawOval(Rect.fromLTWH(4,-86,25,14), frame);
    c.drawLine(const Offset(-4,-79), const Offset(4,-79), frame);
    c.drawCircle(const Offset(27,-105), 4, _fill(trim));

    // Compass/star research pendant.
    c.drawLine(const Offset(0,-25), const Offset(0,2), _stroke(trim, 2));
    _star(c, const Offset(0,7), 9, trim, violet);

    // Book/knowledge tablet cue in active states.
    if (state == 'WORK' || state == 'RECEIVE' || state == 'HANDOFF') _tablet(c, Offset(29, 44), 31, 19, violet);
  }

  void _veridat(Canvas c) {
    const outer = Color(0xFFE7E0D3);
    const dark = Color(0xFF151B23);
    const trim = Color(0xFFD9B56C);
    const green = Color(0xFF38E0A8);

    // Refined white verification coat over a fitted dark bodysuit.
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-28,-36,56,86), const Radius.circular(11)), _fill(dark));
    _coatPanel(c, Path()
      ..moveTo(-41,-35)..lineTo(-27,-32)..lineTo(-16,48)
      ..lineTo(-38,91)..lineTo(-55,84)..lineTo(-48,10)..close(), outer, trim);
    _coatPanel(c, Path()
      ..moveTo(41,-35)..lineTo(27,-32)..lineTo(16,48)
      ..lineTo(38,91)..lineTo(55,84)..lineTo(48,10)..close(), outer, trim);

    // High collar and narrow neck cloth.
    c.drawPath(Path()..moveTo(-17,-58)..lineTo(0,-48)..lineTo(17,-58)..lineTo(11,-31)..lineTo(0,-22)..lineTo(-11,-31)..close(), _fill(Color(0xFF222934)));
    c.drawPath(Path()..moveTo(-6,-45)..lineTo(0,-38)..lineTo(6,-45)..lineTo(4,-12)..lineTo(0,-6)..lineTo(-4,-12)..close(), _fill(Color(0xFFD1C5B3)));

    // Verification glasses.
    final frame = _stroke(const Color(0xFF202A32), 2.1);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-29,-86,25,13), const Radius.circular(4)), frame);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(4,-86,25,13), const Radius.circular(4)), frame);
    c.drawLine(const Offset(-4,-80), const Offset(4,-80), frame);

    // Gold verification star with green core.
    c.drawLine(const Offset(0,-27), const Offset(0,3), _stroke(trim, 2));
    _star(c, const Offset(0,8), 9, trim, green);

    // Compact wrist scanner and evidence slate.
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-47, 17, 13, 7), const Radius.circular(3)), _fill(Color(0xFF202936)));
    c.drawCircle(const Offset(-40.5,20.5), 1.8, _fill(green));
    if (state == 'WORK' || state == 'RECEIVE' || state == 'HANDOFF') _tablet(c, Offset(29, 44), 31, 19, green);
  }

  void _tablet(Canvas c, Offset at, double w, double h, Color glow) {
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(at.dx, at.dy, w, h), const Radius.circular(4));
    c.drawRRect(body, _fill(const Color(0xFF101A24)));
    c.drawRRect(body, _stroke(glow.withValues(alpha:.75), 1.4));
    c.drawLine(Offset(at.dx+5, at.dy+6), Offset(at.dx+w-5, at.dy+6), _stroke(glow.withValues(alpha:.55), 1));
    c.drawLine(Offset(at.dx+5, at.dy+11), Offset(at.dx+w-10, at.dy+11), _stroke(Colors.white24, 1));
    c.drawCircle(Offset(at.dx+w-5, at.dy+h-5), 1.7, _fill(glow));
  }

  void _star(Canvas c, Offset center, double radius, Color outline, Color core) {
    final path = Path();
    for (int i=0; i<10; i++) {
      final r = i.isEven ? radius : radius * .42;
      final a = -3.14159265/2 + i*3.14159265/5;
      final p = Offset(center.dx + r*mathCos(a), center.dy + r*mathSin(a));
      if (i==0) path.moveTo(p.dx,p.dy); else path.lineTo(p.dx,p.dy);
    }
    path.close();
    c.drawPath(path, _fill(core));
    c.drawPath(path, _stroke(outline, 1.5));
  }

  double mathCos(double a) => _cos(a);
  double mathSin(double a) => _sin(a);

  double _sin(double x) {
    // Small self-contained approximation is sufficient for this decorative star.
    var term = x;
    var sum = x;
    for (var n=1; n<7; n++) {
      term *= -x*x / ((2*n)*(2*n+1));
      sum += term;
    }
    return sum;
  }

  double _cos(double x) {
    var term = 1.0;
    var sum = 1.0;
    for (var n=1; n<7; n++) {
      term *= -x*x / ((2*n-1)*(2*n));
      sum += term;
    }
    return sum;
  }

  @override
  bool shouldRepaint(covariant _S8CharacterDetailsPainter oldDelegate) =>
      oldDelegate.characterId != characterId || oldDelegate.state != state;
}
