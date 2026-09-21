import 'package:flutter/material.dart';

import 'visual_character_contract.dart';

class CharacterVisualRegistry {
  static const all = <VisualCharacterDefinition>[
    VisualCharacterDefinition(
      id: 'syvax',
      displayName: 'Syvax',
      family: CharacterVisualFamily.gateway,
      accent: Color(0xFF55D9FF),
      accessory: 'interface_orb',
      heroPortraitAsset: 'assets/characters/portraits/syvax.webp',
    ),
    VisualCharacterDefinition(
      id: 'sandre',
      displayName: 'Sandre',
      family: CharacterVisualFamily.steward,
      accent: Color(0xFFE4B84A),
      accessory: 'data_archive',
      heroPortraitAsset: 'assets/characters/portraits/sandre.webp',
    ),
    VisualCharacterDefinition(
      id: 'kaelen',
      displayName: 'Kaelen',
      family: CharacterVisualFamily.builder,
      accent: Color(0xFFFFA62B),
      accessory: 'builder_tool',
      heroPortraitAsset: 'assets/characters/portraits/kaelen.webp',
    ),
    VisualCharacterDefinition(
      id: 'dharen',
      displayName: 'Dharen',
      family: CharacterVisualFamily.context,
      accent: Color(0xFFDDBA55),
      accessory: 'context_compass',
      heroPortraitAsset: 'assets/characters/portraits/dharen.webp',
    ),
    VisualCharacterDefinition(
      id: 'anuka',
      displayName: 'Anuka',
      family: CharacterVisualFamily.adaptive,
      accent: Color(0xFFE26BFF),
      accessory: 'adaptive_ribbon',
      heroPortraitAsset: 'assets/characters/portraits/anuka.webp',
    ),
    VisualCharacterDefinition(
      id: 'vivren',
      displayName: 'Vivren',
      family: CharacterVisualFamily.critical,
      accent: Color(0xFF9C7CFF),
      accessory: 'inspection_lens',
      heroPortraitAsset: 'assets/characters/portraits/vivren.webp',
    ),
    VisualCharacterDefinition(
      id: 'tarkis',
      displayName: 'Tarkis',
      family: CharacterVisualFamily.hypothesis,
      accent: Color(0xFFFF8A3D),
      accessory: 'orb',
      heroPortraitAsset: 'assets/characters/portraits/tarkis.webp',
    ),
    VisualCharacterDefinition(
      id: 'pramon',
      displayName: 'Pramon',
      family: CharacterVisualFamily.planning,
      accent: Color(0xFFF2C14E),
      accessory: 'planning_tablet',
      heroPortraitAsset: 'assets/characters/portraits/pramon.webp',
    ),
    VisualCharacterDefinition(
      id: 'bodhex',
      displayName: 'Bodhex',
      family: CharacterVisualFamily.action,
      accent: Color(0xFF65B9FF),
      accessory: 'action_module',
      heroPortraitAsset: 'assets/characters/portraits/bodhex.webp',
    ),
    VisualCharacterDefinition(
      id: 'medrus',
      displayName: 'Medrus',
      family: CharacterVisualFamily.evidence,
      accent: Color(0xFF59D8E8),
      accessory: 'evidence_tablet',
      heroPortraitAsset: 'assets/characters/portraits/medrus.webp',
    ),
    VisualCharacterDefinition(
      id: 'epistre',
      displayName: 'Epistre',
      family: CharacterVisualFamily.explanation,
      accent: Color(0xFFE5C15A),
      accessory: 'knowledge_book',
      heroPortraitAsset: 'assets/characters/portraits/epistre.webp',
    ),
    VisualCharacterDefinition(
      id: 'veridat',
      displayName: 'Veridat',
      family: CharacterVisualFamily.verification,
      accent: Color(0xFFF2F4FF),
      accessory: 'verification_lens',
      heroPortraitAsset: 'assets/characters/portraits/veridat.webp',
    ),
    VisualCharacterDefinition(
      id: 'manis',
      displayName: 'Manis',
      family: CharacterVisualFamily.challenge,
      accent: Color(0xFF7BE495),
      accessory: 'challenge_token',
      heroPortraitAsset: 'assets/characters/portraits/manis.webp',
    ),
    VisualCharacterDefinition(
      id: 'viveda',
      displayName: 'Viveda',
      family: CharacterVisualFamily.knowledge,
      accent: Color(0xFF5AB6FF),
      accessory: 'knowledge_cube',
      heroPortraitAsset: 'assets/characters/portraits/viveda.webp',
    ),
    VisualCharacterDefinition(
      id: 'anukor',
      displayName: 'Anukor',
      family: CharacterVisualFamily.transfer,
      accent: Color(0xFFC477FF),
      accessory: 'transfer_orb',
      heroPortraitAsset: 'assets/characters/portraits/anukor.webp',
    ),
  ];

  static VisualCharacterDefinition byId(String id) =>
      all.firstWhere((character) => character.id == id);
}
