import 'package:flutter/material.dart';
class AnukorPresentation {
  static const characterId='anukor';
  static const role='Adaptive Cross-Home Transfer';
  static const chatPrompts=<String>[
    'Show the recorded cross-home transfers.',
    'Assess whether this artifact can move to another home.',
    'Show compatibility with the target context.',
    'Show whether adaptation is required.',
    'Show rejected or incomplete transfers.',
    'Trace the transfer provenance.',
  ];
  static const capabilities=<AnukorCapability>[
    AnukorCapability('assess','TRANSFER ASSESSMENT','Assess compatibility before a cross-home transfer.',Icons.compare_arrows_outlined),
    AnukorCapability('adaptation','ADAPTATION REQUIREMENT','Expose when target-context adaptation is required.',Icons.sync_alt_outlined),
    AnukorCapability('record','TRANSFER RECORD','Persist the transfer state and provenance.',Icons.receipt_long_outlined),
    AnukorCapability('rejection','TRANSFER REJECTION','Keep incompatible or incomplete transfers explicitly rejected.',Icons.block_outlined),
    AnukorCapability('trace','TRANSFER TRACE','Expose source, target and adaptation references.',Icons.account_tree_outlined),
  ];
}
class AnukorCapability { final String id,label,description; final IconData icon; const AnukorCapability(this.id,this.label,this.description,this.icon); }
