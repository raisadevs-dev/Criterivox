import 'package:flutter/material.dart';

enum CharacterOperationalState {
  idle,
  receive,
  work,
  communicate,
  handoff,
  complete,
  warning,
}

enum CharacterAttentionState {
  quiet,
  attentive,
  focused,
  busy,
  waiting,
  needsUser,
  completing,
  recovering,
}

enum CharacterVisualFamily {
  gateway,
  steward,
  builder,
  context,
  adaptive,
  critical,
  hypothesis,
  planning,
  action,
  evidence,
  explanation,
  verification,
  challenge,
  knowledge,
  transfer,
}

@immutable
class VisualCharacterDefinition {
  final String id;
  final String displayName;
  final CharacterVisualFamily family;
  final Color accent;
  final String accessory;
  final String heroPortraitAsset;

  const VisualCharacterDefinition({
    required this.id,
    required this.displayName,
    required this.family,
    required this.accent,
    required this.accessory,
    required this.heroPortraitAsset,
  });
}
