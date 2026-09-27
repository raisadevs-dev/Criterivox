import 'package:flutter/material.dart';

class DharenPresentation {
  static const characterId = 'dharen';
  static const role = 'Context Architecture';

  static const chatPrompts = <String>[
    'Build the current context frame.',
    'Inspect context scope.',
    'Inspect context priority.',
    'Inspect boundary violations.',
    'Create a context checkpoint.',
    'Inspect the current handoff.',
  ];

  static const capabilities = <DharenCapability>[
    DharenCapability(
      id: 'framing',
      label: 'CONTEXT FRAMING',
      description: 'Construct a bounded context frame from authoritative inputs.',
      icon: Icons.account_tree_outlined,
    ),
    DharenCapability(
      id: 'scope',
      label: 'SCOPE BOUNDARY',
      description: 'Separate critical, high, medium and low context.',
      icon: Icons.filter_center_focus_outlined,
    ),
    DharenCapability(
      id: 'firewall',
      label: 'CONTEXT FIREWALL',
      description: 'Detect context clashes and poisoning before downstream use.',
      icon: Icons.security_outlined,
    ),
    DharenCapability(
      id: 'budget',
      label: 'CONTEXT BUDGET',
      description: 'Allocate bounded context through the deterministic priority allocator.',
      icon: Icons.data_usage_outlined,
    ),
    DharenCapability(
      id: 'handoff',
      label: 'CONTEXT HANDOFF',
      description: 'Expose the authoritative frame and state for downstream workers.',
      icon: Icons.call_made_outlined,
    ),
    DharenCapability(
      id: 'checkpoint',
      label: 'CHECKPOINTING',
      description: 'Expose context state and checkpoint records.',
      icon: Icons.bookmark_border_outlined,
    ),
  ];
}

class DharenCapability {
  final String id;
  final String label;
  final String description;
  final IconData icon;

  const DharenCapability({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });
}
