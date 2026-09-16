import 'package:flutter/material.dart';

import 'character/character_runtime_flutter.dart';
import 'presentation/presentation_state.dart';
import 's8_presentation_state.dart';

/// S8 reuses the canonical Criterivox character renderer. S8 supplies semantic
/// state; the character remains a presentation identity, never a truth engine.
class S8CharacterPresentation extends StatelessWidget {
  final S8CharacterState character;
  final bool compact;

  const S8CharacterPresentation({super.key, required this.character, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final state = PresentationState(
      agentId: character.name.toLowerCase(),
      characterState: character.activity.name.toUpperCase(),
      active: character.activity != S8ActivityState.idle,
      reducedMotion: false,
      prominence: 1,
    );
    return Semantics(
      container: true,
      label: '${character.name}, ${character.role}',
      value: character.activityLabel,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 14),
          child: Column(children: [
            CharacterRuntimeView(
              characterId: state.agentId,
              state: state.characterState,
              reducedMotion: state.reducedMotion,
              width: compact ? 150 : 220,
              height: compact ? 190 : 245,
            ),
            Text(character.name, style: Theme.of(context).textTheme.titleLarge),
            Text(character.role),
            const SizedBox(height: 4),
            Text(character.visualMetaphor, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 7),
            Chip(label: Text(character.activityLabel)),
          ]),
        ),
      ),
    );
  }
}
