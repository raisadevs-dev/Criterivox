import 'dart:math' as math;

import 'package:flutter/material.dart';

const _violet = Color(0xffb59cff);
const _amber = Color(0xffffb463);
const _glass = Color(0xff111526);

class S7BureauBackdrop extends CustomPainter {
  const S7BureauBackdrop({required this.progress, required this.room});

  final double progress;
  final String room;

  Color get accent {
    switch (room) {
      case 'vivren':
        return _violet;
      case 'tarkis':
        return _amber;
      default:
        return const Color(0xffc9bcff);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = .5 + .5 * math.sin(progress * math.pi * 2);
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xff17152d),
          Color(0xff0b0d1b),
          Color(0xff050713),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    _drawSky(canvas, size, p);
    _drawWindows(canvas, size);
    _drawArchitecture(canvas, size);
    _drawShelves(canvas, size);
    _drawPlants(canvas, size, p);
    _drawResearchBoard(canvas, size);
    _drawTerminals(canvas, size, p);
    _drawTable(canvas, size, p);
    _drawFloor(canvas, size, p);
  }

  void _drawSky(Canvas canvas, Size size, double p) {
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xff283455).withValues(alpha: .28),
          const Color(0xff75618c).withValues(alpha: .12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * .45));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * .45), sky);
    final sun = Paint()
      ..color = accent.withValues(alpha: .11 + .025 * p)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 42);
    canvas.drawCircle(Offset(size.width * .78, size.height * .18), 38, sun);
    final skyline = Paint()..color = Colors.white.withValues(alpha: .035);
    for (var i = 0; i < 18; i++) {
      final x = size.width * (i / 18);
      final h = size.height * (.035 + ((i * 17) % 5) * .012);
      canvas.drawRect(Rect.fromLTWH(x, size.height * .38 - h, size.width / 23, h), skyline);
    }
  }

  void _drawWindows(Canvas canvas, Size size) {
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = Colors.white.withValues(alpha: .075);
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [accent.withValues(alpha: .10), Colors.white.withValues(alpha: .018)],
      ).createShader(Rect.fromLTWH(size.width * .05, size.height * .07, size.width * .9, size.height * .38));
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(size.width * .05, size.height * .07, size.width * .90, size.height * .36), const Radius.circular(24));
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, frame);
    final x1 = size.width * .34;
    final x2 = size.width * .66;
    canvas.drawLine(Offset(x1, size.height * .07), Offset(x1, size.height * .43), frame);
    canvas.drawLine(Offset(x2, size.height * .07), Offset(x2, size.height * .43), frame);
    canvas.drawLine(Offset(size.width * .05, size.height * .28), Offset(size.width * .95, size.height * .28), frame);
    for (var i = 0; i < 8; i++) {
      final x = size.width * (.10 + i * .11);
      canvas.drawLine(Offset(x, size.height * .40), Offset(x + 20, size.height * .37), frame);
    }
  }

  void _drawArchitecture(Canvas canvas, Size size) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .045);
    for (var i = 0; i < 7; i++) {
      final x = size.width * (.04 + i * .16);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height * .12, size.width * .025, size.height * .58), const Radius.circular(10)), line);
    }
    canvas.drawLine(Offset(0, size.height * .69), Offset(size.width, size.height * .69), line);
    canvas.drawLine(Offset(0, size.height * .48), Offset(size.width, size.height * .48), line);
  }

  void _drawShelves(Canvas canvas, Size size) {
    final wood = Paint()..color = const Color(0xff26243a).withValues(alpha: .62);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .06);
    final left = Rect.fromLTWH(size.width * .015, size.height * .43, size.width * .14, size.height * .24);
    final right = Rect.fromLTWH(size.width * .845, size.height * .43, size.width * .14, size.height * .24);
    for (final r in [left, right]) {
      canvas.drawRect(r, wood);
      for (var row = 0; row < 4; row++) {
        final y = r.top + 12 + row * (r.height / 4);
        canvas.drawLine(Offset(r.left + 5, y), Offset(r.right - 5, y), edge);
      }
    }
  }

  void _drawPlants(Canvas canvas, Size size, double p) {
    final leaf = Paint()..color = const Color(0xff557b68).withValues(alpha: .32);
    final stem = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xff6b927a).withValues(alpha: .30);
    for (final base in [Offset(size.width * .17, size.height * .66), Offset(size.width * .81, size.height * .66)]) {
      canvas.drawLine(base, base + Offset(0, -size.height * .15), stem);
      for (var i = 0; i < 6; i++) {
        final y = base.dy - size.height * (.035 + i * .022);
        final side = i.isEven ? -1.0 : 1.0;
        final sway = math.sin(progress * math.pi * 2 + i) * 2;
        canvas.drawOval(Rect.fromCenter(center: Offset(base.dx + side * (8 + i * 2) + sway, y), width: 22, height: 9), leaf);
      }
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(base.dx - 15, base.dy - 4, 30, 19), const Radius.circular(6)), Paint()..color = const Color(0xff39354a).withValues(alpha: .65));
    }
  }

  void _drawResearchBoard(Canvas canvas, Size size) {
    final board = RRect.fromRectAndRadius(Rect.fromLTWH(size.width * .19, size.height * .13, size.width * .17, size.height * .15), const Radius.circular(12));
    canvas.drawRRect(board, Paint()..color = const Color(0xff0d1220).withValues(alpha: .72));
    canvas.drawRRect(board, Paint()..style = PaintingStyle.stroke..color = accent.withValues(alpha: .14));
    final l = Paint()..color = Colors.white.withValues(alpha: .08)..strokeWidth = 2;
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(Offset(size.width * .205, size.height * (.16 + i * .027)), Offset(size.width * (.33 - i * .018), size.height * (.16 + i * .027)), l);
    }
  }

  void _drawTerminals(Canvas canvas, Size size, double p) {
    final glow = Paint()..color = accent.withValues(alpha: .05 + p * .025)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    for (final x in [size.width * .40, size.width * .58]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height * .38, size.width * .08, size.height * .07), const Radius.circular(8)), Paint()..color = const Color(0xff111727).withValues(alpha: .75));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 7, size.height * .39, size.width * .065, size.height * .045), const Radius.circular(5)), glow);
    }
  }

  void _drawTable(Canvas canvas, Size size, double p) {
    final center = Offset(size.width * .50, size.height * .69);
    final table = Paint()..color = const Color(0xff0a0e1b).withValues(alpha: .88);
    final edge = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.3..color = accent.withValues(alpha: .23 + .05 * p);
    canvas.drawOval(Rect.fromCenter(center: center, width: size.width * .47, height: size.height * .11), table);
    canvas.drawOval(Rect.fromCenter(center: center, width: size.width * .47, height: size.height * .11), edge);
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(Rect.fromCenter(center: center + Offset(0, i * 4.0), width: size.width * (.27 + i * .08), height: size.height * (.035 + i * .015)), edge);
    }
    canvas.drawCircle(center.translate(0, -3), 5 + p * 2, Paint()..color = accent.withValues(alpha: .18));
  }

  void _drawFloor(Canvas canvas, Size size, double p) {
    final grid = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.white.withValues(alpha: .035);
    final horizon = size.height * .70;
    for (var i = -8; i <= 8; i++) {
      final x = size.width / 2 + i * size.width / 10;
      canvas.drawLine(Offset(x, horizon), Offset(size.width / 2 + i * size.width / 3.0, size.height), grid);
    }
    canvas.drawLine(Offset(0, horizon), Offset(size.width, horizon), grid);
  }

  @override
  bool shouldRepaint(covariant S7BureauBackdrop oldDelegate) => oldDelegate.progress != progress || oldDelegate.room != room;
}

class S7BureauCharacter extends StatelessWidget {
  const S7BureauCharacter({super.key, required this.identity, required this.state, required this.progress, this.scale = 1});

  final String identity;
  final String state;
  final double progress;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final isVivren = identity.toLowerCase() == 'vivren';
    final accent = isVivren ? _violet : _amber;
    return GestureDetector(
      onTap: () => _showProfile(context, isVivren),
      child: SizedBox(
        width: 190 * scale,
        height: 310 * scale,
        child: CustomPaint(painter: _CharacterPainter(isVivren: isVivren, state: state, progress: progress, accent: accent)),
      ),
    );
  }

  void _showProfile(BuildContext context, bool isVivren) {
    final accent = isVivren ? _violet : _amber;
    final name = isVivren ? 'VIVREN' : 'TARKIS';
    final role = isVivren ? 'Context Specialist · Critical Inspection' : 'Reasoning Specialist · Hypothesis Exploration';
    final quote = isVivren ? '“Connect the evidence before you trust the conclusion.”' : '“A possibility becomes useful when we can test its path.”';
    final traits = isVivren ? ['observant', 'contextual', 'skeptical', 'precise'] : ['exploratory', 'strategic', 'adaptive', 'decisive'];
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .72),
      builder: (dialog) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 360,
            margin: const EdgeInsets.all(22),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _glass.withValues(alpha: .92), borderRadius: BorderRadius.circular(24), border: Border.all(color: accent.withValues(alpha: .30)), boxShadow: [BoxShadow(color: accent.withValues(alpha: .12), blurRadius: 34)]),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .10), border: Border.all(color: accent.withValues(alpha: .30))), child: Icon(isVivren ? Icons.visibility_rounded : Icons.account_tree_rounded, color: accent)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white, shadows: [Shadow(color: accent.withValues(alpha: .65), blurRadius: 12)])), Text(role, style: const TextStyle(fontSize: 9, color: Colors.white54, height: 1.4))])),
                IconButton(onPressed: () => Navigator.pop(dialog), icon: const Icon(Icons.close, color: Colors.white54)),
              ]),
              const SizedBox(height: 18),
              Text('PERSONALITY REFLECTION', style: TextStyle(fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w800, color: accent)),
              const SizedBox(height: 7),
              Text(quote, style: TextStyle(fontSize: 14, height: 1.5, fontStyle: FontStyle.italic, color: Colors.white.withValues(alpha: .80))),
              const SizedBox(height: 16),
              Wrap(spacing: 7, runSpacing: 7, children: traits.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 8, color: Colors.white70)), backgroundColor: accent.withValues(alpha: .08), side: BorderSide(color: accent.withValues(alpha: .16))).toList()),
              const SizedBox(height: 12),
              Text(isVivren ? 'Visual responsibility: critique, assumptions, evidence quality, epistemic limits.' : 'Visual responsibility: hypotheses, branches, alternatives, counterfactual exploration.', style: TextStyle(fontSize: 9, height: 1.5, color: Colors.white.withValues(alpha: .45))),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  _CharacterPainter({required this.isVivren, required this.state, required this.progress, required this.accent});

  final bool isVivren;
  final String state;
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / 190, size.height / 310);
    canvas.save();
    canvas.scale(s);
    final cycle = progress * math.pi * 2;
    final normalized = state.toLowerCase();
    final idle = normalized == 'idle' || normalized.isEmpty;
    final dance = idle ? math.sin(cycle * 2) : 0.0;
    final bob = idle ? math.sin(cycle) * 1.5 : math.sin(cycle) * 2.8;
    final active = !idle;
    final armLift = normalized == 'receive' ? -0.20 : normalized == 'communicate' ? -0.38 : normalized == 'handoff' ? 0.26 : normalized == 'work' ? -0.10 : 0.03;
    final faceShift = normalized == 'surprised' ? -1.5 : normalized == 'focused' ? 1.0 : 0.0;

    final glow = Paint()..color = accent.withValues(alpha: active ? .17 : .09)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawOval(Rect.fromCenter(center: const Offset(95, 292), width: 115 + dance * 2, height: 25), glow);
    final halo = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = accent.withValues(alpha: active ? .42 : .16 + .04 * (math.sin(cycle) + 1));
    canvas.drawOval(Rect.fromCenter(center: Offset(95, 145 + bob), width: 118 + 8 * math.sin(cycle), height: 224), halo);
    if (active) {
      canvas.drawArc(Rect.fromCenter(center: const Offset(95, 145), width: 132, height: 238), cycle, math.pi * .75, false, halo);
    }

    canvas.translate(0, bob + dance);
    final skin = Paint()..color = isVivren ? const Color(0xffd9d5df) : const Color(0xffcbb8ad);
    final dark = Paint()..color = const Color(0xff11131c);
    final coat = Paint()..color = isVivren ? const Color(0xffd9d9e1) : const Color(0xff171a24);
    final shade = Paint()..color = isVivren ? const Color(0xffa7a9ba) : const Color(0xff2d3140);
    final hair = Paint()..color = isVivren ? const Color(0xffaeb2c8) : const Color(0xff24232d);
    final seam = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = accent.withValues(alpha: .62);

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(64, 222, 19, 55), const Radius.circular(8)), dark);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(88, 222, 19, 55), const Radius.circular(8)), dark);
    canvas.drawOval(const Rect.fromLTWH(55, 270, 35, 12), dark);
    canvas.drawOval(const Rect.fromLTWH(82, 270, 35, 12), dark);

    final body = Path()..moveTo(58, 133)..quadraticBezierTo(95, 116, 132, 133)..lineTo(140, 230)..quadraticBezierTo(113, 245, 95, 231)..quadraticBezierTo(72, 246, 47, 229)..close();
    canvas.drawPath(body, coat);
    canvas.drawPath(body, seam);
    canvas.drawPath(Path()..moveTo(88, 132)..lineTo(80, 231)..lineTo(95, 238)..lineTo(103, 132)..close(), shade);

    canvas.save();
    canvas.translate(57, 158);
    canvas.rotate(armLift);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-11, 0, 20, 72), const Radius.circular(8)), shade);
    _drawHand(canvas, const Offset(-1, 77), skin, accent, open: normalized == 'communicate' || normalized == 'handoff');
    canvas.restore();

    canvas.save();
    canvas.translate(112, 160);
    canvas.rotate(-armLift * .72);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-1, 0, 20, 68), const Radius.circular(8)), shade);
    _drawHand(canvas, const Offset(9, 73), skin, accent, open: normalized == 'communicate' || normalized == 'receive');
    canvas.restore();

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(76, 106, 38, 30), const Radius.circular(9)), skin);
    canvas.drawOval(Rect.fromLTWH(64, 54 + faceShift, 62, 76), skin);

    final hairPath = Path();
    if (isVivren) {
      hairPath..moveTo(62, 88)..quadraticBezierTo(51, 50, 78, 34 + math.sin(cycle) * 2)..quadraticBezierTo(109, 22, 128, 54)..quadraticBezierTo(132, 78, 112, 103)..lineTo(103, 72 + math.sin(cycle) * 2)..lineTo(91, 88)..lineTo(83, 61)..lineTo(69, 91)..close();
    } else {
      hairPath..moveTo(60, 88)..quadraticBezierTo(56, 48, 81, 33)..quadraticBezierTo(110, 25, 128, 56)..lineTo(117, 98)..lineTo(106, 72)..lineTo(97, 90)..lineTo(86, 66)..lineTo(73, 94)..close();
    }
    canvas.drawPath(hairPath, hair);
    for (var i = 0; i < 5; i++) {
      final sway = math.sin(cycle + i) * 2.5;
      canvas.drawLine(Offset(68 + i * 11, 51 + i * 2), Offset(60 + i * 12 + sway, 92 + i * 2), seam);
    }

    final eye = Paint()..color = accent.withValues(alpha: .92);
    final eyeH = normalized == 'surprised' ? 6.0 : normalized == 'focused' ? 3.0 : 4.0;
    canvas.drawOval(Rect.fromLTWH(74, 83, 12, eyeH), eye);
    canvas.drawOval(Rect.fromLTWH(101, 83, 12, eyeH), eye);
    final mouth = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0xff4b4650).withValues(alpha: .72);
    final mouthRect = Rect.fromLTWH(89, 93, 15, normalized == 'smiling' ? 9 : 6);
    canvas.drawArc(mouthRect, normalized == 'smiling' ? 0 : math.pi, math.pi, false, mouth);

    final pendant = Path()..moveTo(95, 139)..lineTo(103, 150)..lineTo(95, 162)..lineTo(87, 150)..close();
    canvas.drawPath(pendant, Paint()..color = accent.withValues(alpha: .86));
    canvas.drawPath(pendant, seam);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(116, 216, 18, 9), const Radius.circular(3)), Paint()..color = accent.withValues(alpha: .86));
    if (active) {
      final tool = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = accent.withValues(alpha: .52);
      const center = Offset(95, 184);
      canvas.drawCircle(center, 24, tool);
      canvas.drawCircle(center, 12, tool);
      for (var i = 0; i < 6; i++) {
        final a = cycle + i * math.pi / 3;
        final q = center + Offset(math.cos(a) * 31, math.sin(a) * 18);
        canvas.drawCircle(q, 2.5, Paint()..color = accent.withValues(alpha: .9));
        canvas.drawLine(center, q, tool);
      }
    }
    if (isVivren) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(48, 183, 13, 28), const Radius.circular(4)), Paint()..color = accent.withValues(alpha: .18));
    } else {
      canvas.drawRect(const Rect.fromLTWH(129, 177, 9, 25), Paint()..color = accent.withValues(alpha: .20));
      canvas.drawCircle(const Offset(134, 174), 3, Paint()..color = accent.withValues(alpha: .82));
    }
    canvas.restore();
  }

  void _drawHand(Canvas canvas, Offset center, Paint skin, Color accent, {required bool open}) {
    canvas.drawCircle(center, 7.5, skin);
    final finger = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..strokeCap = StrokeCap.round..color = skin.color;
    final spread = open ? 7.0 : 3.0;
    for (var i = -1; i <= 2; i++) {
      canvas.drawLine(center + Offset(i * spread, -2), center + Offset(i * spread * 1.15, -9 - (i == 0 ? 2 : 0)), finger);
    }
    canvas.drawCircle(center, 1.4, Paint()..color = accent.withValues(alpha: .55));
  }

  @override
  bool shouldRepaint(covariant _CharacterPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.state != state || oldDelegate.isVivren != isVivren;
}

class S7GlassPanel extends StatefulWidget {
  const S7GlassPanel({super.key, required this.title, required this.child, this.accent, this.initiallyExpanded = true, this.width});

  final String title;
  final Widget child;
  final Color? accent;
  final bool initiallyExpanded;
  final double? width;

  @override
  State<S7GlassPanel> createState() => _S7GlassPanelState();
}

class _S7GlassPanelState extends State<S7GlassPanel> {
  late bool expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent ?? Colors.white;
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: _glass.withValues(alpha: .74),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: .19)),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: .045), blurRadius: 28), BoxShadow(color: Colors.black.withValues(alpha: .24), blurRadius: 18)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: () => setState(() => expanded = !expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 13, 12),
              child: Row(
                children: <Widget>[
                  Container(width: 3, height: 20, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: accent.withValues(alpha: .7), blurRadius: 10)])),
                  const SizedBox(width: 10),
                  Expanded(child: Text(widget.title, style: TextStyle(fontSize: 10, letterSpacing: 1.55, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: .88), shadows: [Shadow(color: accent.withValues(alpha: .25), blurRadius: 8)]))),
                  Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 19, color: Colors.white38),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(padding: const EdgeInsets.fromLTRB(15, 0, 15, 15), child: widget.child),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class S7SectionLabel extends StatelessWidget {
  const S7SectionLabel(this.text, {super.key, this.accent});

  final String text;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 9,
        letterSpacing: 1.6,
        fontWeight: FontWeight.w900,
        color: accent ?? Colors.white38,
        shadows: accent == null ? null : [Shadow(color: accent!.withValues(alpha: .5), blurRadius: 9)],
      ),
    );
  }
}

class S7Metric extends StatelessWidget {
  const S7Metric(this.label, this.value, {super.key, this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color metricAccent = accent ?? Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: metricAccent,
            shadows: [Shadow(color: metricAccent.withValues(alpha: .28), blurRadius: 9)],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 8, letterSpacing: 1.25, color: Colors.white38, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
