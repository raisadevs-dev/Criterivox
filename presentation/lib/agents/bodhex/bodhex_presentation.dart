import 'package:flutter/material.dart';
class BodhexPresentation {
  static const characterId='bodhex';
  static const role='Insight & Action Preparation';
  static const chatPrompts=<String>[
    'Compile the available insights.',
    'Prepare this strategy as an action contract.',
    'Show the execution preconditions.',
    'Show the blast radius and affected scope.',
    'Show the execution DAG and recovery points.',
    'Show what still requires authorization.',
  ];
  static const capabilities=<BodhexCapability>[
    BodhexCapability('insight','INSIGHT COMPILATION','Compile recorded analytical outputs without inventing conclusions.',Icons.auto_awesome_outlined),
    BodhexCapability('action','ACTION PREPARATION','Prepare an inspectable action contract before consequential execution.',Icons.assignment_turned_in_outlined),
    BodhexCapability('preconditions','PRECONDITIONS','Expose required conditions and authorization state.',Icons.rule_outlined),
    BodhexCapability('scope','IMPACT SCOPE','Expose action scope before execution.',Icons.radar_outlined),
    BodhexCapability('recovery','RECOVERY CONTROL','Keep execution and recovery boundaries inspectable.',Icons.replay_outlined),
  ];
}
class BodhexCapability { final String id,label,description; final IconData icon; const BodhexCapability(this.id,this.label,this.description,this.icon); }
