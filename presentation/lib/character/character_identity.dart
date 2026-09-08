class CharacterIdentity {
  final String id;
  final String displayName;
  final String role;
  const CharacterIdentity({required this.id, required this.displayName, required this.role});
}

class CharacterIdentities {
  CharacterIdentities._();
  static const Map<String, CharacterIdentity> all = {
    'dharen': CharacterIdentity(id: 'dharen', displayName: 'Dharen', role: 'Analysis'),
    'vivren': CharacterIdentity(id: 'vivren', displayName: 'Vivren', role: 'Context'),
    'tarkis': CharacterIdentity(id: 'tarkis', displayName: 'Tarkis', role: 'Reasoning'),
    'sandre': CharacterIdentity(id: 'sandre', displayName: 'Sandre', role: 'Comparison'),
    'pramon': CharacterIdentity(id: 'pramon', displayName: 'Pramon', role: 'Planning'),
    'syvax': CharacterIdentity(id: 'syvax', displayName: 'Syvax', role: 'Pattern Analysis'),
    'bodhex': CharacterIdentity(id: 'bodhex', displayName: 'Bodhex', role: 'Evidence'),
    'medrus': CharacterIdentity(id: 'medrus', displayName: 'Medrus', role: 'Measurement'),
    'epistre': CharacterIdentity(id: 'epistre', displayName: 'Epistre', role: 'Explanation'),
    'manis': CharacterIdentity(id: 'manis', displayName: 'Manis', role: 'Human Interaction'),
    'anuka': CharacterIdentity(id: 'anuka', displayName: 'Anuka', role: 'Exploration'),
    'veridat': CharacterIdentity(id: 'veridat', displayName: 'Veridat', role: 'Verification'),
    'viveda': CharacterIdentity(id: 'viveda', displayName: 'Viveda', role: 'Knowledge'),
    'kaelen': CharacterIdentity(id: 'kaelen', displayName: 'Kaelen', role: 'Experimentation'),
    'anukor': CharacterIdentity(id: 'anukor', displayName: 'Anukor', role: 'Transfer'),
  };
  static CharacterIdentity resolve(String id) => all[id.trim().toLowerCase()] ?? CharacterIdentity(id: id, displayName: id, role: 'Criterivox Agent');
}
