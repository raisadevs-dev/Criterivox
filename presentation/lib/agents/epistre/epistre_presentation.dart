import 'package:flutter/material.dart';
class EpistrePresentation {
  static const characterId='epistre';
  static const role='Explanation & Provenance Lineage';
  static const chatPrompts=<String>[
    'Explain this recorded artifact.',
    'Trace this artifact to its sources.',
    'Show parent and dependency lineage.',
    'Show the explanation status and limitations.',
    'Show whether provenance is available.',
    'Inspect the recorded explanation artifact.',
  ];
  static const capabilities=<EpistreCapability>[
    EpistreCapability('explain','ARTIFACT EXPLANATION','Create an inspectable explanation artifact for recorded state.',Icons.description_outlined),
    EpistreCapability('sources','SOURCE TRACE','Trace an artifact to its recorded sources.',Icons.call_split_outlined),
    EpistreCapability('parents','PARENT LINEAGE','Show parent and dependency relationships.',Icons.account_tree_outlined),
    EpistreCapability('limitations','EXPLANATION LIMITS','Expose recorded status and limitations.',Icons.warning_amber_outlined),
    EpistreCapability('provenance','PROVENANCE AVAILABILITY','Show whether recorded lineage is available.',Icons.route_outlined),
  ];
}
class EpistreCapability { final String id,label,description; final IconData icon; const EpistreCapability(this.id,this.label,this.description,this.icon); }
