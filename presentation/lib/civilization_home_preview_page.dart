import 'package:flutter/material.dart';

import 'character/character_identity.dart';
import 'character/session_character_animation.dart';
import 'foundation/criterivox_responsive_scene.dart';
import 'foundation/criterivox_scene.dart';
import 'foundation/criterivox_status.dart';
import 'foundation/criterivox_visual_tokens.dart';
import 'level2_operational_page.dart';
import 'presentation/criterivox_theme.dart' as criterivox_theme;

class CivilizationHomePreviewPage extends StatelessWidget {
  final String homeId;
  final VoidCallback onBack;
  final VoidCallback? onChat;
  final ValueChanged<String>? onOpenOperationalHome;

  const CivilizationHomePreviewPage({
    super.key,
    required this.homeId,
    required this.onBack,
    this.onChat,
    this.onOpenOperationalHome,
  });

  static const homes = <String, _HomeInfo>{
    'context': _HomeInfo(
      'Context House',
      'Context & Data District',
      ['dharen', 'anuka'],
      'Context framing, adaptation and scope control',
      [
        'Situation Room',
        'Context Observatory',
        'Framing Desk',
        'Change Garden',
        'Context Workshop',
      ],
    ),
    'data': _HomeInfo(
      'Data Stewardship House',
      'Context & Data District',
      ['sandre', 'kaelen'],
      'Data foundation, stewardship and transformation',
      [
        'Intake Desk',
        'Data Stewardship Room',
        'Context Connection Room',
        'Temporal Context Room',
        'Data Archive',
      ],
    ),
    'gateway': _HomeInfo(
      'Gateway House',
      'Interaction District',
      ['syvax'],
      'Human-machine dialogue and interaction boundary',
      [
        'Reception Hall',
        'Intent Desk',
        'Dialogue Room',
        'Input Studio',
        'Output Gallery',
        'Human Steering Room',
      ],
    ),
    'reasoning': _HomeInfo(
      'Reasoning House',
      'Intelligence District',
      ['vivren', 'tarkis'],
      'Critical reasoning and hypothesis exploration',
      [
        'Analysis Chamber',
        'Assumption Desk',
        'Hypothesis Workshop',
        'Alternative Room',
        'Reasoning Gallery',
      ],
    ),
    'decision': _HomeInfo(
      'Decision House',
      'Decision & Insight District',
      ['pramon', 'bodhex', 'manis'],
      'Evidence, insight, alternatives and deliberation',
      [
        'Evidence Desk',
        'Insight Room',
        'Alternatives Chamber',
        'Trade-off Room',
        'Decision Desk',
      ],
    ),
    'evidence': _HomeInfo(
      'Evidence House',
      'Evidence & Verification District',
      ['medrus', 'epistre', 'veridat'],
      'Retention, explanation and verification',
      [
        'Knowledge Archive',
        'Evidence Library',
        'Explanation Chamber',
        'Verification Bureau',
        'Review Room',
      ],
    ),
    'knowledge': _HomeInfo(
      'Knowledge House',
      'Knowledge District',
      ['viveda'],
      'Knowledge synthesis and reusable understanding',
      [
        'Knowledge Hall',
        'Reference Library',
        'Learning Desk',
        'Transfer Workshop',
        'Knowledge Garden',
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);
    final v = CriterivoxVisualTokens.of(context);
    final r = CriterivoxResponsive(
      MediaQuery.sizeOf(context).width,
    );

    final home = homes[homeId] ?? homes['context']!;

    return Material(
      color: t.page,
      child: SingleChildScrollView(
        child: CriterivoxResponsiveScene(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Return to Civilization',
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GATE 1 · HOME ENTRY',
                          style: TextStyle(
                            color: t.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                          ),
                        ),
                        Text(
                          home.name,
                          style: TextStyle(
                            color: t.text,
                            fontSize: r.isCompact ? 23 : 29,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          home.district,
                          style: TextStyle(
                            color: t.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CriterivoxStatusBadge(
                    status: CriterivoxStatus.planned,
                    detail: 'operational rooms deferred',
                  ),
                ],
              ),
              SizedBox(height: v.space4),
              CriterivoxScene(
                descriptor: CriterivoxSceneDescriptor(
                  world: CriterivoxWorld.civilization,
                  level: CriterivoxSceneLevel.home,
                  id: homeId,
                  title: home.name,
                ),
                environment: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          t.primary.withValues(alpha: .12),
                          t.surface,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        v.radiusLarge,
                      ),
                      border: Border.all(
                        color: t.border,
                      ),
                    ),
                  ),
                ],
                character: [
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20,
                            runSpacing: 16,
                            children: home.residents
                                .map(
                                  (id) => _ResidentCard(id: id),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            home.responsibility,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: t.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'This is the Level 1 '
                            'Home-entry/read-model '
                            'boundary. Room operations '
                            'are intentionally deferred '
                            'to the deeper Level 2 '
                            'implementation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: t.mutedText,
                              fontSize: 10.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                lighting: const [],
                information: const [
                  Positioned(
                    left: 16,
                    top: 16,
                    child: _HomeBadge(
                      text: 'RESPONSIBILITY ANCHOR',
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: _HomeBadge(
                      text: 'GATE 1 · INSPECTION',
                    ),
                  ),
                ],
              ),
              SizedBox(height: v.space4),
              _Rooms(
                home: home,
                onOpen: () {
                  if (onOpenOperationalHome != null) {
                    onOpenOperationalHome!(homeId);
                    return;
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Level2OperationalPage(
                        homeId: homeId,
                        onBack: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: v.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onChat != null)
                    FilledButton.icon(
                      onPressed: onChat,
                      icon: const Icon(Icons.forum_outlined),
                      label: const Text('Talk to Syvax'),
                    ),
                  if (onChat != null)
                    const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Return to Civilization'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeInfo {
  final String name;
  final String district;
  final List<String> residents;
  final String responsibility;
  final List<String> rooms;

  const _HomeInfo(
    this.name,
    this.district,
    this.residents,
    this.responsibility,
    this.rooms,
  );
}

class _ResidentCard extends StatelessWidget {
  final String id;

  const _ResidentCard({
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);
    final p = CharacterIdentities.resolve(id);

    return Container(
      width: 130,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          SessionCharacterAnimationView(
            characterId: id,
            state: 'IDLE',
            width: 74,
            height: 96,
          ),
          Text(
            p.displayName,
            style: TextStyle(
              color: t.text,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          Text(
            p.role,
            textAlign: TextAlign.center,
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

class _HomeBadge extends StatelessWidget {
  final String text;

  const _HomeBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: t.surfaceStrong.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: t.mutedText,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Rooms extends StatelessWidget {
  final _HomeInfo home;
  final VoidCallback onOpen;

  const _Rooms({
    required this.home,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROOM PREVIEW',
            style: TextStyle(
              color: t.text,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Named spatial responsibilities are visible now; '
            'operational behavior belongs to later Level 2 work.',
            style: TextStyle(
              color: t.mutedText,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: home.rooms
                .map(
                  (room) => Chip(
                    avatar: Icon(
                      Icons.meeting_room_outlined,
                      size: 14,
                      color: t.primary,
                    ),
                    label: Text(room),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(
              Icons.meeting_room_outlined,
              size: 16,
            ),
            label: const Text(
              'Enter Level 2 operational spaces',
            ),
          ),
        ],
      ),
    );
  }
}