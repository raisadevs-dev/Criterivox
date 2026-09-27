import 'package:flutter/material.dart';

import 's8_authority.dart';
import 's8_presentation_state.dart';

/// The four specialist rooms expose capabilities through this presentation
/// contract. Home remains the navigation hub, not a fifth specialist room.
enum S8RoomCapability {
  evidence,
  memory,
  provenance,
  explanation,
  verification,
  uncertainty,
  collaboration,
  inspection,
  challenge,
}

class S8RoomDescriptor {
  final S8Room room;
  final String name;
  final String role;
  final String focus;
  final Color accent;
  final IconData icon;
  final List<S8RoomCapability> capabilities;

  const S8RoomDescriptor({
    required this.room,
    required this.name,
    required this.role,
    required this.focus,
    required this.accent,
    required this.icon,
    required this.capabilities,
  });
}

const s8SpecialistRooms = <S8RoomDescriptor>[
  S8RoomDescriptor(
    room: S8Room.medrus,
    name: 'Medrus',
    role: 'Evidence & Memory',
    focus: 'Sources, evidence intake, retention and temporal context.',
    accent: Color(0xFF2CCCF5),
    icon: Icons.inventory_2_outlined,
    capabilities: [S8RoomCapability.evidence, S8RoomCapability.memory],
  ),
  S8RoomDescriptor(
    room: S8Room.epistre,
    name: 'Epistre',
    role: 'Provenance & Explanation',
    focus: 'Lineage, attribution and human-readable explanation.',
    accent: Color(0xFFB98BFF),
    icon: Icons.account_tree_outlined,
    capabilities: [S8RoomCapability.provenance, S8RoomCapability.explanation],
  ),
  S8RoomDescriptor(
    room: S8Room.veridat,
    name: 'Veridat',
    role: 'Verification & Truth Boundary',
    focus: 'Verification state, conflict, integrity and uncertainty.',
    accent: Color(0xFF38E0A8),
    icon: Icons.verified_outlined,
    capabilities: [S8RoomCapability.verification, S8RoomCapability.uncertainty],
  ),
  S8RoomDescriptor(
    room: S8Room.presentation,
    name: 'Presentation',
    role: 'Flow & Collaboration',
    focus: 'Human-facing inspection, trace, challenge and review.',
    accent: Color(0xFFFFC857),
    icon: Icons.dashboard_customize_outlined,
    capabilities: [S8RoomCapability.collaboration, S8RoomCapability.inspection, S8RoomCapability.challenge],
  ),
];

S8RoomDescriptor? s8DescriptorFor(S8Room room) {
  for (final descriptor in s8SpecialistRooms) {
    if (descriptor.room == room) return descriptor;
  }
  return null;
}

/// A state-derived room view. It intentionally receives authoritative state,
/// preventing a room card from becoming an independent source of truth.
class S8RoomStateView extends StatelessWidget {
  final S8AuthoritativeState state;
  final S8Room room;

  const S8RoomStateView({super.key, required this.state, required this.room});

  @override
  Widget build(BuildContext context) {
    final descriptor = s8DescriptorFor(room);
    if (descriptor == null) {
      return const Center(child: Text('S8 Home is the hub; specialist state is shown in its four rooms.'));
    }
    final relevant = state.artifacts.where((artifact) {
      return switch (room) {
        S8Room.medrus => artifact.kind == 'evidence',
        S8Room.epistre => artifact.kind == 'explanation',
        S8Room.veridat => artifact.kind == 'verification' || artifact.kind == 'contradiction',
        S8Room.presentation => true,
        S8Room.home => false,
      };
    }).toList(growable: false);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(descriptor.icon, color: descriptor.accent), const SizedBox(width: 10), Text(descriptor.name, style: TextStyle(color: descriptor.accent, fontSize: 22, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 4),
      Text(descriptor.role, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text(descriptor.focus, style: const TextStyle(color: Colors.white60)),
      const SizedBox(height: 16),
      Text('AUTHORITATIVE STATE', style: TextStyle(color: descriptor.accent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
      const SizedBox(height: 8),
      Text('${relevant.length} relevant artifact(s)', style: const TextStyle(color: Colors.white)),
      const SizedBox(height: 10),
      Expanded(child: ListView.separated(
        itemCount: relevant.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) => _ArtifactTile(artifact: relevant[index], accent: descriptor.accent),
      )),
    ]);
  }
}

class _ArtifactTile extends StatelessWidget {
  final S8ArtifactSummary artifact;
  final Color accent;
  const _ArtifactTile({required this.artifact, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: .24), borderRadius: BorderRadius.circular(12), border: Border.all(color: accent.withValues(alpha: .24))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(artifact.title, style: const TextStyle(fontWeight: FontWeight.w700))), Text(artifact.status, style: TextStyle(color: accent, fontSize: 11))]),
          const SizedBox(height: 5),
          Text(artifact.id, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          if (artifact.parents.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text('Parents: ${artifact.parents.join(', ')}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
          if (artifact.uncertainty.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text('Uncertainty: ${artifact.uncertainty.join('; ')}', style: const TextStyle(color: Colors.amber, fontSize: 10)),
          ],
        ]),
      );
}
