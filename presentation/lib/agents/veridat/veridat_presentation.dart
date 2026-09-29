import 'package:flutter/material.dart';
class VeridatPresentation {
  static const characterId='veridat';
  static const role='Verification & Grounding';
  static const chatPrompts=<String>[
    'Verify this claim against recorded evidence.',
    'Show missing or inaccessible evidence.',
    'Show contradictions affecting this claim.',
    'Show the verification method and provenance.',
    'Show temporal and integrity limitations.',
    'Explain why this result is still pending validation.',
  ];
  static const capabilities=<VeridatCapability>[
    VeridatCapability('grounding','CLAIM GROUNDING','Trace a claim to the evidence artifacts supplied for verification.',Icons.fact_check_outlined),
    VeridatCapability('contradiction','CONTRADICTION INSPECTION','Surface explicit contradictory evidence.',Icons.compare_arrows_outlined),
    VeridatCapability('provenance','VERIFICATION PROVENANCE','Expose the verification and provenance chain.',Icons.account_tree_outlined),
    VeridatCapability('temporal','TEMPORAL VALIDITY','Expose temporal validity and time-related limitations.',Icons.schedule_outlined),
    VeridatCapability('integrity','INTEGRITY CHECK','Expose recorded integrity status and limitations.',Icons.verified_user_outlined),
  ];
}
class VeridatCapability { final String id,label,description; final IconData icon; const VeridatCapability(this.id,this.label,this.description,this.icon); }
