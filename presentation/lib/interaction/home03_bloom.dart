import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../presentation/criterivox_theme.dart';

class Home03Bloom extends StatefulWidget {
  final ValueChanged<String> onOpen;
  final Map<String, dynamic>? state;

  const Home03Bloom({
    super.key,
    required this.onOpen,
    this.state,
  });

  @override
  State<Home03Bloom> createState() => _Home03BloomState();
}

class _Home03BloomState extends State<Home03Bloom>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  static const homes = <List<String>>[
    ['Home 01', 'Sandre', 'stewardship'],
    ['Home 02', 'Dharen', 'context'],
    ['Home 03', 'Syvax', 'home-03'],
    ['Home 04', 'Vivren / Tarkis', 'intelligence'],
    ['Home 05', 'Pramon / Bodhex', 'planning'],
    ['Home 06', 'Medrus / Epistre / Veridat', 'evidence'],
    ['Home 07', 'Manis', 'challenge'],
    ['Home 08', 'Viveda / Anukor', 'knowledge'],
  ];

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  Set<String> get _activeHomes {
    final raw = widget.state?['active_homes'];

    if (raw is! List) {
      return <String>{};
    }

    return raw.map((entry) => entry.toString()).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);
    final active = _activeHomes;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 760.0);
        final height = size * .86;

        return SizedBox(
          width: size,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: pulse,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(size, height),
                    painter: _VinePainter(
                      active: active,
                      pulse: pulse.value,
                    ),
                  );
                },
              ),
              Container(
                width: size * .25,
                height: size * .25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.primary.withValues(alpha: .58),
                      theme.surfaceStrong,
                      theme.page,
                    ],
                  ),
                  border: Border.all(
                    color: theme.primary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primary.withValues(alpha: .24),
                      blurRadius: 34 + pulse.value * 14,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🌸',
                      style: TextStyle(
                        fontSize: size * .045,
                      ),
                    ),
                    Text(
                      'THE BLOOM',
                      style: TextStyle(
                        color: theme.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${active.length} ACTIVE',
                      style: TextStyle(
                        color: theme.mutedText,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              ..._petals(theme, size, height),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _petals(
    CriterivoxTheme theme,
    double size,
    double height,
  ) {
    final output = <Widget>[];
    final radius = size * .32;

    for (var i = 0; i < homes.length; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / homes.length;

      final x = size / 2 + math.cos(angle) * radius;
      final y = height / 2 + math.sin(angle) * radius;

      final home = homes[i];
      final homeId = home[0];
      final active = _activeHomes.contains(homeId);

      output.add(
        Positioned(
          left: x - 58,
          top: y - 58,
          child: Tooltip(
            message: 'Open $homeId · ${home[1]}',
            child: InkWell(
              borderRadius: BorderRadius.circular(60),
              onTap: () => widget.onOpen(home[2]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.primary.withValues(
                        alpha: active ? .32 : .10,
                      ),
                      theme.surfaceStrong,
                    ],
                  ),
                  border: Border.all(
                    color: theme.primary.withValues(
                      alpha: active ? 1 : .42,
                    ),
                    width: active ? 2.2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primary.withValues(
                        alpha: active ? .32 : .08,
                      ),
                      blurRadius: active ? 28 : 15,
                      spreadRadius: active ? 4 : 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_florist_rounded,
                      color: theme.primary,
                      size: 22,
                    ),
                    Text(
                      homeId,
                      style: TextStyle(
                        color: theme.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      home[1],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.mutedText,
                        fontSize: 8,
                      ),
                    ),
                    Text(
                      active ? 'ACTIVE' : 'READY',
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return output;
  }
}

class _VinePainter extends CustomPainter {
  final Set<String> active;
  final double pulse;

  _VinePainter({
    required this.active,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height * .5,
    );

    final radius = size.width * .32;

    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 8;

      final point = center +
          Offset(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
          );

      final key = 'Home ${(i + 1).toString().padLeft(2, '0')}';
      final isActive = active.contains(key);

      final lineAlpha = isActive ? .26 : .08;

      canvas.drawLine(
        center,
        point,
        Paint()
          ..color = Colors.white.withValues(alpha: lineAlpha)
          ..strokeWidth = isActive ? 2 : 1,
      );

      canvas.drawCircle(
        point,
        3 + pulse * 2,
        Paint()..color = Colors.white.withValues(alpha: .5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VinePainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.active != active;
  }
}
/*

### Corrections made

* Fixed `widget.state?['active_homes']` to valid nullable-map access.
* Added a single `_activeHomes` getter so state extraction is not duplicated.
* Fixed malformed ternaries such as `active?.32:.10`.
* Fixed the broken `BoxShadow` constructor nesting.
* Fixed the painter's malformed `active.contains(key)?.18:0`.
* Explicitly calculated the vine-line alpha.
* Added proper `Offset` construction for `Canvas.drawLine`.
* Preserved the existing eight-home radial Bloom architecture and routing IDs.
* Preserved `onOpen(home[2])`.
* Preserved the active/ready visual state.
* Kept `withValues(alpha: ...)`, avoiding the deprecated `Color.value` path.

One architectural detail is worth noting: **Home 03 remains represented as `['Home 03', 'Syvax', 'home-03']`**, so this correction does not silently alter the existing route contract.
*/
