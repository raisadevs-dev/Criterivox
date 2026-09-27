import 'dart:math' as math;

import 'package:flutter/material.dart';

import 's8_presentation_state.dart';

/// Reference-driven, Flutter-only interior design for the S8 bureau.
///
/// These are real vector-painted decorative objects, not emoji placeholders or
/// external images. They are presentation context only and carry no authority.
class S8RoomEnvironment extends StatelessWidget {
  final S8Room room;
  final Widget child;

  const S8RoomEnvironment({
    super.key,
    required this.room,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B2132),
            Color(0xFF07131F),
            Color(0xFF02080E),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: .14),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RoomPainter(room),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: _RoomArchitecture(room),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: _RoomDecor(room),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                106,
                18,
                104,
              ),
              child: child,
            ),
            Positioned(
              left: 18,
              right: 18,
              top: 15,
              child: _RoomSign(room),
            ),
            Positioned(
              left: 18,
              bottom: 16,
              child: _FloorLabel(room),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomPainter extends CustomPainter {
  final S8Room room;

  _RoomPainter(this.room);

  Color get accent => switch (room) {
        S8Room.medrus => const Color(0xFF2CCCF5),
        S8Room.epistre => const Color(0xFFB98BFF),
        S8Room.veridat => const Color(0xFF38E0A8),
        S8Room.presentation => const Color(0xFFFFC857),
        S8Room.home => const Color(0xFF4CB8FF),
      };

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height * .72;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF071622),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        horizon,
        size.width,
        size.height - horizon,
      ),
      Paint()..color = const Color(0xFF0A1824),
    );

    final glow = Paint()
      ..color = accent.withValues(alpha: .065);

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(
          0,
          0,
        ),
        width: size.width * .78,
        height: 190,
      ).shift(
        Offset(size.width / 2, 82),
      ),
      glow,
    );

    final panel = Paint()
      ..color = Colors.white.withValues(alpha: .035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 7; i++) {
      final x = i * size.width / 6;

      canvas.drawLine(
        Offset(x, 62),
        Offset(x, horizon),
        panel,
      );
    }

    canvas.drawLine(
      Offset(0, horizon),
      Offset(size.width, horizon),
      panel,
    );

    final floor = Paint()
      ..color = Colors.white.withValues(alpha: .045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = -6; i <= 6; i++) {
      canvas.drawLine(
        Offset(
          size.width / 2 + i * 55,
          horizon,
        ),
        Offset(
          size.width / 2 + i * 175,
          size.height,
        ),
        floor,
      );
    }

    for (var i = 1; i < 7; i++) {
      final y =
          horizon + (size.height - horizon) * i / 7;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        floor,
      );
    }

    final ring = Paint()
      ..color = accent.withValues(alpha: .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.width / 2,
          horizon + 43,
        ),
        width: size.width * .42,
        height: 72,
      ),
      ring,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.width / 2,
          horizon + 43,
        ),
        width: size.width * .25,
        height: 43,
      ),
      ring,
    );

    canvas.drawCircle(
      Offset(
        size.width / 2,
        horizon + 43,
      ),
      4,
      Paint()
        ..color = accent.withValues(alpha: .65),
    );
  }

  @override
  bool shouldRepaint(covariant _RoomPainter old) {
    return old.room != room;
  }
}

class _RoomArchitecture extends StatelessWidget {
  final S8Room room;

  const _RoomArchitecture(this.room);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 42,
          right: 42,
          top: 68,
          height: 160,
          child: _Window(room),
        ),
        Positioned(
          left: 17,
          top: 246,
          child: _Shelf(
            room,
            left: true,
          ),
        ),
        Positioned(
          right: 17,
          top: 246,
          child: _Shelf(
            room,
            left: false,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 105,
          child: _Furniture(room),
        ),
      ],
    );
  }
}

class _Window extends StatelessWidget {
  final S8Room room;

  const _Window(this.room);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF294B64),
            Color(0xFF10273A),
            Color(0xFF091923),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: .17),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4423B7E8),
            blurRadius: 25,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _WindowPainter(room),
      ),
    );
  }
}

class _WindowPainter extends CustomPainter {
  final S8Room room;

  _WindowPainter(this.room);

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..color = Colors.white.withValues(alpha: .16);

    canvas.drawCircle(
      Offset(
        size.width * .78,
        size.height * .22,
      ),
      18,
      sky,
    );

    final mountain = Paint()
      ..color = const Color(0xFF17374C);

    final path = Path()
      ..moveTo(
        0,
        size.height * .75,
      )
      ..lineTo(
        size.width * .16,
        size.height * .38,
      )
      ..lineTo(
        size.width * .31,
        size.height * .68,
      )
      ..lineTo(
        size.width * .49,
        size.height * .31,
      )
      ..lineTo(
        size.width * .64,
        size.height * .64,
      )
      ..lineTo(
        size.width * .83,
        size.height * .39,
      )
      ..lineTo(
        size.width,
        size.height * .69,
      )
      ..lineTo(
        size.width,
        size.height,
      )
      ..lineTo(
        0,
        size.height,
      )
      ..close();

    canvas.drawPath(path, mountain);

    final city = Paint()
      ..color = const Color(0xFF091B29);

    for (var i = 0; i < 17; i++) {
      final x = i * size.width / 16;
      final h = 14.0 + (i % 5) * 9;

      canvas.drawRect(
        Rect.fromLTWH(
          x,
          size.height * .80 - h,
          11 + (i % 3) * 3,
          h,
        ),
        city,
      );
    }

    final trees = Paint()
      ..color = const Color(0xFF103A34);

    for (var i = 0; i < 8; i++) {
      final x = 10.0 + i * size.width / 8;

      canvas.drawCircle(
        Offset(
          x,
          size.height * .79,
        ),
        10 + (i % 3) * 4,
        trees,
      );

      canvas.drawRect(
        Rect.fromLTWH(
          x - 2,
          size.height * .79,
          4,
          22,
        ),
        Paint()
          ..color = const Color(0xFF20362E),
      );
    }

    final mullion = Paint()
      ..color = Colors.white.withValues(alpha: .13)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(size.width * .5, 0),
      Offset(size.width * .5, size.height),
      mullion,
    );

    canvas.drawLine(
      Offset(0, size.height * .57),
      Offset(size.width, size.height * .57),
      mullion,
    );
  }

  @override
  bool shouldRepaint(covariant _WindowPainter old) {
    return old.room != room;
  }
}

class _Shelf extends StatelessWidget {
  final S8Room room;
  final bool left;

  const _Shelf(
    this.room, {
    required this.left,
  });

  List<String> get labels => switch (room) {
        S8Room.medrus => left
            ? [
                'OBSERVATION',
                'EXPERIMENTS',
                'EVIDENCE',
                'LAB NOTES',
                'METHODS',
              ]
            : [
                'DATA',
                'RECEIPTS',
                'TOOLS',
                'SAMPLES',
                'RESULTS',
              ],
        S8Room.epistre => left
            ? [
                'HISTORY',
                'CULTURES',
                'PROVENANCE',
                'ARCHIVE',
                'SOURCES',
              ]
            : [
                'LINEAGE',
                'EXPLANATION',
                'ATTRIBUTION',
                'STORIES',
                'MEMORY',
              ],
        S8Room.veridat => left
            ? [
                'VALIDATION',
                'SOURCES',
                'INTEGRITY',
                'TESTS',
                'CHECKS',
              ]
            : [
                'CONFLICTS',
                'RECEIPTS',
                'TRUTH',
                'VALIDITY',
                'LIMITS',
              ],
        S8Room.presentation => left
            ? [
                'QUESTIONS',
                'CONTEXT',
                'ACTIONS',
                'CASES',
                'REVIEW',
              ]
            : [
                'INSPECT',
                'TRACE',
                'CHALLENGE',
                'DECIDE',
                'HISTORY',
              ],
        S8Room.home => left
            ? [
                'KNOWLEDGE',
                'EVIDENCE',
                'MEMORY',
                'SOURCES',
                'CONTEXT',
              ]
            : [
                'TRACE',
                'TRUTH',
                'PROVENANCE',
                'ACTION',
                'RECORDS',
              ],
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 220,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xE50A121A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: .10),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 5,
            margin: const EdgeInsets.only(bottom: 6),
            color: const Color(0xFF435664),
          ),
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                decoration: BoxDecoration(
                  color: i.isEven
                      ? const Color(0xFF1B2B39)
                      : const Color(0xFF132330),
                  borderRadius:
                      BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        labels[i],
                        style: const TextStyle(
                          fontSize: 6.4,
                          letterSpacing: .55,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 18 + (i % 2) * 5,
                      color: const Color(0xFFD0A960),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Furniture extends StatelessWidget {
  final S8Room room;

  const _Furniture(this.room);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 23,
          right: 23,
          bottom: 0,
          height: 66,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xEE09131B),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: .11),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 50,
          bottom: 28,
          child: _Chair(),
        ),
        const Positioned(
          right: 50,
          bottom: 28,
          child: _Chair(),
        ),
        Positioned(
          left: 96,
          right: 96,
          bottom: 15,
          height: 55,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              color: const Color(0xF00A1721),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: .13),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                _Lamp(room),
                _Monitor(room),
                _PlantPot(
                  kind: _plantFor(room),
                ),
                _PaperStack(room),
                _Drink(room),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Chair extends StatelessWidget {
  const _Chair();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 60,
      height: 62,
      child: CustomPaint(
        painter: _ChairPainter(),
      ),
    );
  }
}

class _ChairPainter extends CustomPainter {
  const _ChairPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1B2B38);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          8,
          4,
          44,
          32,
        ),
        const Radius.circular(10),
      ),
      p,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          13,
          30,
          34,
          11,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF2B414E),
    );

    final metal = Paint()
      ..color = const Color(0xFF6C7E88)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      const Offset(30, 41),
      const Offset(30, 56),
      metal,
    );

    canvas.drawLine(
      const Offset(30, 51),
      const Offset(17, 59),
      metal,
    );

    canvas.drawLine(
      const Offset(30, 51),
      const Offset(43, 59),
      metal,
    );
  }

  @override
  bool shouldRepaint(covariant _ChairPainter old) {
    return false;
  }
}

class _Lamp extends StatelessWidget {
  final S8Room room;

  const _Lamp(this.room);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 38),
      painter: _LampPainter(room),
    );
  }
}

class _LampPainter extends CustomPainter {
  final S8Room room;

  _LampPainter(this.room);

  @override
  void paint(Canvas canvas, Size size) {
    final accent = _accent(room);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          5,
          3,
          18,
          13,
        ),
        const Radius.circular(7),
      ),
      Paint()..color = const Color(0xFF2A3B47),
    );

    canvas.drawCircle(
      const Offset(14, 10),
      5,
      Paint()..color = accent.withValues(alpha: .85),
    );

    canvas.drawLine(
      const Offset(14, 16),
      const Offset(14, 33),
      Paint()
        ..color = const Color(0xFF74838B)
        ..strokeWidth = 2,
    );

    canvas.drawLine(
      const Offset(7, 34),
      const Offset(21, 34),
      Paint()
        ..color = const Color(0xFF74838B)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _LampPainter old) {
    return old.room != room;
  }
}

class _Monitor extends StatelessWidget {
  final S8Room room;

  const _Monitor(this.room);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(52, 39),
      painter: _MonitorPainter(room),
    );
  }
}

class _MonitorPainter extends CustomPainter {
  final S8Room room;

  _MonitorPainter(this.room);

  @override
  void paint(Canvas canvas, Size size) {
    final accent = _accent(room);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          3,
          2,
          46,
          28,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF0D1720),
    );

    final line = Paint()
      ..color = accent.withValues(alpha: .65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRect(
      const Rect.fromLTWH(
        7,
        6,
        38,
        20,
      ),
      line,
    );

    canvas.drawLine(
      const Offset(10, 20),
      const Offset(18, 14),
      line,
    );

    canvas.drawLine(
      const Offset(18, 14),
      const Offset(27, 18),
      line,
    );

    canvas.drawLine(
      const Offset(27, 18),
      const Offset(40, 10),
      line,
    );

    canvas.drawLine(
      const Offset(10, 23),
      const Offset(42, 23),
      line,
    );

    canvas.drawLine(
      const Offset(26, 30),
      const Offset(26, 35),
      Paint()
        ..color = const Color(0xFF71808A)
        ..strokeWidth = 2,
    );

    canvas.drawLine(
      const Offset(18, 36),
      const Offset(34, 36),
      Paint()
        ..color = const Color(0xFF71808A)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _MonitorPainter old) {
    return old.room != room;
  }
}

class _PaperStack extends StatelessWidget {
  final S8Room room;

  const _PaperStack(this.room);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(31, 35),
      painter: _PaperPainter(room),
    );
  }
}

class _PaperPainter extends CustomPainter {
  final S8Room room;

  _PaperPainter(this.room);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromLTWH(
        3 + i * 2,
        4 + i * 2,
        22,
        25,
      );

      canvas.drawRect(
        rect,
        Paint()..color = const Color(0xFFD7D0C4),
      );
    }

    final ink = Paint()
      ..color = _accent(room).withValues(alpha: .55)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(7, 10 + i * 4),
        Offset(22, 10 + i * 4),
        ink,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PaperPainter old) {
    return old.room != room;
  }
}

class _Drink extends StatelessWidget {
  final S8Room room;

  const _Drink(this.room);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(27, 35),
      painter: _DrinkPainter(room),
    );
  }
}

class _DrinkPainter extends CustomPainter {
  final S8Room room;

  _DrinkPainter(this.room);

  @override
  void paint(Canvas canvas, Size size) {
    final accent = _accent(room);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          4,
          7,
          17,
          17,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFB8A486),
    );

    canvas.drawArc(
      const Rect.fromLTWH(
        18,
        10,
        9,
        11,
      ),
      -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFB8A486)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawOval(
      const Rect.fromLTWH(
        5,
        5,
        15,
        5,
      ),
      Paint()..color = const Color(0xFF473528),
    );

    canvas.drawCircle(
      const Offset(12, 15),
      2,
      Paint()
        ..color = accent.withValues(alpha: .45),
    );
  }

  @override
  bool shouldRepaint(covariant _DrinkPainter old) {
    return old.room != room;
  }
}

PlantKind _plantFor(S8Room room) => switch (room) {
      S8Room.medrus => PlantKind.cactus,
      S8Room.epistre => PlantKind.flower,
      S8Room.veridat => PlantKind.succulent,
      S8Room.presentation => PlantKind.palm,
      S8Room.home => PlantKind.tree,
    };

enum PlantKind {
  cactus,
  tree,
  palm,
  fern,
  flower,
  grass,
  succulent,
  vine,
  herb,
}

class _PlantPot extends StatelessWidget {
  final PlantKind kind;

  const _PlantPot({
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 52,
      child: CustomPaint(
        painter: _PlantPainter(kind),
      ),
    );
  }
}

class _PlantPainter extends CustomPainter {
  final PlantKind kind;

  _PlantPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = const Color(0xFF4B8A63)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final leaf = Paint()
      ..color = const Color(0xFF2D7654);

    final light = Paint()
      ..color = const Color(0xFF5C9C6E);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          9,
          35,
          24,
          14,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF705039),
    );

    canvas.drawLine(
      const Offset(21, 36),
      const Offset(21, 16),
      stem,
    );

    switch (kind) {
      case PlantKind.cactus:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(
              15,
              10,
              12,
              27,
            ),
            const Radius.circular(8),
          ),
          leaf,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(
              8,
              20,
              9,
              6,
            ),
            const Radius.circular(4),
          ),
          light,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(
              25,
              18,
              9,
              6,
            ),
            const Radius.circular(4),
          ),
          light,
        );
        break;

      case PlantKind.palm:
        for (var i = 0; i < 7; i++) {
          _leaf(
            canvas,
            const Offset(21, 16),
            i * math.pi / 3.3,
            light,
            14,
          );
        }
        break;

      case PlantKind.flower:
        for (var i = 0; i < 6; i++) {
          canvas.drawCircle(
            Offset(
              21 + math.cos(i * math.pi / 3) * 7,
              15 + math.sin(i * math.pi / 3) * 7,
            ),
            5,
            light,
          );
        }

        canvas.drawCircle(
          const Offset(21, 15),
          3,
          Paint()..color = const Color(0xFFD7B66A),
        );

        for (var i = 0; i < 5; i++) {
          _leaf(
            canvas,
            Offset(
              21,
              22 + i * 2,
            ),
            i * .9,
            leaf,
            9,
          );
        }
        break;

      default:
        for (var i = 0; i < 9; i++) {
          _leaf(
            canvas,
            Offset(
              21,
              16 + (i % 3) * 3,
            ),
            i.isEven ? -.8 : .8,
            i.isEven ? leaf : light,
            8 + (i % 3) * 2,
          );
        }
        break;
    }
  }

  void _leaf(
    Canvas canvas,
    Offset base,
    double angle,
    Paint paint,
    double length,
  ) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);

    canvas.drawOval(
      Rect.fromLTWH(
        0,
        -2,
        length,
        5,
      ),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PlantPainter old) {
    return old.kind != kind;
  }
}

class _RoomDecor extends StatelessWidget {
  final S8Room room;

  const _RoomDecor(this.room);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 9,
          bottom: 111,
          child: _TallPlant(
            _leftPlant(room),
          ),
        ),
        Positioned(
          right: 9,
          bottom: 111,
          child: _TallPlant(
            _rightPlant(room),
          ),
        ),
        Positioned(
          left: 128,
          top: 246,
          child: _WallResearchPanel(room),
        ),
        Positioned(
          right: 128,
          top: 246,
          child: _WallResearchPanel(room),
        ),
        Positioned(
          left: 16,
          top: 75,
          child: _WallSconce(room),
        ),
        Positioned(
          right: 16,
          top: 75,
          child: _WallSconce(room),
        ),
        Positioned(
          left: 35,
          top: 233,
          child: _DecorObject(
            kind: _leftObject(room),
            size: 34,
          ),
        ),
        Positioned(
          right: 35,
          top: 233,
          child: _DecorObject(
            kind: _rightObject(room),
            size: 34,
          ),
        ),
      ],
    );
  }
}

PlantKind _leftPlant(S8Room room) => switch (room) {
      S8Room.medrus => PlantKind.cactus,
      S8Room.epistre => PlantKind.tree,
      S8Room.veridat => PlantKind.grass,
      S8Room.presentation => PlantKind.palm,
      S8Room.home => PlantKind.tree,
    };

PlantKind _rightPlant(S8Room room) => switch (room) {
      S8Room.medrus => PlantKind.herb,
      S8Room.epistre => PlantKind.fern,
      S8Room.veridat => PlantKind.succulent,
      S8Room.presentation => PlantKind.flower,
      S8Room.home => PlantKind.vine,
    };

DecorKind _leftObject(S8Room room) => switch (room) {
      S8Room.medrus => DecorKind.flask,
      S8Room.epistre => DecorKind.book,
      S8Room.veridat => DecorKind.scale,
      S8Room.presentation => DecorKind.link,
      S8Room.home => DecorKind.orb,
    };

DecorKind _rightObject(S8Room room) => switch (room) {
      S8Room.medrus => DecorKind.calculator,
      S8Room.epistre => DecorKind.archive,
      S8Room.veridat => DecorKind.search,
      S8Room.presentation => DecorKind.calendar,
      S8Room.home => DecorKind.controller,
    };

class _TallPlant extends StatelessWidget {
  final PlantKind kind;

  const _TallPlant(this.kind);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 105,
      child: CustomPaint(
        painter: _TallPlantPainter(kind),
      ),
    );
  }
}

class _TallPlantPainter extends CustomPainter {
  final PlantKind kind;

  _TallPlantPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    final plant = Paint()
      ..color = const Color(0xFF2C7955);

    final pot = Paint()
      ..color = const Color(0xFF6B4B35);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          17,
          76,
          36,
          23,
        ),
        const Radius.circular(6),
      ),
      pot,
    );

    canvas.drawLine(
      const Offset(35, 79),
      const Offset(35, 32),
      Paint()
        ..color = const Color(0xFF4A895F)
        ..strokeWidth = 4,
    );

    if (kind == PlantKind.palm) {
      for (var i = 0; i < 9; i++) {
        canvas.save();
        canvas.translate(35, 32);
        canvas.rotate(
          -1.25 + i * .31,
        );

        canvas.drawOval(
          const Rect.fromLTWH(
            0,
            -4,
            34,
            8,
          ),
          plant,
        );

        canvas.restore();
      }
    } else if (kind == PlantKind.cactus) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(
            27,
            20,
            17,
            59,
          ),
          const Radius.circular(9),
        ),
        plant,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(
            17,
            43,
            14,
            9,
          ),
          const Radius.circular(6),
        ),
        plant,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(
            42,
            35,
            14,
            9,
          ),
          const Radius.circular(6),
        ),
        plant,
      );
    } else {
      for (var i = 0; i < 13; i++) {
        final y = 30.0 + (i % 5) * 8.0;
        final x =
            35.0 + (i.isEven ? -(i % 3) * 6.0 : (i % 3) * 6.0);

        canvas.drawOval(
          Rect.fromLTWH(
            x,
            y,
            24,
            9,
          ),
          plant,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TallPlantPainter old) {
    return old.kind != kind;
  }
}

class _WallResearchPanel extends StatelessWidget {
  final S8Room room;

  const _WallResearchPanel(this.room);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(118, 76),
      painter: _PanelPainter(room),
    );
  }
}

class _PanelPainter extends CustomPainter {
  final S8Room room;

  _PanelPainter(this.room);

  @override
  void paint(Canvas canvas, Size size) {
    final accent = _accent(room);

    final paint = Paint()
      ..color = accent.withValues(alpha: .38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(
          8,
          15 + i * 12,
        ),
        Offset(
          size.width - 8,
          15 + i * 12,
        ),
        paint,
      );
    }

    canvas.drawCircle(
      const Offset(20, 19),
      5,
      Paint()
        ..color = accent.withValues(alpha: .75),
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        62,
        10,
        38,
        27,
      ),
      paint,
    );

    canvas.drawLine(
      const Offset(68, 47),
      Offset(
        size.width - 10,
        47,
      ),
      paint,
    );

    canvas.drawCircle(
      const Offset(88, 57),
      6,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PanelPainter old) {
    return old.room != room;
  }
}

class _WallSconce extends StatelessWidget {
  final S8Room room;

  const _WallSconce(this.room);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 48),
      painter: _SconcePainter(room),
    );
  }
}

class _SconcePainter extends CustomPainter {
  final S8Room room;

  _SconcePainter(this.room);

  @override
  void paint(Canvas canvas, Size size) {
    final accent = _accent(room);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          5,
          2,
          12,
          29,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF1D2B35),
    );

    canvas.drawCircle(
      const Offset(11, 14),
      4,
      Paint()
        ..color = accent.withValues(alpha: .85),
    );

    canvas.drawLine(
      const Offset(11, 30),
      const Offset(11, 45),
      Paint()
        ..color = const Color(0xFF6A7A84)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SconcePainter old) {
    return old.room != room;
  }
}

class _DecorObject extends StatelessWidget {
  final DecorKind kind;
  final double size;

  const _DecorObject({
    required this.kind,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: kind.label,
      child: CustomPaint(
        size: Size.square(size),
        painter: _DecorPainter(kind),
      ),
    );
  }
}

enum DecorKind {
  flask,
  book,
  archive,
  calculator,
  scale,
  search,
  link,
  calendar,
  orb,
  controller,
}

extension on DecorKind {
  String get label => switch (this) {
        DecorKind.flask => 'Experiment flask',
        DecorKind.book => 'Research book',
        DecorKind.archive => 'Archive drawer',
        DecorKind.calculator => 'Research calculator',
        DecorKind.scale => 'Verification scale',
        DecorKind.search => 'Source inspection tool',
        DecorKind.link => 'Provenance link',
        DecorKind.calendar => 'Temporal calendar',
        DecorKind.orb => 'Research orb',
        DecorKind.controller => 'Interaction controller',
      };
}

class _DecorPainter extends CustomPainter {
  final DecorKind kind;

  _DecorPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFB8C9D3);

    final fill = Paint()
      ..color = const Color(0xFF203342);

    const accent = Color(0xFF69C8EA);

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (kind) {
      case DecorKind.flask:
        final path = Path()
          ..moveTo(cx - 5, 5)
          ..lineTo(cx + 5, 5)
          ..lineTo(cx + 5, 13)
          ..lineTo(cx + 12, 27)
          ..quadraticBezierTo(
            cx,
            34,
            cx - 12,
            27,
          )
          ..lineTo(cx - 5, 13)
          ..close();

        canvas.drawPath(path, paint);

        canvas.drawCircle(
          Offset(cx, 25),
          3,
          Paint()..color = accent,
        );
        break;

      case DecorKind.book:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              6,
              8,
              size.width - 12,
              size.height - 14,
            ),
            const Radius.circular(3),
          ),
          fill,
        );

        canvas.drawLine(
          Offset(cx, 9),
          Offset(cx, size.height - 7),
          paint,
        );

        canvas.drawLine(
          const Offset(10, 14),
          Offset(cx - 3, 14),
          paint,
        );

        canvas.drawLine(
          Offset(cx + 3, 14),
          Offset(size.width - 10, 14),
          paint,
        );
        break;

      case DecorKind.archive:
        canvas.drawRect(
          Rect.fromLTWH(
            6,
            7,
            size.width - 12,
            size.height - 13,
          ),
          fill,
        );

        for (var i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(10, 14 + i * 7),
            Offset(
              size.width - 10,
              14 + i * 7,
            ),
            paint,
          );
        }
        break;

      case DecorKind.calculator:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              6,
              5,
              size.width - 12,
              size.height - 10,
            ),
            const Radius.circular(5),
          ),
          fill,
        );

        canvas.drawRect(
          Rect.fromLTWH(
            10,
            9,
            size.width - 20,
            8,
          ),
          paint,
        );

        for (var i = 0; i < 6; i++) {
          canvas.drawCircle(
            Offset(
              11 + (i % 3) * 8,
              22 + (i ~/ 3) * 7,
            ),
            1.8,
            Paint()..color = accent,
          );
        }
        break;

      case DecorKind.scale:
        canvas.drawLine(
          Offset(cx, 7),
          Offset(cx, 29),
          paint,
        );

        canvas.drawLine(
          const Offset(7, 12),
          Offset(size.width - 7, 12),
          paint,
        );

        canvas.drawLine(
          const Offset(10, 13),
          const Offset(5, 27),
          paint,
        );

        canvas.drawLine(
          Offset(size.width - 10, 13),
          Offset(size.width - 5, 27),
          paint,
        );

        canvas.drawArc(
          const Rect.fromLTWH(
            0,
            22,
            10,
            5,
          ),
          0,
          math.pi,
          false,
          paint,
        );

        canvas.drawArc(
          Rect.fromLTWH(
            size.width - 10,
            22,
            10,
            5,
          ),
          0,
          math.pi,
          false,
          paint,
        );
        break;

      case DecorKind.search:
        canvas.drawCircle(
          Offset(
            cx - 3,
            cy - 3,
          ),
          9,
          paint,
        );

        canvas.drawLine(
          Offset(
            cx + 4,
            cy + 4,
          ),
          Offset(
            cx + 12,
            cy + 12,
          ),
          paint,
        );
        break;

      case DecorKind.link:
        canvas.drawOval(
          const Rect.fromLTWH(
            3,
            10,
            17,
            10,
          ),
          paint,
        );

        canvas.drawOval(
          const Rect.fromLTWH(
            14,
            10,
            17,
            10,
          ),
          paint,
        );
        break;

      case DecorKind.calendar:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              5,
              6,
              size.width - 10,
              size.height - 10,
            ),
            const Radius.circular(4),
          ),
          paint,
        );

        canvas.drawLine(
          const Offset(5, 14),
          Offset(size.width - 5, 14),
          paint,
        );

        for (var i = 0; i < 6; i++) {
          canvas.drawCircle(
            Offset(
              11 + (i % 3) * 8,
              20 + (i ~/ 3) * 8,
            ),
            1.5,
            Paint()..color = accent,
          );
        }
        break;

      case DecorKind.orb:
        canvas.drawCircle(
          Offset(cx, cy),
          12,
          Paint()
            ..color = accent.withValues(alpha: .10),
        );

        canvas.drawCircle(
          Offset(cx, cy),
          12,
          paint,
        );

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: 25,
            height: 10,
          ),
          paint,
        );

        canvas.drawLine(
          Offset(cx, cy - 12),
          Offset(cx, cy + 12),
          paint,
        );
        break;

      case DecorKind.controller:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              5,
              10,
              size.width - 10,
              17,
            ),
            const Radius.circular(9),
          ),
          fill,
        );

        canvas.drawCircle(
          const Offset(12, 18),
          2,
          Paint()..color = accent,
        );

        canvas.drawCircle(
          Offset(size.width - 12, 17),
          2,
          Paint()..color = accent,
        );

        canvas.drawLine(
          Offset(cx - 2, 18),
          Offset(cx + 4, 18),
          paint,
        );

        canvas.drawLine(
          Offset(cx + 1, 15),
          Offset(cx + 1, 21),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DecorPainter old) {
    return old.kind != kind;
  }
}

Color _accent(S8Room room) => switch (room) {
      S8Room.medrus => const Color(0xFF2CCCF5),
      S8Room.epistre => const Color(0xFFB98BFF),
      S8Room.veridat => const Color(0xFF38E0A8),
      S8Room.presentation => const Color(0xFFFFC857),
      S8Room.home => const Color(0xFF4CB8FF),
    };

class _RoomSign extends StatelessWidget {
  final S8Room room;

  const _RoomSign(this.room);

  @override
  Widget build(BuildContext context) {
    final name = switch (room) {
      S8Room.home =>
        'S8 HOME · EVIDENCE RESEARCH BUREAU',
      S8Room.medrus =>
        'MEDRUS · EVIDENCE & KNOWLEDGE ROOM',
      S8Room.epistre =>
        'EPISTRE · PROVENANCE & EXPLANATION ROOM',
      S8Room.veridat =>
        'VERIDAT · VERIFICATION & TRUTH ROOM',
      S8Room.presentation =>
        'PRESENTATION · HUMAN COLLABORATION ROOM',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xDD081722),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: .13),
        ),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _FloorLabel extends StatelessWidget {
  final S8Room room;

  const _FloorLabel(this.room);

  @override
  Widget build(BuildContext context) {
    final label = switch (room) {
      S8Room.home =>
        'SHARED RESEARCH FLOOR · FIVE REFERENCE ZONES',
      S8Room.medrus =>
        'EXPERIMENT BENCH · EVIDENCE VAULT',
      S8Room.epistre =>
        'KNOWLEDGE DESK · PROVENANCE ARCHIVE',
      S8Room.veridat =>
        'VERIFICATION STATION · INTEGRITY LAB',
      S8Room.presentation =>
        'COLLABORATION TABLE · DEBATE ARENA',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xDD08131C),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Colors.white.withValues(alpha: .10),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8.5,
          letterSpacing: .7,
          color: Colors.white70,
        ),
      ),
    );
  }
}