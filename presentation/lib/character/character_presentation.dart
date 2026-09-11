import 'package:flutter/material.dart';

import '../presentation/criterivox_theme.dart';
import '../presentation/presentation_state.dart';
import 'character_identity.dart';
import 'character_runtime.dart';

class CharacterPresentation extends StatelessWidget {
  final PresentationState state;

  const CharacterPresentation({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);
    final identity = CharacterIdentities.resolve(state.agentId);

    return Semantics(
      container: true,
      label: '${identity.displayName}, ${identity.role}',
      value: state.characterState,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CharacterRuntimeView(
            characterId: state.agentId,
            state: state.characterState,
            reducedMotion: state.reducedMotion,
            width: 238,
            height: 286,
          ),
          const SizedBox(height: 4),
          Text(
            'Final character artwork coming soon',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: .25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          Text(
            identity.displayName,
            style: TextStyle(
              color: theme.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            identity.role,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 10,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 9),
          _StateBadge(state: state.characterState),
        ],
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  final String state;

  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);
    final accent = switch (state) {
      'WARNING' => theme.warning,
      'COMPLETE' => theme.success,
      _ => theme.primary,
    };

    return Semantics(
      label: 'Character state',
      value: state,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: .35)),
        ),
        child: Text(
          state,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: accent,
          ),
        ),
      ),
    );
  }
}
