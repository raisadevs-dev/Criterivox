class CharacterIdentity {
  final String id;
  final String displayName;
  final String role;
  final String? subtitle;
  final String? description;
  final List<String> skills;
  final String? appearance;

  const CharacterIdentity({
    required this.id,
    required this.displayName,
    required this.role,
    this.subtitle,
    this.description,
    this.skills = const [],
    this.appearance,
  });
}

class CharacterIdentities {
  CharacterIdentities._();

  static const Map<String, CharacterIdentity> all = {
    'dharen': CharacterIdentity(id: 'dharen', displayName: 'Dharen', role: 'Context Architecture'),
    'vivren': CharacterIdentity(id: 'vivren', displayName: 'Vivren', role: 'Discernment'),
    'tarkis': CharacterIdentity(id: 'tarkis', displayName: 'Tarkis', role: 'Hypothesis + Evidence'),
    'sandre': CharacterIdentity(id: 'sandre', displayName: 'Sandre', role: 'Data Stewardship'),
    'pramon': CharacterIdentity(id: 'pramon', displayName: 'Pramon', role: 'Proof'),
    'syvax': CharacterIdentity(id: 'syvax', displayName: 'Syvax', role: 'Dialogue + Orchestration'),
    'bodhex': CharacterIdentity(id: 'bodhex', displayName: 'Bodhex', role: 'Insight'),
    'manis': CharacterIdentity(id: 'manis', displayName: 'Manis', role: 'Deliberation'),
    'anuka': CharacterIdentity(id: 'anuka', displayName: 'Anuka', role: 'Adaptive Context'),
    'viveda': CharacterIdentity(id: 'viveda', displayName: 'Viveda', role: 'Knowledge Delivery'),
    'kaelen': CharacterIdentity(id: 'kaelen', displayName: 'Kaelen', role: 'Build + Experimentation'),
    'anukor': CharacterIdentity(id: 'anukor', displayName: 'Anukor', role: 'Context Transfer'),
    'medrus': CharacterIdentity(id: 'medrus', displayName: 'Medrus', role: 'Evidence Specialist / Experimenter', subtitle: 'Evidence Specialist · Experimenter · Verifier', description: 'Turns questions into evidence, designs experiments, tests assumptions, and preserves what can be observed, measured, and confirmed.', skills: ['Research Design', 'Data Analysis', 'Experimentation', 'Verification'], appearance: 'Layered practical coat, fitted dark bodysuit, neck cloth, glasses, research pendant, wrist device and evidence slate.'),
    'epistre': CharacterIdentity(id: 'epistre', displayName: 'Epistre', role: 'Knowledge Specialist / Research Companion', subtitle: 'Knowledge Specialist · Research Companion', description: 'Connects what has been learned across time and disciplines, preserving provenance and turning evidence into understandable knowledge.', skills: ['Historical Analysis', 'Pattern Recognition', 'Cross-Cultural Understanding', 'Knowledge Synthesis'], appearance: 'Elegant scholarly layered coat, dark inner suit, neck stole, glasses, star/compass pendant and knowledge tablet.'),
    'veridat': CharacterIdentity(id: 'veridat', displayName: 'Veridat', role: 'Verification Specialist / Research Partner', subtitle: 'Verification Specialist · Research Partner', description: 'Examines what others accept, traces sources, checks support, and keeps truth boundaries explicit rather than assumed.', skills: ['Data Verification', 'Source Tracing', 'Pattern Validation', 'Risk Analysis'], appearance: 'Refined light verification coat over a dark fitted bodysuit, high neck cloth, glasses, verification insignia, wrist scanner and evidence slate.'),
  };

  static CharacterIdentity resolve(String id) => all[id.trim().toLowerCase()] ?? CharacterIdentity(id: id, displayName: id, role: 'Criterivox Agent');
}
