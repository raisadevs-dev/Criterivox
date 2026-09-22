import 'package:flutter/material.dart';

import 'character/character_identity.dart';
import 'presentation/criterivox_theme.dart';

class AppIntroductionPage extends StatelessWidget {
  final VoidCallback onOpenWorkspace;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenCivilization;

  const AppIntroductionPage({
    super.key,
    required this.onOpenWorkspace,
    required this.onOpenChat,
    required this.onOpenCivilization,
  });

  static const _specialists = <String>[
    'Sandre',
    'Kaelen',
    'Dharen',
    'Anuka',
    'Syvax',
    'Vivren',
    'Tarkis',
    'Pramon',
    'Bodhex',
    'Medrus',
    'Epistre',
    'Veridat',
    'Manis',
    'Viveda',
    'Anukor',
  ];

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            compact ? 14 : 28,
            24,
            compact ? 14 : 28,
            36,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _townHallHero(t, compact),
              const SizedBox(height: 22),
              _civilizationRegistry(t, compact),
              const SizedBox(height: 22),
              _capabilities(t),
            ],
          ),
        );
      },
    );
  }

  Widget _townHallHero(CriterivoxTheme t, bool compact) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: t.border),
        color: t.surfaceStrong,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: compact ? 1.15 : 2.15,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/introduction/criterivox_15_specialists.webp',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: t.surfaceStrong,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'CRITERIVOX\n15 SPECIALISTS · 15 PERSPECTIVES · ONE MISSION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: t.text,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    );
                  },
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .08),
                        Colors.black.withValues(alpha: .18),
                        Colors.black.withValues(alpha: .82),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: compact ? 18 : 30,
                  right: compact ? 18 : 30,
                  bottom: compact ? 18 : 26,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOWN HALL',
                        style: TextStyle(
                          color: t.primary,
                          fontSize: compact ? 10 : 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'CRITERIVOX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 28 : 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Different minds · One intelligence',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .88),
                          fontSize: compact ? 11 : 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '15 specialists · 15 perspectives · one mission',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .82),
                          fontSize: compact ? 10 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 14 : 18),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final name in _specialists)
                  _specialistChip(t, name),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specialistChip(CriterivoxTheme t, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.border),
      ),
      child: Text(
        name.toUpperCase(),
        style: TextStyle(
          color: t.text,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: .8,
        ),
      ),
    );
  }

  Widget _civilizationRegistry(CriterivoxTheme t, bool compact) {
    final profiles = CharacterIdentities.all.values.toList();

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CIVILIZATION REGISTRY',
            style: TextStyle(
              color: t.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Identity · role · residency · current state',
            style: TextStyle(
              color: t.mutedText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final profile in profiles)
                ActionChip(
                  avatar: CircleAvatar(
                    radius: 9,
                    child: Text(
                      profile.displayName.substring(0, 1),
                    ),
                  ),
                  label: Text(profile.displayName),
                  onPressed: onOpenCivilization,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _capabilities(CriterivoxTheme t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border),
      ),
      child: Text(
        'Characters visualize runtime state through the same semantic animation contract used by the interaction layer.',
        style: TextStyle(
          color: t.mutedText,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}
