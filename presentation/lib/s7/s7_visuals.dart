import 'dart:math' as math;

import 'package:flutter/material.dart';

class S7BureauBackdrop extends CustomPainter {
  const S7BureauBackdrop({
    required this.progress,
    required this.room,
  });

  final double progress;
  final String room;

  Color get accent {
    switch (room) {
      case 'vivren':
        return const Color(0xffa98cff);
      case 'tarkis':
        return const Color(0xffffb45f);
      default:
        return const Color(0xffc8b7ff);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xff050817),
          const Color(0xff0b0a18),
          accent.withValues(alpha: 0.10),
          const Color(0xff03040a),
        ],
        stops: const [0, .34, .68, 1],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, bg);

    final glow = Paint()
      ..color = accent.withValues(alpha: .055)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        80,
      );

    canvas.drawCircle(
      Offset(size.width * .50, size.height * .42),
      size.shortestSide * .32,
      glow,
    );

    final architecture = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .055);

    final horizon = size.height * .66;

    canvas.drawLine(
      Offset(0, horizon),
      Offset(size.width, horizon),
      architecture,
    );

    for (var i = -7; i <= 7; i++) {
      final x = size.width / 2 + i * size.width / 10;

      canvas.drawLine(
        Offset(x, horizon),
        Offset(
          size.width / 2 + i * size.width / 3.1,
          size.height,
        ),
        architecture,
      );
    }

    for (var i = 0; i < 6; i++) {
      final x = size.width * (.07 + i * .18);
      final h = size.height * (.30 + (i.isEven ? .07 : 0));

      final column = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          size.height * .16,
          size.width * .035,
          h,
        ),
        const Radius.circular(8),
      );

      canvas.drawRRect(column, architecture);
    }

    final pulse = .5 + .5 * math.sin(progress * math.pi * 2);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(
        alpha: .10 + .08 * pulse,
      );

    for (var i = 0; i < 4; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.width * .50,
            size.height * .62,
          ),
          width: size.width * (.18 + i * .07),
          height: size.height * (.035 + i * .012),
        ),
        ring,
      );
    }

    final light = Paint()
      ..color = accent.withValues(
        alpha: .16 + .05 * pulse,
      );

    canvas.drawCircle(
      Offset(size.width * .5, size.height * .60),
      3.5,
      light,
    );

    _drawWindow(
      canvas,
      size,
      Offset(
        size.width * .10,
        size.height * .11,
      ),
      Size(
        size.width * .23,
        size.height * .26,
      ),
    );

    _drawWindow(
      canvas,
      size,
      Offset(
        size.width * .67,
        size.height * .10,
      ),
      Size(
        size.width * .23,
        size.height * .27,
      ),
    );

    _drawCentralTable(canvas, size);
  }

  void _drawWindow(
    Canvas canvas,
    Size size,
    Offset origin,
    Size windowSize,
  ) {
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: .07);

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: .07),
          Colors.white.withValues(alpha: .012),
        ],
      ).createShader(origin & windowSize);

    final rect = RRect.fromRectAndRadius(
      origin & windowSize,
      const Radius.circular(18),
    );

    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, frame);

    canvas.drawLine(
      origin + Offset(windowSize.width * .5, 0),
      origin +
          Offset(
            windowSize.width * .5,
            windowSize.height,
          ),
      frame,
    );

    canvas.drawLine(
      origin + Offset(0, windowSize.height * .52),
      origin +
          Offset(
            windowSize.width,
            windowSize.height * .52,
          ),
      frame,
    );
  }

  void _drawCentralTable(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width * .50,
      size.height * .67,
    );

    final table = Paint()
      ..color = const Color(0xff0d1120).withValues(alpha: .86)
      ..style = PaintingStyle.fill;

    final edge = Paint()
      ..color = accent.withValues(alpha: .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .43,
        height: size.height * .105,
      ),
      table,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .43,
        height: size.height * .105,
      ),
      edge,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 4),
        width: size.width * .25,
        height: size.height * .035,
      ),
      edge,
    );
  }

  @override
  bool shouldRepaint(
    covariant S7BureauBackdrop oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.room != room;
  }
}

class S7BureauCharacter extends StatelessWidget {
  const S7BureauCharacter({
    super.key,
    required this.identity,
    required this.state,
    required this.progress,
    this.scale = 1,
  });

  final String identity;
  final String state;
  final double progress;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final isVivren = identity.toLowerCase() == 'vivren';

    final accent = isVivren
        ? const Color(0xffad92ff)
        : const Color(0xffffb463);

    return SizedBox(
      width: 170 * scale,
      height: 290 * scale,
      child: CustomPaint(
        painter: _CharacterPainter(
          isVivren: isVivren,
          state: state,
          progress: progress,
          accent: accent,
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  _CharacterPainter({
    required this.isVivren,
    required this.state,
    required this.progress,
    required this.accent,
  });

  final bool isVivren;
  final String state;
  final double progress;
  final Color accent;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final active = state != 'idle';

    final motion = active
        ? math.sin(progress * math.pi * 2) * 3
        : math.sin(progress * math.pi * 2) * .7;

    final glow = Paint()
      ..color = accent.withValues(
        alpha: active ? .16 : .08,
      )
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        25,
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.width / 2,
          size.height - 16,
        ),
        width: 100,
        height: 24,
      ),
      glow,
    );

    final skin = Paint()
      ..color = isVivren
          ? const Color(0xffd9d2d9)
          : const Color(0xffc8b5aa);

    final dark = Paint()
      ..color = const Color(0xff10121a);

    final coat = Paint()
      ..color = isVivren
          ? const Color(0xffd5d6df)
          : const Color(0xff171a24);

    final coatShade = Paint()
      ..color = isVivren
          ? const Color(0xffa6a9b8)
          : const Color(0xff2c303d);

    final hair = Paint()
      ..color = isVivren
          ? const Color(0xffaeb2c6)
          : const Color(0xff25232d);

    final tech = Paint()
      ..color = accent.withValues(alpha: .85);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = accent.withValues(alpha: .55);

    canvas.save();
    canvas.translate(0, motion);

    // Legs and grounded silhouette.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(63, 215, 18, 52),
        const Radius.circular(8),
      ),
      dark,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(89, 215, 18, 52),
        const Radius.circular(8),
      ),
      dark,
    );

    canvas.drawOval(
      const Rect.fromLTWH(55, 258, 33, 11),
      dark,
    );

    canvas.drawOval(
      const Rect.fromLTWH(82, 258, 33, 11),
      dark,
    );

    // Flowing or structured coat.
    final body = Path()
      ..moveTo(58, 130)
      ..quadraticBezierTo(85, 116, 112, 130)
      ..lineTo(125, 222)
      ..quadraticBezierTo(106, 236, 86, 224)
      ..quadraticBezierTo(67, 237, 44, 220)
      ..close();

    canvas.drawPath(body, coat);
    canvas.drawPath(body, line);

    canvas.drawPath(
      Path()
        ..moveTo(83, 132)
        ..lineTo(78, 220)
        ..lineTo(88, 226)
        ..lineTo(96, 133)
        ..close(),
      coatShade,
    );

    // Arms, with activity-directed pose.
    final armY = active ? 158.0 : 165.0;

    canvas.save();
    canvas.translate(54, armY);
    canvas.rotate(active ? -.10 : .05);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12, 0, 18, 72),
        const Radius.circular(8),
      ),
      coatShade,
    );

    canvas.drawCircle(
      const Offset(-3, 74),
      7,
      skin,
    );

    canvas.restore();

    canvas.save();
    canvas.translate(111, armY + 2);
    canvas.rotate(active ? .18 : -.04);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-1, 0, 18, 68),
        const Radius.circular(8),
      ),
      coatShade,
    );

    canvas.drawCircle(
      const Offset(8, 71),
      7,
      skin,
    );

    canvas.restore();

    // Neck and head.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(75, 105, 20, 28),
        const Radius.circular(7),
      ),
      skin,
    );

    canvas.drawOval(
      const Rect.fromLTWH(62, 57, 47, 61),
      skin,
    );

    // Hair mass and identity-specific silhouette.
    if (isVivren) {
      final h = Path()
        ..moveTo(62, 83)
        ..quadraticBezierTo(54, 54, 75, 39)
        ..quadraticBezierTo(97, 25, 116, 49)
        ..quadraticBezierTo(123, 72, 108, 96)
        ..lineTo(100, 67)
        ..lineTo(91, 83)
        ..lineTo(84, 61)
        ..lineTo(73, 86)
        ..close();

      canvas.drawPath(h, hair);

      for (var i = 0; i < 4; i++) {
        canvas.drawLine(
          Offset(
            68 + i * 11.0,
            54 + i * 2,
          ),
          Offset(
            57 + i * 10.0,
            91 + i * 3,
          ),
          line,
        );
      }
    } else {
      final h = Path()
        ..moveTo(59, 82)
        ..quadraticBezierTo(57, 48, 80, 35)
        ..quadraticBezierTo(106, 29, 116, 57)
        ..lineTo(109, 91)
        ..lineTo(99, 70)
        ..lineTo(91, 87)
        ..lineTo(81, 66)
        ..lineTo(70, 89)
        ..close();

      canvas.drawPath(h, hair);

      canvas.drawLine(
        const Offset(103, 42),
        const Offset(117, 58),
        line,
      );
    }

    // Face details, deliberately stylized rather than an icon.
    final eye = Paint()
      ..color = accent.withValues(alpha: .9);

    canvas.drawOval(
      const Rect.fromLTWH(72, 82, 9, 4),
      eye,
    );

    canvas.drawOval(
      const Rect.fromLTWH(92, 82, 9, 4),
      eye,
    );

    final faceLine = Paint()
      ..color = const Color(0xff4b4650).withValues(alpha: .65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawArc(
      const Rect.fromLTWH(80, 90, 12, 8),
      0,
      math.pi,
      false,
      faceLine,
    );

    // Signature pendant.
    final pendant = Path()
      ..moveTo(85, 137)
      ..lineTo(91, 146)
      ..lineTo(85, 156)
      ..lineTo(79, 146)
      ..close();

    canvas.drawPath(pendant, tech);
    canvas.drawPath(pendant, line);

    // Wrist device.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          111,
          armY + 55,
          15,
          8,
        ),
        const Radius.circular(3),
      ),
      tech,
    );

    // Analytical interface held between the hands when active.
    if (active) {
      final interfacePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = accent.withValues(alpha: .50);

      const center = Offset(85, 177);

      canvas.drawCircle(
        center,
        22,
        interfacePaint,
      );

      canvas.drawCircle(
        center,
        12,
        interfacePaint,
      );

      for (var i = 0; i < 5; i++) {
        final a =
            i * math.pi * 2 / 5 + progress * math.pi * 2;

        final p = center +
            Offset(
              math.cos(a) * 30,
              math.sin(a) * 18,
            );

        canvas.drawCircle(
          p,
          2.3,
          tech,
        );

        canvas.drawLine(
          center,
          p,
          interfacePaint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(
    covariant _CharacterPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.state != state ||
        oldDelegate.isVivren != isVivren ||
        oldDelegate.accent != accent;
  }
}

class S7GlassPanel extends StatelessWidget {
  const S7GlassPanel({
    super.key,
    required this.title,
    required this.child,
    this.accent,
    this.initiallyExpanded = true,
    this.width,
  });

  final String title;
  final Widget child;
  final Color? accent;
  final bool initiallyExpanded;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return _CollapsibleGlassPanel(
      title: title,
      accent: accent ?? Colors.white,
      initiallyExpanded: initiallyExpanded,
      width: width,
      child: child,
    );
  }
}

class _CollapsibleGlassPanel extends StatefulWidget {
  const _CollapsibleGlassPanel({
    required this.title,
    required this.child,
    required this.accent,
    required this.initiallyExpanded,
    this.width,
  });

  final String title;
  final Widget child;
  final Color accent;
  final bool initiallyExpanded;
  final double? width;

  @override
  State<_CollapsibleGlassPanel> createState() =>
      _CollapsibleGlassPanelState();
}

class _CollapsibleGlassPanelState
    extends State<_CollapsibleGlassPanel> {
  late bool expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: const Color(0xff111526).withValues(alpha: .64),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.accent.withValues(alpha: .16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: widget.accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 17,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                14,
              ),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class S7SectionLabel extends StatelessWidget {
  const S7SectionLabel(
    this.text, {
    super.key,
    this.accent,
  });

  final String text;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 8,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w800,
        color: accent ?? Colors.white38,
      ),
    );
  }
}

class S7Metric extends StatelessWidget {
  const S7Metric(
    this.label,
    this.value, {
    super.key,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: accent ?? Colors.white,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 7,
            letterSpacing: 1.2,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }
}