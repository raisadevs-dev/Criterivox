import 'package:flutter/material.dart';

import 's8_presentation_state.dart';

class S8CharacterPresentation extends StatelessWidget {
  final S8CharacterState character;
  final bool compact;

  const S8CharacterPresentation({
    super.key,
    required this.character,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: compact ? 24 : 34,
      backgroundColor: character.accent.withValues(alpha: .14),
      child: Text(
        character.name.characters.first,
        style: TextStyle(color: character.accent, fontWeight: FontWeight.bold, fontSize: compact ? 18 : 26),
      ),
    );
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(character.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(character.role),
                  const SizedBox(height: 5),
                  Text(character.visualMetaphor, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Chip(label: Text(character.activityLabel)),
          ],
        ),
      ),
    );
  }
}
