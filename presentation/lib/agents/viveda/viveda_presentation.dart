import 'package:flutter/material.dart';
class VivedaPresentation {
  static const characterId='viveda';
  static const role='Knowledge Consolidation & Reuse';
  static const chatPrompts=<String>[
    'Show the consolidated knowledge for this journey.',
    'Which evidence supports this knowledge?',
    'Which verification references support it?',
    'Show the applicability and context limits.',
    'What knowledge is still awaiting validation?',
    'Trace this rule back to its source artifacts.',
  ];
  static const capabilities=<VivedaCapability>[
    VivedaCapability('synthesis','KNOWLEDGE SYNTHESIS','Consolidate supported artifacts into reusable knowledge candidates.',Icons.hub_outlined),
    VivedaCapability('evidence','KNOWLEDGE EVIDENCE','Expose evidence supporting a knowledge record.',Icons.fact_check_outlined),
    VivedaCapability('verification','VERIFICATION GATE','Require verification references before trusted maturity.',Icons.verified_outlined),
    VivedaCapability('applicability','APPLICABILITY BOUNDARY','Keep context and reuse conditions explicit.',Icons.rule_outlined),
    VivedaCapability('lineage','KNOWLEDGE LINEAGE','Trace reusable knowledge to source artifacts and references.',Icons.account_tree_outlined),
  ];
}
class VivedaCapability { final String id,label,description; final IconData icon; const VivedaCapability(this.id,this.label,this.description,this.icon); }
