import 'package:flutter/material.dart';

import 'character/character_identity.dart';
import 'character/session_character_animation.dart';
import 'foundation/criterivox_responsive_scene.dart';
import 'foundation/criterivox_scene.dart';
import 'foundation/criterivox_status.dart';
import 'foundation/criterivox_visual_tokens.dart';
import 'presentation/criterivox_theme.dart';
import 'presentation/presentation_state.dart';

class CivilizationPage extends StatefulWidget {
  final PresentationState? state;
  final ValueChanged<String>? onOpenHome;
  final VoidCallback? onOpenChat;

  const CivilizationPage({
    super.key,
    this.state,
    this.onOpenHome,
    this.onOpenChat,
  });

  /// Canonical civilization Homes exposed to presentation tests and
  /// other presentation surfaces.
  static const List<_Home> canonicalHomes = <_Home>[
    _Home(
      'context',
      'Context House',
      'Context & Data District',
      ['dharen', 'anuka'],
      'Context framing, adaptation and scope control',
    ),
    _Home(
      'data',
      'Data Stewardship House',
      'Context & Data District',
      ['sandre', 'kaelen'],
      'Data foundation, stewardship and transformation',
    ),
    _Home(
      'gateway',
      'Gateway House',
      'Interaction District',
      ['syvax'],
      'Human-machine dialogue and interaction boundary',
    ),
    _Home(
      'reasoning',
      'Reasoning House',
      'Intelligence District',
      ['vivren', 'tarkis'],
      'Critical reasoning and hypothesis exploration',
    ),
    _Home(
      'decision',
      'Decision House',
      'Decision & Insight District',
      ['pramon', 'bodhex', 'manis'],
      'Evidence, insight, alternatives and deliberation',
    ),
    _Home(
      'evidence',
      'Evidence House',
      'Evidence & Verification District',
      ['medrus', 'epistre', 'veridat'],
      'Retention, explanation and verification',
    ),
    _Home(
      'knowledge',
      'Knowledge House',
      'Knowledge District',
      ['viveda'],
      'Knowledge synthesis and reusable understanding',
    ),
  ];

  /// Compatibility/read-model alias used by existing presentation tests.
  static const List<_Home> homes = canonicalHomes;

  static const List<_Relation> relationships = <_Relation>[
    _Relation('dharen', 'vivren', 'context → reasoning'),
    _Relation('tarkis', 'medrus', 'hypothesis → evidence'),
    _Relation('medrus', 'veridat', 'evidence → verification'),
    _Relation('veridat', 'pramon', 'verification → planning'),
    _Relation('manis', 'vivren', 'challenge ↔ reasoning'),
    _Relation('viveda', 'medrus', 'knowledge ← retained evidence'),
    _Relation('syvax', 'dharen', 'human interaction → context'),
    _Relation('anukor', 'syvax', 'network routing'),
    _Relation('anukor', 'veridat', 'network routing'),
  ];

  @override
  State<CivilizationPage> createState() => _CivilizationPageState();
}

class _CivilizationPageState extends State<CivilizationPage> {
  String? selectedCharacter;
  String? selectedHome;

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final r = CriterivoxResponsive(
      MediaQuery.sizeOf(context).width,
    );

    const scene = CriterivoxSceneDescriptor(
      world: CriterivoxWorld.civilization,
      level: CriterivoxSceneLevel.world,
      id: 'criterivox-civilization',
      title: 'Criterivox Civilization',
      subtitle: 'Gate 1 · Understand the system',
    );

    return SingleChildScrollView(
      child: CriterivoxResponsiveScene(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GATE 1 · CRITERIVOX CIVILIZATION',
                        style: TextStyle(
                          color: t.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Meet the people who make the decision',
                        style: TextStyle(
                          color: t.text,
                          fontSize: r.isCompact ? 23 : 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Explore responsibilities, Homes and meaningful system relationships.',
                        style: TextStyle(
                          color: t.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                CriterivoxStatusBadge(
                  status: widget.state == null
                      ? CriterivoxStatus.ready
                      : CriterivoxStatus.active,
                  detail: widget.state == null ? 'world view' : 'runtime',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: t.surface.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: t.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_city_rounded,
                    color: t.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Start at the Bloom, explore a Home, inspect its residents and follow supported relationships. Deeper operational rooms remain future scope.',
                      style: TextStyle(
                        color: t.mutedText,
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (widget.onOpenChat != null)
                    TextButton.icon(
                      onPressed: widget.onOpenChat,
                      icon: const Icon(
                        Icons.forum_outlined,
                        size: 16,
                      ),
                      label: const Text('Syvax'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: r.isCompact ? 700 : 620,
              child: CriterivoxScene(
                descriptor: scene,
                environment: const [
                  _WorldBackdrop(),
                ],
                character: [
                  _WorldCharacters(
                    homes: CivilizationPage.canonicalHomes,
                    selectedHome: selectedHome,
                    selectedCharacter: selectedCharacter,
                    state: widget.state,
                    onHome: _selectHome,
                    onCharacter: _selectCharacter,
                  ),
                ],
                lighting: const [
                  _WorldLighting(),
                ],
                information: [
                  const _Legend(),
                  if (selectedHome != null)
                    _HomePreview(
                      home: CivilizationPage.canonicalHomes.firstWhere(
                        (home) => home.id == selectedHome,
                      ),
                      state: widget.state,
                      onEnter: () => _enterHome(selectedHome!),
                      onClose: () {
                        setState(() {
                          selectedHome = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (selectedCharacter != null) ...[
              const SizedBox(height: 14),
              _CharacterBriefing(
                id: selectedCharacter!,
                state: widget.state,
              ),
            ],
            if (r.isCompact || r.isTablet) ...[
              _BloomPanel(
                onHome: _selectHome,
                state: widget.state,
              ),
              const SizedBox(height: 12),
              _Relations(
                selected: selectedCharacter,
                onSelect: _selectCharacter,
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _BloomPanel(
                      onHome: _selectHome,
                      state: widget.state,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Relations(
                      selected: selectedCharacter,
                      onSelect: _selectCharacter,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _selectHome(String id) {
    setState(() {
      selectedHome = id;
      selectedCharacter = null;
    });
  }

  void _selectCharacter(String id) {
    final home = CivilizationPage.canonicalHomes
        .where((home) => home.residents.contains(id))
        .firstOrNull;

    setState(() {
      selectedCharacter = id;
      selectedHome = home?.id;
    });
  }

  void _enterHome(String id) {
    if (widget.onOpenHome != null) {
      widget.onOpenHome!(id);
    } else {
      setState(() {
        selectedHome = id;
      });
    }
  }
}

class _Home {
  final String id;
  final String name;
  final String district;
  final List<String> residents;
  final String responsibility;

  const _Home(
    this.id,
    this.name,
    this.district,
    this.residents,
    this.responsibility,
  );
}

class _Relation {
  final String from;
  final String to;
  final String meaning;

  const _Relation(
    this.from,
    this.to,
    this.meaning,
  );
}

class _WorldBackdrop extends StatelessWidget {
  const _WorldBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(
        CriterivoxTheme.of(context).border,
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final Color color;

  const _MapPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: .28);

    final center = Offset(
      size.width * .5,
      size.height * .48,
    );

    canvas.drawCircle(
      center,
      size.shortestSide * .17,
      paint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .68,
        height: size.height * .62,
      ),
      paint,
    );

    for (var i = 0; i < 7; i++) {
      final angle = i * 6.28318 / 7 - 1.5708;

      final point = Offset(
        center.dx + size.width * .28 * _Math.cos(angle),
        center.dy + size.height * .25 * _Math.sin(angle),
      );

      canvas.drawLine(
        center,
        point,
        paint,
      );

      canvas.drawCircle(
        point,
        42,
        paint,
      );
    }

    final street = Paint()
      ..color = color.withValues(alpha: .08)
      ..strokeWidth = 24;

    canvas.drawLine(
      Offset(
        size.width * .08,
        size.height * .86,
      ),
      Offset(
        size.width * .92,
        size.height * .86,
      ),
      street,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) {
    return old.color != color;
  }
}

/// Small deterministic trigonometric helper used by the procedural
/// civilization map. This avoids introducing another dependency.
class _Math {
  static const double pi = 3.141592653589793;

  static double sin(double x) {
    return cos(x - pi / 2);
  }

  static double cos(double x) {
    var y = x % (2 * pi);
    var term = 1.0;
    var sum = 1.0;

    for (var n = 1; n < 10; n++) {
      term *= -y * y / ((2 * n - 1) * (2 * n));
      sum += term;
    }

    return sum;
  }
}

class _WorldLighting extends StatelessWidget {
  const _WorldLighting();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: .10),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldCharacters extends StatelessWidget {
  final List<_Home> homes;
  final String? selectedHome;
  final String? selectedCharacter;
  final PresentationState? state;
  final ValueChanged<String> onHome;
  final ValueChanged<String> onCharacter;

  const _WorldCharacters({
    required this.homes,
    required this.selectedHome,
    required this.selectedCharacter,
    required this.state,
    required this.onHome,
    required this.onCharacter,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth * .5,
          constraints.maxHeight * .48,
        );

        final rx = constraints.maxWidth * .30;
        final ry = constraints.maxHeight * .29;

        return Stack(
          children: [
            Positioned(
              left: center.dx - 66,
              top: center.dy - 54,
              child: const _BloomNode(),
            ),
            for (var i = 0; i < homes.length; i++)
              _buildHomeNode(
                homes: homes,
                index: i,
                center: center,
                rx: rx,
                ry: ry,
              ),
            Positioned(
              left: center.dx - 74,
              top: constraints.maxHeight - 62,
              child: Semantics(
                button: true,
                label:
                    'Anukor, network resident, no permanent Home',
                child: ActionChip(
                  avatar: const Icon(
                    Icons.alt_route_rounded,
                    size: 15,
                  ),
                  label: const Text(
                    'Anukor · Network Territory',
                  ),
                  onPressed: () => onCharacter('anukor'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeNode({
    required List<_Home> homes,
    required int index,
    required Offset center,
    required double rx,
    required double ry,
  }) {
    final angle =
        index * 6.28318 / homes.length - 1.5708;

    final x = center.dx + rx * _Math.cos(angle);
    final y = center.dy + ry * _Math.sin(angle);

    return Positioned(
      left: x - 78,
      top: y - 86,
      child: _HomeNode(
        home: homes[index],
        selected: homes[index].id == selectedHome,
        selectedCharacter: selectedCharacter,
        state: state,
        onHome: () => onHome(homes[index].id),
        onCharacter: onCharacter,
      ),
    );
  }
}

class _BloomNode extends StatelessWidget {
  const _BloomNode();

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    return Container(
      width: 132,
      height: 108,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            t.primary.withValues(alpha: .30),
            t.surfaceStrong,
          ],
        ),
        border: Border.all(
          color: t.primary.withValues(alpha: .55),
        ),
        boxShadow: [
          BoxShadow(
            color: t.primary.withValues(alpha: .12),
            blurRadius: 26,
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.spa_rounded,
            size: 34,
          ),
          Text(
            'THE BLOOM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'spatial nexus',
            style: TextStyle(
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeNode extends StatelessWidget {
  final _Home home;
  final bool selected;
  final String? selectedCharacter;
  final PresentationState? state;
  final VoidCallback onHome;
  final ValueChanged<String> onCharacter;

  const _HomeNode({
    required this.home,
    required this.selected,
    required this.selectedCharacter,
    required this.state,
    required this.onHome,
    required this.onCharacter,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final active =
        state != null && home.residents.contains(state!.agentId);

    return Semantics(
      button: true,
      label: '${home.name}, ${home.responsibility}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onHome,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 156,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: t.surface.withValues(alpha: .94),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? t.primary : t.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  home.name,
                  style: TextStyle(
                    color: t.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  home.district,
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 7.5,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 3,
                  children: home.residents
                      .map(
                        (id) => InkWell(
                          onTap: () => onCharacter(id),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: t.page,
                            child: Text(
                              CharacterIdentities.resolve(id)
                                  .displayName
                                  .substring(0, 1),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 5),
                Text(
                  home.responsibility,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.mutedText,
                    fontSize: 7.8,
                  ),
                ),
                if (active)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: CriterivoxStatusBadge(
                      status: CriterivoxStatus.active,
                      detail: 'runtime',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    return Positioned(
      left: 12,
      top: 12,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: t.surface.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIVING HOUSEHOLD MAP',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Homes = responsibility anchors',
              style: TextStyle(fontSize: 7.5),
            ),
            Text(
              'Edges = meaningful relationships',
              style: TextStyle(fontSize: 7.5),
            ),
            Text(
              'Anukor = network resident',
              style: TextStyle(fontSize: 7.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePreview extends StatelessWidget {
  final _Home home;
  final PresentationState? state;
  final VoidCallback onEnter;
  final VoidCallback onClose;

  const _HomePreview({
    required this.home,
    required this.state,
    required this.onEnter,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final live =
        state != null && home.residents.contains(state!.agentId);

    return Positioned(
      right: 12,
      top: 12,
      width: 300,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.surfaceStrong.withValues(alpha: .97),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: t.primary.withValues(alpha: .45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    home.name,
                    style: TextStyle(
                      color: t.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  tooltip: 'Close Home preview',
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                  ),
                ),
              ],
            ),
            Text(
              home.district,
              style: TextStyle(
                color: t.primary,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              home.responsibility,
              style: TextStyle(
                color: t.mutedText,
                fontSize: 9.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Residents: ${home.residents.map((id) => CharacterIdentities.resolve(id).displayName).join(', ')}',
              style: TextStyle(
                color: t.text,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 8),
            CriterivoxStatusBadge(
              status: live
                  ? CriterivoxStatus.active
                  : CriterivoxStatus.planned,
              detail: live
                  ? 'runtime-backed'
                  : 'operational rooms deferred',
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onEnter,
              icon: const Icon(
                Icons.login,
                size: 14,
              ),
              label: const Text('Enter / inspect Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BloomPanel extends StatelessWidget {
  final ValueChanged<String> onHome;
  final PresentationState? state;

  const _BloomPanel({
    required this.onHome,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    return _Panel(
      title: 'THE BLOOM',
      subtitle: 'Spatial nexus · presentation/read-model',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: RadialGradient(
                colors: [
                  t.primary.withValues(alpha: .24),
                  t.surfaceStrong,
                ],
              ),
              border: Border.all(
                color: t.primary.withValues(alpha: .35),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.spa_rounded,
                color: t.primary,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bloom visualizes civilization state and provides Home navigation. It owns no orchestration or provenance authority.',
            style: TextStyle(
              color: t.mutedText,
              fontSize: 8.8,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 4,
            children: CivilizationPage.canonicalHomes
                .map(
                  (home) => ActionChip(
                    label: Text(
                      home.name.replaceAll(' House', ''),
                    ),
                    onPressed: () => onHome(home.id),
                  ),
                )
                .toList(),
          ),
          if (state != null)
            const Padding(
              padding: EdgeInsets.only(top: 7),
              child: CriterivoxStatusBadge(
                status: CriterivoxStatus.active,
                detail: 'runtime telemetry',
              ),
            ),
        ],
      ),
    );
  }
}

class _CharacterBriefing extends StatelessWidget {
  final String id;
  final PresentationState? state;

  const _CharacterBriefing({
    required this.id,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final profile = CharacterIdentities.resolve(id);

    final live = state?.agentId == id;
    final status = live
        ? CriterivoxStatus.active
        : CriterivoxStatus.planned;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: t.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: t.primary.withValues(alpha: .35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SessionCharacterAnimationView(
            characterId: id,
            state: live ? state!.characterState : 'IDLE',
            width: 80,
            height: 100,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHARACTER BRIEFING',
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.displayName,
                  style: TextStyle(
                    color: t.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  profile.role,
                  style: TextStyle(
                    color: t.mutedText,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Responsibility is represented here; computational authority remains in the underlying Criterivox architecture.',
                  style: TextStyle(
                    color: t.mutedText,
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    CriterivoxStatusBadge(
                      status: status,
                      detail: live
                          ? state!.characterState
                          : 'profile/read-model',
                    ),
                    CriterivoxStatusBadge(
                      status: live
                          ? CriterivoxStatus.ready
                          : CriterivoxStatus.simulated,
                      detail: 'identity',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Relations extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _Relations({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    final rows = CivilizationPage.relationships
        .where(
          (relation) =>
              selected == null ||
              relation.from == selected ||
              relation.to == selected,
        )
        .toList();

    return _Panel(
      title: 'RELATIONAL TOPOLOGY',
      subtitle:
          'Observable relationships, not a fixed execution pipeline',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rows.isEmpty)
            Text(
              'Select a character to focus supported relationships.',
              style: TextStyle(
                color: t.mutedText,
                fontSize: 9,
              ),
            ),
          for (final relation in rows.take(6))
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                '${CharacterIdentities.resolve(relation.from).displayName} → ${CharacterIdentities.resolve(relation.to).displayName} · ${relation.meaning}',
                style: TextStyle(
                  color: t.text,
                  fontSize: 8.5,
                ),
              ),
            ),
          Text(
            'Only meaningful/documented relationships are represented here.',
            style: TextStyle(
              color: t.mutedText,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final v = CriterivoxVisualTokens.of(context);

    return Container(
      padding: EdgeInsets.all(v.space3),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(v.radiusMedium),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: t.text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              color: t.mutedText,
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}