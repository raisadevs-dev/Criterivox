import 'package:flutter/material.dart';
import 'data_stewardship_page.dart';
import 'character/live_agent_panel.dart';
import 'presentation/criterivox_theme.dart';
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';

class StewardshipLiveWorkspacePage extends StatelessWidget {
  final PresentationState? state;
  final CharacterRuntimeClient runtime;
  final ValueChanged<String>? onChatCharacter;

  const StewardshipLiveWorkspacePage({super.key, required this.state, required this.runtime, this.onChatCharacter});

  String _stateFor(String id) {
    final current = state?.characterState.toUpperCase();
    if (id == state?.agentId.toLowerCase() && current != null) return current;
    if (id == 'kaelen' && (current == 'HANDOFF' || current == 'WORK')) return 'WORK';
    return 'IDLE';
  }

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);
    final narrow = MediaQuery.sizeOf(context).width < 900;
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DataStewardshipPage(state: state, runtime: runtime),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LIVE WORKING MEMBERS', style: TextStyle(color: theme.mutedText, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            const SizedBox(height: 9),
            if (narrow) ...[
              LiveAgentPanel(characterId: 'sandre', responsibility: 'Data Stewardship', workDescription: 'Owns the data foundation: intake, inspection, confirmation, provenance choices, quality and safe downstream handoff.', state: _stateFor('sandre'), onChat: () => onChatCharacter?.call('sandre')),
              const SizedBox(height: 10),
              LiveAgentPanel(characterId: 'kaelen', responsibility: 'Build + Experimentation', workDescription: 'Works from Sandre’s validated material to prepare downstream build and experimentation work. Kaelen is a working member, not a passive roommate label.', state: _stateFor('kaelen'), onChat: () => onChatCharacter?.call('kaelen')),
            ] else
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: LiveAgentPanel(characterId: 'sandre', responsibility: 'Data Stewardship', workDescription: 'Owns the data foundation: intake, inspection, confirmation, provenance choices, quality and safe downstream handoff.', state: _stateFor('sandre'), onChat: () => onChatCharacter?.call('sandre'))),
                const SizedBox(width: 12),
                Expanded(child: LiveAgentPanel(characterId: 'kaelen', responsibility: 'Build + Experimentation', workDescription: 'Works from Sandre’s validated material to prepare downstream build and experimentation work. Kaelen is a working member, not a passive roommate label.', state: _stateFor('kaelen'), onChat: () => onChatCharacter?.call('kaelen'))),
              ]),
          ]),
        ),
      ]),
    );
  }
}
