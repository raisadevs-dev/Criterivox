class CharacterIdentity {
  final String id;
  final String displayName;
  final String role;
  const CharacterIdentity(
      {required this.id, required this.displayName, required this.role});
}

class CharacterIdentities {
  CharacterIdentities._();

  static const Map<String, CharacterIdentity> all = {
    'dharen': CharacterIdentity(
        id: 'dharen', displayName: 'Dharen', role: 'Context Architecture'),
    'vivren': CharacterIdentity(
        id: 'vivren', displayName: 'Vivren', role: 'Discernment'),
    'tarkis': CharacterIdentity(
        id: 'tarkis', displayName: 'Tarkis', role: 'Hypothesis + Evidence'),
    'sandre': CharacterIdentity(
        id: 'sandre', displayName: 'Sandre', role: 'Data Stewardship'),
    'pramon':
        CharacterIdentity(id: 'pramon', displayName: 'Pramon', role: 'Proof'),
    'syvax': CharacterIdentity(
        id: 'syvax', displayName: 'Syvax', role: 'Dialogue + Orchestration'),
    'bodhex':
        CharacterIdentity(id: 'bodhex', displayName: 'Bodhex', role: 'Insight'),
    'medrus': CharacterIdentity(
        id: 'medrus', displayName: 'Medrus', role: 'Knowledge'),
    'epistre': CharacterIdentity(
        id: 'epistre', displayName: 'Epistre', role: 'Transfer'),
    'manis': CharacterIdentity(
        id: 'manis', displayName: 'Manis', role: 'Deliberation'),
    'anuka': CharacterIdentity(
        id: 'anuka', displayName: 'Anuka', role: 'Adaptive Context'),
    'veridat': CharacterIdentity(
        id: 'veridat', displayName: 'Veridat', role: 'Verification'),
    'viveda': CharacterIdentity(
        id: 'viveda', displayName: 'Viveda', role: 'Knowledge Delivery'),
    'kaelen': CharacterIdentity(
        id: 'kaelen', displayName: 'Kaelen', role: 'Build + Experimentation'),
    'anukor': CharacterIdentity(
        id: 'anukor', displayName: 'Anukor', role: 'Context Transfer'),
  };

  static CharacterIdentity resolve(String id) =>
      all[id.trim().toLowerCase()] ??
      CharacterIdentity(id: id, displayName: id, role: 'Criterivox Agent');
}
