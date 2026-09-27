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
    'dharen': CharacterIdentity(id: 'dharen', displayName: 'Dharen', localizedNames: {'hi': 'धारेन', 'mr': 'धारेन', 'ne': 'धारेन'}, role: 'Context Architecture'),
    'vivren': CharacterIdentity(id: 'vivren', displayName: 'Vivren', localizedNames: {'hi': 'विव्रेन', 'mr': 'विव्रेन', 'ne': 'विव्रेन'}, role: 'Discernment'),
    'tarkis': CharacterIdentity(id: 'tarkis', displayName: 'Tarkis', localizedNames: {'hi': 'टार्किस', 'mr': 'टार्किस', 'ne': 'टार्किस'}, role: 'Hypothesis + Evidence'),
    'sandre': CharacterIdentity(id: 'sandre', displayName: 'Sandre', localizedNames: {'hi': 'सैंड्रे', 'mr': 'सैंड्रे', 'ne': 'सैंड्रे'}, role: 'Data Stewardship'),
    'pramon': CharacterIdentity(id: 'pramon', displayName: 'Pramon', localizedNames: {'hi': 'प्रामोन', 'mr': 'प्रामोन', 'ne': 'प्रामोन'}, role: 'Proof'),
    'syvax': CharacterIdentity(id: 'syvax', displayName: 'Syvax', localizedNames: {'hi': 'साइवेक्स', 'mr': 'साइवेक्स', 'ne': 'साइवेक्स'}, role: 'Dialogue + Orchestration'),
    'bodhex': CharacterIdentity(id: 'bodhex', displayName: 'Bodhex', localizedNames: {'hi': 'बोधेक्स', 'mr': 'बोधेक्स', 'ne': 'बोधेक्स'}, role: 'Insight'),
    'manis': CharacterIdentity(id: 'manis', displayName: 'Manis', localizedNames: {'hi': 'मानिस', 'mr': 'मानिस', 'ne': 'मानिस'}, role: 'Deliberation'),
    'anuka': CharacterIdentity(id: 'anuka', displayName: 'Anuka', localizedNames: {'hi': 'अनुका', 'mr': 'अनुका', 'ne': 'अनुका'}, role: 'Adaptive Context'),
    'viveda': CharacterIdentity(id: 'viveda', displayName: 'Viveda', localizedNames: {'hi': 'विवेदा', 'mr': 'विवेदा', 'ne': 'विवेदा'}, role: 'Knowledge Delivery'),
    'kaelen': CharacterIdentity(id: 'kaelen', displayName: 'Kaelen', localizedNames: {'hi': 'कैलेन', 'mr': 'कैलेन', 'ne': 'कैलेन'}, role: 'Build + Experimentation'),
    'anukor': CharacterIdentity(id: 'anukor', displayName: 'Anukor', localizedNames: {'hi': 'अनुकोर', 'mr': 'अनुकोर', 'ne': 'अनुकोर'}, role: 'Context Transfer'),
    'medrus': CharacterIdentity(id: 'medrus', displayName: 'Medrus', localizedNames: {'hi': 'मेड्रस', 'mr': 'मेड्रस', 'ne': 'मेड्रस'}, role: 'Evidence Specialist / Experimenter', subtitle: 'Evidence Specialist · Experimenter · Verifier', description: 'Turns questions into evidence, designs experiments, tests assumptions, and preserves what can be observed, measured, and confirmed.', skills: ['Research Design', 'Data Analysis', 'Experimentation', 'Verification'], appearance: 'Layered practical coat, fitted dark bodysuit, neck cloth, glasses, research pendant, wrist device and evidence slate.'),
    'epistre': CharacterIdentity(id: 'epistre', displayName: 'Epistre', localizedNames: {'hi': 'एपिस्त्रे', 'mr': 'एपिस्त्रे', 'ne': 'एपिस्त्रे'}, role: 'Knowledge Specialist / Research Companion', subtitle: 'Knowledge Specialist · Research Companion', description: 'Connects what has been learned across time and disciplines, preserving provenance and turning evidence into understandable knowledge.', skills: ['Historical Analysis', 'Pattern Recognition', 'Cross-Cultural Understanding', 'Knowledge Synthesis'], appearance: 'Elegant scholarly layered coat, dark inner suit, neck stole, glasses, star/compass pendant and knowledge tablet.'),
    'veridat': CharacterIdentity(id: 'veridat', displayName: 'Veridat', localizedNames: {'hi': 'वेरिडैट', 'mr': 'वेरिडैट', 'ne': 'वेरिडैट'}, role: 'Verification Specialist / Research Partner', subtitle: 'Verification Specialist · Research Partner', description: 'Examines what others accept, traces sources, checks support, and keeps truth boundaries explicit rather than assumed.', skills: ['Data Verification', 'Source Tracing', 'Pattern Validation', 'Risk Analysis'], appearance: 'Refined light verification coat over a dark fitted bodysuit, high neck cloth, glasses, verification insignia, wrist scanner and evidence slate.'),
  };

  static CharacterIdentity resolve(String id) => all[id.trim().toLowerCase()] ?? CharacterIdentity(id: id, displayName: id, role: 'Criterivox Agent');
}
