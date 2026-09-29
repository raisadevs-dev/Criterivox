import 'package:flutter/material.dart';
class MedrusPresentation {
  static const characterId='medrus';
  static const role='Evidence Acquisition & Experiment';
  static const chatPrompts=<String>[
    'Show the evidence collected for this question.',
    'Inspect the source and observation behind this evidence.',
    'Show what remains unverified.',
    'Record an experiment and its observations.',
    'Retrieve historical evidence with temporal context.',
    'Show evidence limitations and uncertainty.',
  ];
  static const capabilities=<MedrusCapability>[
    MedrusCapability('acquisition','EVIDENCE ACQUISITION','Record observations with source, scope and provenance.',Icons.inventory_2_outlined),
    MedrusCapability('experiment','EXPERIMENT RECORDING','Record a procedure, observations and outcome without calling it verification.',Icons.science_outlined),
    MedrusCapability('retrieval','TEMPORAL RETRIEVAL','Retrieve retained evidence using temporal boundaries.',Icons.history_outlined),
    MedrusCapability('uncertainty','EVIDENCE UNCERTAINTY','Keep uncertainty and limitations attached to evidence.',Icons.warning_amber_outlined),
    MedrusCapability('provenance','SOURCE PROVENANCE','Preserve source references and acquisition metadata.',Icons.source_outlined),
  ];
}
class MedrusCapability { final String id,label,description; final IconData icon; const MedrusCapability(this.id,this.label,this.description,this.icon); }
