import 'package:flutter/material.dart';

import '../character/live_agent_panel.dart';
import '../presentation/criterivox_theme.dart';
import 'anuka_presentation.dart';

class AnukaWorkspacePage extends StatelessWidget {
  final String state;

  const AnukaWorkspacePage({super.key, this.state = 'IDLE'});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Anuka Context Adaptation',
              style: TextStyle(color: t.text, fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Drift, adaptive state, sandboxing, checkpoints and handoff',
              style: TextStyle(color: t.mutedText, fontSize: 11)),
          const SizedBox(height: 14),
          LiveAgentPanel(
            characterId: AnukaPresentation.characterId,
            responsibility: AnukaPresentation.role,
            workDescription:
                'Owns conditional context adaptation, drift handling, sandbox forks, checkpoints and adaptive handoff.',
            state: state,
          ),
          const SizedBox(height: 14),
          ...AnukaPresentation.capabilities.map(
            (capability) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.surfaceStrong,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.border),
              ),
              child: Row(
                children: [
                  Icon(capability.icon, color: t.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(capability.label,
                            style: TextStyle(color: t.text, fontWeight: FontWeight.w800, fontSize: 12)),
                        const SizedBox(height: 3),
                        Text(capability.description,
                            style: TextStyle(color: t.mutedText, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
