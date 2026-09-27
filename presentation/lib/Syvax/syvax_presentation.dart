import 'package:flutter/material.dart';

class SyvaxPresentation {
  static const characterId = 'syvax';
  static const role = 'Interaction & Gateway';

  static const chatPrompts = <String>[
    'Route my request.',
    'Show the current task plan.',
    'Check the gateway safety result.',
    'Show where this task will go.',
    'Render the current result.',
    'Inspect the handoff trace.',
  ];

  static const capabilities = <SyvaxCapability>[
    SyvaxCapability('preflight', 'GATEWAY PREFLIGHT', 'Check a request before routing.', Icons.security_outlined),
    SyvaxCapability('intent', 'INTENT EXTRACTION', 'Identify the task intent and confidence.', Icons.track_changes_outlined),
    SyvaxCapability('routing', 'TASK ROUTING', 'Construct the worker route for the request.', Icons.alt_route_outlined),
    SyvaxCapability('oversight', 'OVERSIGHT', 'Keep human oversight mode explicit.', Icons.visibility_outlined),
    SyvaxCapability('rendering', 'OUTPUT TRANSLATION', 'Return an inspectable human-facing result.', Icons.output_outlined),
    SyvaxCapability('trace', 'ROUTING TRACE', 'Expose route and execution trace state.', Icons.account_tree_outlined),
  ];
}

class SyvaxCapability {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  const SyvaxCapability(this.id, this.label, this.description, this.icon);
}
