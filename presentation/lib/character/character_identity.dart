class CharacterIdentity {
  final String id;
  final Map<String, String> localizedNames;
  final String displayName;
  final String role;
  final String? subtitle;
  final String? description;
  final List<String> skills;
  final String? appearance;

  const CharacterIdentity({
    required this.id,
    required this.displayName,
    this.localizedNames = const {},
    required this.role,
    this.subtitle,
    this.description,
    this.skills = const [],
    this.appearance,
  });

  String nameFor(String languageCode) => localizedNames[languageCode] ?? displayName;
}

class CharacterIdentities {
  CharacterIdentities._();

  static const Map<String, CharacterIdentity> all = {
    'dharen': CharacterIdentity(id: 'dharen', displayName: 'Dharen', localizedNames: const {'hi': 'Dharen'}, role: 'Context Architecture'),
    'vivren': CharacterIdentity(id: 'vivren', displayName: 'Vivren', localizedNames: const {'hi': 'Vivren'}, role: 'Discernment'),
    'tarkis': CharacterIdentity(id: 'tarkis', displayName: 'Tarkis', localizedNames: const {'hi': 'Tarkis'}, role: 'Hypothesis + Evidence'),
    'sandre': CharacterIdentity(id: 'sandre', displayName: 'Sandre', localizedNames: const {'hi': 'Sandre'}, role: 'Data Stewardship'),
    'pramon': CharacterIdentity(id: 'pramon', displayName: 'Pramon', localizedNames: const {'hi': 'Pramon'}, role: 'Proof'),
    'syvax': CharacterIdentity(id: 'syvax', displayName: 'Syvax', localizedNames: const {'hi': 'Syvax'}, role: 'Dialogue + Orchestration'),
    'bodhex': CharacterIdentity(id: 'bodhex', displayName: 'Bodhex', localizedNames: const {'hi': 'Bodhex'}, role: 'Insight'),
    'manis': CharacterIdentity(id: 'manis', displayName: 'Manis', localizedNames: const {'hi': 'Manis'}, role: 'Deliberation'),
    'anuka': CharacterIdentity(id: 'anuka', displayName: 'Anuka', localizedNames: const {'hi': 'Anuka'}, role: 'Adaptive Context'),
    'viveda': CharacterIdentity(id: 'viveda', displayName: 'Viveda', localizedNames: const {'hi': 'Viveda'}, role: 'Knowledge Delivery'),
    'kaelen': CharacterIdentity(id: 'kaelen', displayName: 'Kaelen', localizedNames: const {'hi': 'Kaelen'}, role: 'Build + Experimentation'),
    'anukor': CharacterIdentity(id: 'anukor', displayName: 'Anukor', localizedNames: const {'hi': 'Anukor'}, role: 'Context Transfer'),
    'medrus': CharacterIdentity(id: 'medrus', displayName: 'Medrus', localizedNames: const {'hi': 'Medrus'}, role: 'Evidence Specialist / Experimenter', subtitle: 'Evidence Specialist · Experimenter · Verifier', description: 'Turns questions into evidence, designs experiments, tests assumptions, and preserves what can be observed, measured, and confirmed.', skills: ['Research Design', 'Data Analysis', 'Experimentation', 'Verification'], appearance: 'Layered practical coat, fitted dark bodysuit, neck cloth, glasses, research pendant, wrist device and evidence slate.'),
    'epistre': CharacterIdentity(id: 'epistre', displayName: 'Epistre', localizedNames: const {'hi': 'Epistre'}, role: 'Knowledge Specialist / Research Companion', subtitle: 'Knowledge Specialist · Research Companion', description: 'Connects what has been learned across time and disciplines, preserving provenance and turning evidence into understandable knowledge.', skills: ['Historical Analysis', 'Pattern Recognition', 'Cross-Cultural Understanding', 'Knowledge Synthesis'], appearance: 'Elegant scholarly layered coat, dark inner suit, neck stole, glasses, star/compass pendant and knowledge tablet.'),
    'veridat': CharacterIdentity(id: 'veridat', displayName: 'Veridat', localizedNames: const {'hi': 'Veridat'}, role: 'Verification Specialist / Research Partner', subtitle: 'Verification Specialist · Research Partner', description: 'Examines what others accept, traces sources, checks support, and keeps truth boundaries explicit rather than assumed.', skills: ['Data Verification', 'Source Tracing', 'Pattern Validation', 'Risk Analysis'], appearance: 'Refined light verification coat over a dark fitted bodysuit, high neck cloth, glasses, verification insignia, wrist scanner and evidence slate.'),
  };

  static CharacterIdentity resolve(String id) => all[id.trim().toLowerCase()] ?? CharacterIdentity(id: id, displayName: id, role: 'Criterivox Agent');
}
