import 'package:flutter/material.dart';

import 'character/character_identity.dart';
import 'character/session_character_animation.dart';
import 'presentation/criterivox_theme.dart';
import 'presentation/language_mode.dart';

class AppIntroductionPage extends StatelessWidget {
  final VoidCallback onOpenWorkspace;
  final VoidCallback onOpenCivilization;

  const AppIntroductionPage({
    super.key,
    required this.onOpenWorkspace,
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
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 20,
        compact ? 14 : 20,
        compact ? 12 : 20,
        compact ? 16 : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: t.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.surfaceStrong, t.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
              color: t.text,
              fontSize: compact ? 28 : 42,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Different minds · One intelligence',
            style: TextStyle(
              color: t.mutedText,
              fontSize: compact ? 11 : 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          _specialistGallery(t, compact),
          const SizedBox(height: 14),
          Text(
            '15 specialists · 15 perspectives · one mission',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.mutedText,
              fontSize: compact ? 10 : 12,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specialistGallery(CriterivoxTheme t, bool compact) {
    final tileWidth = compact ? 82.0 : 118.0;
    final tileHeight = compact ? 132.0 : 172.0;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: compact ? 5 : 8,
        runSpacing: compact ? 7 : 9,
        children: [
          for (final name in _specialists)
            _specialistPortrait(
              t,
              name,
              width: tileWidth,
              height: tileHeight,
            ),
        ],
      ),
    );
  }

  Widget _specialistPortrait(
    CriterivoxTheme t,
    String name, {
    required double width,
    required double height,
  }) {
    final id = name.toLowerCase();
    final displayName = CharacterIdentities.resolve(id).nameFor(
      CriterivoxLanguageScope.maybeOf(context)?.language.code ?? 'en',
    );

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.fromLTRB(5, 6, 5, 7),
      decoration: BoxDecoration(
        color: t.page.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: t.primary.withValues(alpha: .20),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SessionCharacterAnimationView(
              characterId: id,
              state: 'IDLE',
              width: width - 10,
              height: height - 42,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayName.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: t.text,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
        ],
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
                      profile.nameFor(
                        CriterivoxLanguageScope.maybeOf(context)?.language.code ?? 'en',
                      ).substring(0, 1),
                    ),
                  ),
                  label: Text(
                    profile.nameFor(
                      CriterivoxLanguageScope.maybeOf(context)?.language.code ?? 'en',
                    ),
                  ),
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
