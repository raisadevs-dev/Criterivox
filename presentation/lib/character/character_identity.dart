class CharacterIdentity {
  final String id;
  final String displayName;
  final String role;

  const CharacterIdentity({
    required this.id,
    required this.displayName,
    required this.role,
  });
}

class CharacterIdentities {
  CharacterIdentities._();

  static const Map<String, CharacterIdentity> all = {
    'Dharen': CharacterIdentity(
      id: 'Dharen',
      displayName: 'Dharen',
      role: 'Analysis',
    ),
    'Vivren': CharacterIdentity(
      id: 'Vivren',
      displayName: 'Vivren',
      role: 'Context',
    ),
    'Tarkis': CharacterIdentity(
      id: 'Tarkis',
      displayName: 'Tarkis',
      role: 'Reasoning',
    ),
    'Sandre': CharacterIdentity(
      id: 'Sandre',
      displayName: 'Sandre',
      role: 'Comparison',
    ),
    'Pramon': CharacterIdentity(
      id: 'Pramon',
      displayName: 'Pramon',
      role: 'Planning',
    ),
    'Syvax': CharacterIdentity(
      id: 'Syvax',
      displayName: 'Syvax',
      role: 'Pattern Analysis',
    ),
    'Bodhex': CharacterIdentity(
      id: 'Bodhex',
      displayName: 'Bodhex',
      role: 'Evidence',
    ),
    'Medrus': CharacterIdentity(
      id: 'Medrus',
      displayName: 'Medrus',
      role: 'Measurement',
    ),
    'Epistre': CharacterIdentity(
      id: 'Epistre',
      displayName: 'Epistre',
      role: 'Explanation',
    ),
    'Manis': CharacterIdentity(
      id: 'Manis',
      displayName: 'Manis',
      role: 'Human Interaction',
    ),
    'Anuka': CharacterIdentity(
      id: 'Anuka',
      displayName: 'Anuka',
      role: 'Exploration',
    ),
    'Veridat': CharacterIdentity(
      id: 'Veridat',
      displayName: 'Veridat',
      role: 'Verification',
    ),
    'Viveda': CharacterIdentity(
      id: 'Viveda',
      displayName: 'Viveda',
      role: 'Knowledge',
    ),
    'Kaelen': CharacterIdentity(
      id: 'Kaelen',
      displayName: 'Kaelen',
      role: 'Experimentation',
    ),
    'Anukor': CharacterIdentity(
      id: 'Anukor',
      displayName: 'Anukor',
      role: 'Transfer',
    ),
  };

  static CharacterIdentity resolve(String id) {
    return all[id] ??
        CharacterIdentity(
          id: id,
          displayName: id,
          role: 'Criterivox Agent',
        );
  }
}