import 'package:flutter/material.dart';

import 's8_presentation_state.dart';

/// Flutter-only interior environment for S8.
///
/// The reference environment is treated as a designed space, not a portrait
/// backdrop. Furniture, shelves, plants, lighting, tools, papers, screens and
/// ambient objects are arranged by room. No external environment images are
/// required and none of these decorative elements carries computational truth.
class S8RoomEnvironment extends StatelessWidget {
  final S8Room room;
  final Widget child;

  const S8RoomEnvironment({super.key, required this.room, required this.child});

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1F31), Color(0xFF07131F), Color(0xFF030A12)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _InteriorPainter(room))),
            Positioned.fill(child: IgnorePointer(child: _RoomArchitecture(room))),
            Positioned.fill(child: IgnorePointer(child: _RoomDecor(room))),
            Theme(
              data: baseTheme.copyWith(
                cardTheme: baseTheme.cardTheme.copyWith(
                  color: const Color(0xC9081725),
                  elevation: 8,
                  margin: const EdgeInsets.all(4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withValues(alpha: .10)),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 104, 18, 96),
                child: child,
              ),
            ),
            Positioned(left: 18, top: 16, right: 18, child: _RoomSign(room)),
            Positioned(left: 22, bottom: 18, child: _FloorLabel(room)),
          ],
        ),
      ),
    );
  }
}

class _InteriorPainter extends CustomPainter {
  final S8Room room;
  _InteriorPainter(this.room);

  @override
  void paint(Canvas canvas, Size size) {
    final floorY = size.height * .80;
    final accent = switch (room) {
      S8Room.medrus => const Color(0xFF2CCCF5),
      S8Room.epistre => const Color(0xFFB98BFF),
      S8Room.veridat => const Color(0xFF38E0A8),
      S8Room.presentation => const Color(0xFFFFC857),
      S8Room.home => const Color(0xFF4CB8FF),
    };

    final wall = Paint()..color = const Color(0xFF081725);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, floorY), wall);

    final ceilingGlow = Paint()..color = accent.withValues(alpha: .06);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width / 2, 50), width: size.width * .72, height: 110), ceilingGlow);

    final floor = Paint()..color = const Color(0xFF0B1824);
    canvas.drawRect(Rect.fromLTWH(0, floorY, size.width, size.height - floorY), floor);

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 8; i++) {
      final y = floorY + (size.height - floorY) * i / 7;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (var i = -7; i <= 7; i++) {
      canvas.drawLine(
        Offset(size.width / 2 + i * 70, floorY),
        Offset(size.width / 2 + i * 190, size.height),
        grid,
      );
    }

    // Architectural wall lights make the room read as an interior even when
    // the central research cards are expanded.
    final light = Paint()..color = accent.withValues(alpha: .32);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20, 74, 4, 115), const Radius.circular(2)), light);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 24, 74, 4, 115), const Radius.circular(2)), light);

    // Central floor medallion, echoing the Criterivox research-room motif.
    final ring = Paint()
      ..color = accent.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width / 2, floorY + 38), width: size.width * .34, height: 52), ring);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width / 2, floorY + 38), width: size.width * .20, height: 30), ring);
  }

  @override
  bool shouldRepaint(covariant _InteriorPainter oldDelegate) => oldDelegate.room != room;
}

class _RoomArchitecture extends StatelessWidget {
  final S8Room room;
  const _RoomArchitecture(this.room);

  @override
  Widget build(BuildContext context) {
    final outside = switch (room) {
      S8Room.medrus => ['⛅', '🌄', '🌲', '🌳', '🌱'],
      S8Room.epistre => ['🌇', '🌃', '🌌', '🌉', '✨'],
      S8Room.veridat => ['⛅', '🌵', '🌾', '🌿', '🌱'],
      S8Room.presentation => ['🌈', '💫', '✨', '🌆', '🌉'],
      S8Room.home => ['⛅', '🌄', '🌴', '🌳', '✨'],
    };
    return Stack(
      children: [
        Positioned(left: 48, right: 48, top: 66, height: 165, child: _PanoramicWindow(outside: outside)),
        Positioned(left: 22, top: 244, child: _Bookcase(labels: _leftShelf(room))),
        Positioned(right: 22, top: 244, child: _Bookcase(labels: _rightShelf(room))),
        Positioned(left: 0, right: 0, bottom: 0, height: 92, child: _FurnitureBase(room)),
      ],
    );
  }

  List<String> _leftShelf(S8Room r) => switch (r) {
    S8Room.medrus => ['OBSERVE', 'EXPERIMENT', 'EVIDENCE', 'LAB NOTES'],
    S8Room.epistre => ['HISTORY', 'CULTURES', 'PROVENANCE', 'ARCHIVE'],
    S8Room.veridat => ['VERIFY', 'SOURCES', 'INTEGRITY', 'TESTS'],
    S8Room.presentation => ['QUESTIONS', 'CONTEXT', 'ACTIONS', 'CASES'],
    S8Room.home => ['KNOWLEDGE', 'EVIDENCE', 'MEMORY', 'SOURCES'],
  };

  List<String> _rightShelf(S8Room r) => switch (r) {
    S8Room.medrus => ['DATA', 'METHODS', 'RECEIPTS', 'TOOLS'],
    S8Room.epistre => ['LINEAGE', 'EXPLANATION', 'ATTRIBUTION', 'STORIES'],
    S8Room.veridat => ['CONFLICTS', 'CHECKS', 'RECEIPTS', 'TRUST'],
    S8Room.presentation => ['INSPECT', 'TRACE', 'CHALLENGE', 'DECIDE'],
    S8Room.home => ['TRACE', 'TRUTH', 'CONTEXT', 'ACTION'],
  };
}

class _PanoramicWindow extends StatelessWidget {
  final List<String> outside;
  const _PanoramicWindow({required this.outside});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF264B68), Color(0xFF10283B)]),
      border: Border.all(color: Colors.white.withValues(alpha: .14), width: 2),
      boxShadow: const [BoxShadow(color: Color(0x5523B7E8), blurRadius: 28, spreadRadius: -8)],
    ),
    child: Stack(children: [
      Positioned.fill(child: Center(child: Text(outside.join('  '), style: const TextStyle(fontSize: 28, letterSpacing: 4)))),
      Positioned(left: 0, right: 0, bottom: 15, child: Container(height: 2, color: Colors.white.withValues(alpha: .16))),
      Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 5, color: Colors.white.withValues(alpha: .08))),
      Positioned(right: 0, top: 0, bottom: 0, child: Container(width: 5, color: Colors.white.withValues(alpha: .08))),
    ]),
  );
}

class _Bookcase extends StatelessWidget {
  final List<String> labels;
  const _Bookcase({required this.labels});

  @override
  Widget build(BuildContext context) => Container(
    width: 108,
    height: 220,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: const Color(0xD40A121B),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x444C9DC3)),
      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18)],
    ),
    child: Column(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: i.isEven ? const Color(0xFF182838) : const Color(0xFF132331),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(labels[i], style: const TextStyle(fontSize: 7, letterSpacing: .7, color: Colors.white70)),
            ),
          ),
      ],
    ),
  );
}

class _RoomDecor extends StatelessWidget {
  final S8Room room;
  const _RoomDecor(this.room);

  @override
  Widget build(BuildContext context) {
    final plants = switch (room) {
      S8Room.medrus => ['🌵', '🌱', '🌿', '🍃'],
      S8Room.epistre => ['🌳', '🌲', '🍃', '🌸'],
      S8Room.veridat => ['🌾', '🌿', '☘', '🌱'],
      S8Room.presentation => ['🌴', '🌺', '🌱', '🍀'],
      S8Room.home => ['🌲', '🌵', '🌳', '🌿'],
    };
    final table = switch (room) {
      S8Room.medrus => ['💻', '⌨', '🧮', '🧾', '📌', '🧪'],
      S8Room.epistre => ['📚', '📜', '📑', '📄', '🗂', '🔖'],
      S8Room.veridat => ['💻', '🖥', '📊', '📈', '🔎', '⚖'],
      S8Room.presentation => ['🖥', '🖱', '📊', '🗓', '🔍', '🔗'],
      S8Room.home => ['💻', '🔮', '📊', '📚', '🧸', '🕹'],
    };
    final ambient = switch (room) {
      S8Room.medrus => ['🔬', '🥤', '🔌', '🔋', '📎', '🖇'],
      S8Room.epistre => ['☕', '🍵', '🗞', '🗄', '📁', '📂'],
      S8Room.veridat => ['📡', '🔌', '🔋', '📉', '📋', '🔍'],
      S8Room.presentation => ['🧸', '🥤', '📎', '🔗', '📃', '📌'],
      S8Room.home => ['☕', '🍶', '📁', '🗳', '📰', '✨'],
    };

    return Stack(children: [
      Positioned(left: 12, bottom: 102, child: _PlantCluster(items: plants.take(2).toList(), tall: true)),
      Positioned(right: 12, bottom: 102, child: _PlantCluster(items: plants.skip(2).toList(), tall: true)),
      Positioned(left: 142, right: 142, bottom: 18, height: 72, child: _ResearchConsole(room: room, objects: table)),
      Positioned(left: 13, top: 250, child: _WallObjects(items: ambient.take(3).toList())),
      Positioned(right: 13, top: 250, child: _WallObjects(items: ambient.skip(3).toList())),
    ]);
  }
}

class _PlantCluster extends StatelessWidget {
  final List<String> items;
  final bool tall;
  const _PlantCluster({required this.items, this.tall = false});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Container(width: 30, height: tall ? 42 : 30, decoration: BoxDecoration(color: const Color(0xFF694A31), borderRadius: BorderRadius.circular(7))),
      for (final item in items) Padding(padding: const EdgeInsets.only(right: 2), child: Text(item, style: TextStyle(fontSize: tall ? 28 : 24))),
    ],
  );
}

class _ResearchConsole extends StatelessWidget {
  final S8Room room;
  final List<String> objects;
  const _ResearchConsole({required this.room, required this.objects});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xEE091722),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      border: Border.all(color: Colors.white.withValues(alpha: .15)),
      boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24)],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final item in objects) _DeskObject(item),
        Text(_label(room), style: const TextStyle(fontSize: 8, letterSpacing: 1.0, color: Colors.white70)),
      ],
    ),
  );

  String _label(S8Room r) => switch (r) {
    S8Room.medrus => 'EXPERIMENT BENCH',
    S8Room.epistre => 'KNOWLEDGE DESK',
    S8Room.veridat => 'VERIFICATION STATION',
    S8Room.presentation => 'COLLABORATION TABLE',
    S8Room.home => 'SHARED RESEARCH TABLE',
  };
}

class _DeskObject extends StatelessWidget {
  final String glyph;
  const _DeskObject(this.glyph);
  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Environmental research object',
    child: Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: const Color(0xFF112738), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withValues(alpha: .08))),
      child: Text(glyph, style: const TextStyle(fontSize: 19)),
    ),
  );
}

class _WallObjects extends StatelessWidget {
  final List<String> items;
  const _WallObjects({required this.items});
  @override
  Widget build(BuildContext context) => Column(
    children: [for (final item in items) Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xC50B1B29), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withValues(alpha: .08))),
        child: Text(item, style: const TextStyle(fontSize: 19)),
      ),
    )],
  );
}

class _FurnitureBase extends StatelessWidget {
  final S8Room room;
  const _FurnitureBase(this.room);
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 126),
      decoration: BoxDecoration(
        color: const Color(0xDD0A1722),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
    ),
  );
}

class _RoomSign extends StatelessWidget {
  final S8Room room;
  const _RoomSign(this.room);
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xDD091827), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: .14))),
      child: Column(children: [
        Text(data.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.35)),
        const SizedBox(height: 3),
        Text(data.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
      ]),
    );
  }
}

class _FloorLabel extends StatelessWidget {
  final S8Room room;
  const _FloorLabel(this.room);
  @override
  Widget build(BuildContext context) => Text(
    switch (room) {
      S8Room.home => 'CRITERIVOX · S8',
      S8Room.medrus => 'MEDRUS · EVIDENCE / EXPERIMENT / MEMORY',
      S8Room.epistre => 'EPISTRE · PROVENANCE / KNOWLEDGE / HISTORY',
      S8Room.veridat => 'VERIDAT · VERIFY / TRACE / PRESERVE',
      S8Room.presentation => 'HUMAN COLLABORATION · INSPECT / CHALLENGE / REVISE',
    },
    style: const TextStyle(fontSize: 8, letterSpacing: 1.0, color: Colors.white54),
  );
}
