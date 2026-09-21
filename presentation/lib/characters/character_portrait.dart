import 'package:flutter/material.dart';

import 'procedural_character_view.dart';
import 'visual_character_contract.dart';

class CharacterPortrait extends StatelessWidget {
  final VisualCharacterDefinition character;
  final double height;
  final BoxFit fit;

  const CharacterPortrait({
    super.key,
    required this.character,
    this.height = 280,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.asset(
          character.heroPortraitAsset,
          fit: fit,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF0B1020),
              alignment: Alignment.center,
              child: ProceduralCharacterView(
                character: character,
                scale: height / 260,
              ),
            );
          },
        ),
      ),
    );
  }
}
