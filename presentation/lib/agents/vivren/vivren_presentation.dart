import 'package:flutter/material.dart';
class VivrenPresentation {
  static const characterId='vivren'; static const role='Critical Reasoning';
  static const chatPrompts=<String>['Inspect the reasoning.','Find the weak point.','What assumption is hidden?','Inspect the evidence.','Explain the contradiction.','Review the logic.','Show the limitations.','Trace the provenance.'];
  static const capabilities=<VivrenCapability>[
    VivrenCapability('inspection','CRITICAL INSPECTION','Inspect reasoning integrity and recorded analytical findings.',Icons.search_outlined),
    VivrenCapability('assumptions','ASSUMPTION REVIEW','Expose assumptions explicitly recorded by reasoning artifacts.',Icons.rule_outlined),
    VivrenCapability('evidence','EVIDENCE REVIEW','Trace available evidence without treating acquisition as verification.',Icons.fact_check_outlined),
    VivrenCapability('contradictions','CONTRADICTION REVIEW','Keep recorded contradictions visible and unresolved when they remain unresolved.',Icons.compare_arrows_outlined),
    VivrenCapability('limitations','LIMITATIONS','Expose uncertainty, missing context and analytical boundaries.',Icons.warning_amber_outlined),
    VivrenCapability('provenance','PROVENANCE TRACE','Trace findings to authoritative artifacts and parents.',Icons.account_tree_outlined),
  ];
}
class VivrenCapability { final String id,label,description; final IconData icon; const VivrenCapability(this.id,this.label,this.description,this.icon); }
