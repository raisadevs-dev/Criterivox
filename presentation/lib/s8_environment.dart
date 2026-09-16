import 'package:flutter/material.dart';

import 's8_presentation_state.dart';

/// S8 interior environment. Everything is rendered with Flutter primitives and
/// glyphs: no external environmental images are required.
///
/// The room is decorative presentation only. It never carries epistemic truth
/// or computational state. Room-specific furniture and objects make the four
/// spaces visually distinct while preserving one shared Criterivox world.
class S8RoomEnvironment extends StatelessWidget {
  final S8Room room;
  final Widget child;

  const S8RoomEnvironment({super.key, required this.room, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF081A2B), Color(0xFF06111C), Color(0xFF030A12)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Positioned.fill(child: _RoomBackdrop()),
            Positioned.fill(child: IgnorePointer(child: _WindowAndArchitecture(room: room))),
            Positioned.fill(child: IgnorePointer(child: _EnvironmentalDecor(room: room))),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 112, 18, 28),
              child: child,
            ),
            Positioned(
              left: 18,
              top: 18,
              right: 18,
              child: _RoomSign(room: room),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomBackdrop extends StatelessWidget {
  const _RoomBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackdropPainter());
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final floorY = size.height * .86;
    final floor = Paint()..color = const Color(0xFF0A1723);
    canvas.drawRect(Rect.fromLTWH(0, floorY, size.width, size.height - floorY), floor);

    final line = Paint()
      ..color = Colors.white.withValues(alpha: .055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 9; i++) {
      final y = floorY + (size.height - floorY) * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    for (var i = -5; i <= 5; i++) {
      canvas.drawLine(
        Offset(size.width / 2 + i * 100, floorY),
        Offset(size.width / 2 + i * 230, size.height),
        line,
      );
    }

    final glow = Paint()..color = const Color(0xFF1E86B6).withValues(alpha: .08);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, floorY), width: size.width * .65, height: 70),
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) => false;
}

class _WindowAndArchitecture extends StatelessWidget {
  final S8Room room;
  const _WindowAndArchitecture({required this.room});

  @override
  Widget build(BuildContext context) {
    final outside = switch (room) {
      S8Room.medrus => '⛅ 🌄 🌲 🌳 🌱',
      S8Room.epistre => '🌇 🌃 🌌 🌉 ✨',
      S8Room.veridat => '⛅ 🌄 🌵 🌾 🌿',
      S8Room.presentation => '🌈 💫 ✨ 🌆 🌉',
      S8Room.home => '⛅ 🌄 🌳 🌴 ✨',
    };

    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(34, 74, 34, 0),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(colors: [Color(0xFF173A50), Color(0xFF0B2235)]),
                  border: Border.all(color: Colors.white.withValues(alpha: .12)),
                  boxShadow: const [BoxShadow(color: Color(0x331EA7D8), blurRadius: 30, spreadRadius: -8)],
                ),
                child: Column(
                  children: [
                    Expanded(child: Center(child: Text(outside, style: const TextStyle(fontSize: 30, letterSpacing: 12)))) ,
                    Row(
                      children: List.generate(6, (i) => Expanded(child: Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 3), color: Colors.white.withValues(alpha: .12)))),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _Shelf(title: _leftShelf(room)),
                  const SizedBox(width: 14),
                  Expanded(child: Container()),
                  const SizedBox(width: 14),
                  _Shelf(title: _rightShelf(room)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _leftShelf(S8Room room) => switch (room) {
        S8Room.medrus => 'OBSERVE\nEXPERIMENT\nEVIDENCE',
        S8Room.epistre => 'HISTORY\nCULTURES\nPROVENANCE',
        S8Room.veridat => 'VERIFY\nSOURCES\nINTEGRITY',
        S8Room.presentation => 'QUESTIONS\nCONTEXT\nACTIONS',
        S8Room.home => 'KNOWLEDGE\nEVIDENCE\nMEMORY',
      };

  String _rightShelf(S8Room room) => switch (room) {
        S8Room.medrus => 'DATA\nMETHODS\nLAB NOTES',
        S8Room.epistre => 'ARCHIVE\nLINEAGE\nEXPLANATION',
        S8Room.veridat => 'CONFLICTS\nTESTS\nRECEIPTS',
        S8Room.presentation => 'INSPECT\nTRACE\nCHALLENGE',
        S8Room.home => 'SOURCES\nTRACE\nTRUTH BOUNDARY',
      };
}

class _Shelf extends StatelessWidget {
  final String title;
  const _Shelf({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xB307121D),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x334AA5CC)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (final label in title.split('\n'))
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF152636), borderRadius: BorderRadius.circular(3)),
                      child: Text(label, style: const TextStyle(fontSize: 7, letterSpacing: .8)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnvironmentalDecor extends StatelessWidget {
  final S8Room room;
  const _EnvironmentalDecor({required this.room});

  @override
  Widget build(BuildContext context) {
    final plants = switch (room) {
      S8Room.medrus => ['🌵', '🌱', '🌿'],
      S8Room.epistre => ['🌳', '🍃', '🌸'],
      S8Room.veridat => ['🌾', '🌿', '☘'],
      S8Room.presentation => ['🌴', '🌺', '🌱'],
      S8Room.home => ['🌲', '🌵', '🌿'],
    };
    final desk = switch (room) {
      S8Room.medrus => ['💻', '🧮', '🧾', '🔬'],
      S8Room.epistre => ['📚', '📜', '📑', '🔖'],
      S8Room.veridat => ['💻', '📊', '🔎', '⚖'],
      S8Room.presentation => ['🖥', '📈', '🗓', '🔍'],
      S8Room.home => ['💻', '🔮', '📊', '📚'],
    };

    return Stack(
      children: [
        Positioned(left: 18, bottom: 18, child: _PlantCluster(items: plants)),
        Positioned(right: 18, bottom: 18, child: _PlantCluster(items: plants.reversed.toList())),
        Positioned(left: 135, right: 135, bottom: 15, child: _ResearchDesk(room: room, objects: desk)),
        Positioned(left: 32, top: 88, child: _DecorColumn(items: _ambient(room))),
        Positioned(right: 32, top: 88, child: _DecorColumn(items: _ambient(room).reversed.toList())),
      ],
    );
  }

  List<String> _ambient(S8Room room) => switch (room) {
        S8Room.medrus => ['🧪', '🥤', '📌', '🖇'],
        S8Room.epistre => ['☕', '🍵', '🗂', '🗞'],
        S8Room.veridat => ['🔋', '📡', '🔌', '🔍'],
        S8Room.presentation => ['🧸', '🥂', '📎', '🔗'],
        S8Room.home => ['☕', '🕹', '📁', '✨'],
      };
}

class _PlantCluster extends StatelessWidget {
  final List<String> items;
  const _PlantCluster({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(width: 28, height: 34, decoration: BoxDecoration(color: const Color(0xFF6D4D32), borderRadius: BorderRadius.circular(7))),
        const SizedBox(width: 3),
        for (final item in items) Padding(padding: const EdgeInsets.only(right: 2), child: Text(item, style: const TextStyle(fontSize: 27))),
      ],
    );
  }
}

class _ResearchDesk extends StatelessWidget {
  final S8Room room;
  final List<String> objects;
  const _ResearchDesk({required this.room, required this.objects});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xE20A1824),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: Colors.white.withValues(alpha: .14)),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final item in objects) _DeskObject(emoji: item),
          _DeskLabel(room: room),
        ],
      ),
    );
  }
}

class _DeskObject extends StatelessWidget {
  final String emoji;
  const _DeskObject({required this.emoji});

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xFF112638), borderRadius: BorderRadius.circular(9), border: Border.all(color: Colors.white.withValues(alpha: .08))),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      );
}

class _DeskLabel extends StatelessWidget {
  final S8Room room;
  const _DeskLabel({required this.room});

  @override
  Widget build(BuildContext context) => Text(
        switch (room) {
          S8Room.medrus => 'EXPERIMENT BENCH',
          S8Room.epistre => 'KNOWLEDGE DESK',
          S8Room.veridat => 'VERIFICATION STATION',
          S8Room.presentation => 'COLLABORATION TABLE',
          S8Room.home => 'SHARED RESEARCH TABLE',
        },
        style: const TextStyle(fontSize: 9, letterSpacing: 1.1, color: Colors.white70),
      );
}

class _DecorColumn extends StatelessWidget {
  final List<String> items;
  const _DecorColumn({required this.items});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xB20B1C2A),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white.withValues(alpha: .08)),
                ),
                child: Text(item, style: const TextStyle(fontSize: 21)),
              ),
            ),
        ],
      );
}

class _RoomSign extends StatelessWidget {
  final S8Room room;
  const _RoomSign({required this.room});

  @override
  Widget build(BuildContext context) {
    final data = switch (room) {
      S8Room.home => ('S8 INTELLIGENCE ENVIRONMENT', 'Four rooms · shared artifacts · one coherent evidence world'),
      S8Room.medrus => ('MEDRUS · EVIDENCE & MEMORY LAB', 'Observation · experiments · evidence · temporal memory'),
      S8Room.epistre => ('EPISTRE · PROVENANCE & KNOWLEDGE STUDY', 'History · attribution · transformation · explanation'),
      S8Room.veridat => ('VERIDAT · VERIFICATION LAB', 'Grounding · source tracing · contradiction · integrity'),
      S8Room.presentation => ('PRESENTATION · HUMAN COLLABORATION', 'Inspect · trace · question · challenge · revise'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xD8091928),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: Column(
        children: [
          Text(data.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 3),
          Text(data.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }
}
