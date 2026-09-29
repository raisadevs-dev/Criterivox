import 'package:flutter/material.dart';

class AnukaPresentation {
  static const characterId = 'anuka';
  static const role = 'Context Adaptation';

  static const chatPrompts = <String>[
    'Check whether the context needs adaptation.',
    'Inspect the latest context diff.',
    'Create a sandbox fork.',
    'Run a counterfactual context change.',
    'Create a context checkpoint.',
    'Prepare an adaptive handoff.',
    'Inspect the current adaptive state.',
  ];

  static const capabilities = <AnukaCapability>[
    AnukaCapability(
      id: 'activation',
      label: 'ADAPTATION GATE',
      description: 'Activate only when context, requirements, evidence or constraints change.',
      icon: Icons.bolt_outlined,
    ),
    AnukaCapability(
      id: 'drift',
      label: 'CONTEXT DRIFT',
      description: 'Detect added, removed and changed context plus goal and constraint shifts.',
      icon: Icons.compare_arrows_outlined,
    ),
    AnukaCapability(
      id: 'state',
      label: 'ADAPTIVE STATE',
      description: 'Maintain versioned active context after an adaptation.',
      icon: Icons.layers_outlined,
    ),
    AnukaCapability(
      id: 'sandbox',
      label: 'SANDBOX FORK',
      description: 'Create isolated context variants for counterfactual work.',
      icon: Icons.call_split_outlined,
    ),
    AnukaCapability(
      id: 'checkpoint',
      label: 'CHECKPOINT',
      description: 'Capture adaptive context state and scratchpad data.',
      icon: Icons.bookmark_border_outlined,
    ),
    AnukaCapability(
      id: 'handoff',
      label: 'ADAPTIVE HANDOFF',
      description: 'Expose the changed context and constraints to downstream workers.',
      icon: Icons.call_made_outlined,
    ),
  ];
}

class AnukaCapability {
  final String id;
  final String label;
  final String description;
  final IconData icon;

  const AnukaCapability({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });
}
