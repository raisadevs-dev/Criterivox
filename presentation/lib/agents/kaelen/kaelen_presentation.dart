import 'package:flutter/material.dart';

/// Kaelen-owned presentation contract.
///
/// Global identity, visual appearance, residence and navigation registries remain
/// centralized. This file owns only Kaelen-specific capability presentation.
class KaelenPresentation {
  static const characterId = 'kaelen';
  static const role = 'Build + Experimentation';

  static const chatPrompts = <String>[
    'Prepare a controlled experiment.',
    'Inspect scratchpad work.',
    'Record the current build state.',
    'Inspect schema drift.',
    'Build the pipeline.',
    'Prepare a normalized handoff.',
    'Inspect vector encoding.',
    'Inspect streaming state.',
  ];

  static const capabilities = <KaelenCapability>[
    KaelenCapability(
      id: 'pipeline',
      label: 'KAELEN PIPELINE',
      description: 'Construct, normalize, repair and inspect transformation pipelines.',
      icon: Icons.account_tree_outlined,
    ),
    KaelenCapability(
      id: 'schema_drift',
      label: 'SCHEMA DRIFT',
      description: 'Detect schema changes and prepare reversible repair mappings.',
      icon: Icons.schema_outlined,
    ),
    KaelenCapability(
      id: 'streaming',
      label: 'STREAM INGESTION',
      description: 'Process ordered events with checkpoints and replay protection.',
      icon: Icons.stream_outlined,
    ),
    KaelenCapability(
      id: 'vector',
      label: 'VECTOR ENCODING',
      description: 'Create deterministic local vector representations for structured rows.',
      icon: Icons.hub_outlined,
    ),
    KaelenCapability(
      id: 'vector_package',
      label: 'VECTOR PACKAGE',
      description: 'Create an inspectable vectorized package artifact.',
      icon: Icons.inventory_2_outlined,
    ),
    KaelenCapability(
      id: 'experimentation',
      label: 'EXPERIMENTATION',
      description: 'Maintain short-lived build state and controlled experimentation context.',
      icon: Icons.science_outlined,
    ),
  ];
}

class KaelenCapability {
  final String id;
  final String label;
  final String description;
  final IconData icon;

  const KaelenCapability({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });
}
