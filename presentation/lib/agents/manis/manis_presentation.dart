import 'package:flutter/material.dart';
class ManisPresentation {
  static const characterId='manis';
  static const role='Human Challenge & Oversight';
  static const chatPrompts=<String>[
    'Challenge the assumptions behind this strategy.',
    'What evidence would make this conclusion unacceptable?',
    'Find contradictions or missing context.',
    'Stress-test the trade-offs.',
    'Record my objection as a governance event.',
    'Show what changes after my challenge.',
  ];
  static const capabilities=<ManisCapability>[
    ManisCapability('assumption','ASSUMPTION CHALLENGE','Challenge premises behind a proposed strategy.',Icons.help_outline),
    ManisCapability('evidence','EVIDENCE CHALLENGE','Question whether available evidence supports the claim.',Icons.fact_check_outlined),
    ManisCapability('logic','LOGIC CHALLENGE','Expose contradictions or unsupported reasoning.',Icons.account_tree_outlined),
    ManisCapability('tradeoff','TRADE-OFF CHALLENGE','Stress-test costs, benefits, risks and constraints.',Icons.compare_arrows_outlined),
    ManisCapability('record','CHALLENGE RECORD','Persist the human challenge as a governance event.',Icons.gavel_outlined),
  ];
}
class ManisCapability { final String id,label,description; final IconData icon; const ManisCapability(this.id,this.label,this.description,this.icon); }
