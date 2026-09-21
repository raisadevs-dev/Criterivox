import 'package:flutter/material.dart';

import 'character_portrait.dart';
import 'character_registry.dart';
import 'character_visual_registry.dart';

class CharacterFocusPanel extends StatelessWidget {
  final CharacterDefinition character;

  const CharacterFocusPanel({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final visual = CharacterVisualRegistry.byId(character.name.toLowerCase());

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CharacterPortrait(
            character: visual,
            height: 240,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  character.role,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
