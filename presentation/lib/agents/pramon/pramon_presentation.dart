import 'package:flutter/material.dart';
class PramonPresentation {
  static const characterId='pramon';
  static const role='Planning & Decision Structure';
  static const chatPrompts=<String>['Show the available strategy options.','Compare the trade-offs.','What assumptions support each option?','Build a contingency path.','Show the decision rationale.','Prepare this for human review.'];
  static const capabilities=<PramonCapability>[
    PramonCapability('options','DECISION OPTIONS','Structure supported alternatives without selecting for the human.',Icons.alt_route_outlined),
    PramonCapability('tradeoffs','TRADE-OFF ANALYSIS','Expose explicit trade-offs across candidate strategies.',Icons.compare_arrows_outlined),
    PramonCapability('contingency','CONTINGENCY PLANNING','Keep recovery and alternative paths visible.',Icons.alt_route_rounded),
    PramonCapability('rationale','DECISION RATIONALE','Preserve why an option is supported and what assumptions remain.',Icons.description_outlined),
    PramonCapability('review','HUMAN REVIEW GATE','Present candidates for human acceptance, rejection or challenge.',Icons.how_to_vote_outlined),
  ];
}
class PramonCapability { final String id,label,description; final IconData icon; const PramonCapability(this.id,this.label,this.description,this.icon); }
