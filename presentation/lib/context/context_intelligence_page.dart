import 'package:flutter/material.dart';

import '../analysis_context_workspace_page.dart';
import '../character/live_agent_panel.dart';
import '../presentation/criterivox_theme.dart';
import '../presentation/presentation_state.dart';
import 'context_workspace_page.dart';
import 'home02_context_console.dart';

/// Canonical Home 02 surface.
///
/// The former Home02ContextConsole, ContextWorkspacePage and
/// AnalysisContextWorkspacePage are implementation layers of this one House.
/// They are not separate navigation destinations.
class ContextIntelligencePage extends StatelessWidget {
  final PresentationState? state;
  final bool busy;
  final TextEditingController task;
  final TextEditingController data;
  final TextEditingController contextText;
  final VoidCallback onStart;
  final VoidCallback onBuildContext;
  final VoidCallback onManualAdapt;
  final ValueChanged<String>? onChatCharacter;
  final VoidCallback onCreateSandbox;
  final VoidCallback onRunSandbox;
  final VoidCallback onInspectSandbox;
  final VoidCallback onPromoteSandbox;
  final VoidCallback onDiscardSandbox;
  final bool sandboxReady;
  final int initialLayer;

  const ContextIntelligencePage({
    super.key,
    required this.state,
    required this.busy,
    required this.task,
    required this.data,
    required this.contextText,
    required this.onStart,
    required this.onBuildContext,
    required this.onManualAdapt,
    this.onChatCharacter,
    required this.onCreateSandbox,
    required this.onRunSandbox,
    required this.onInspectSandbox,
    required this.onPromoteSandbox,
    required this.onDiscardSandbox,
    required this.sandboxReady,
    this.initialLayer = 0,
  });

  String _agentState(String id) {
    final current = state?.characterState.toUpperCase();
    if (current != null && id == state?.agentId.toLowerCase()) return current;
    if (id == 'anuka' &&
        (state?.contextUncertainty.isNotEmpty == true ||
            current == 'WARNING')) {
      return 'RECEIVE';
    }
    if (id == 'dharen' && state?.contextId != null) return 'WORK';
    return 'IDLE';
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final initial = initialLayer.clamp(0, 2);
    return DefaultTabController(
      length: 3,
      initialIndex: initial,
      child: Container(
        color: t.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HOUSE 02 • CONTEXT INTELLIGENCE',
                      style: TextStyle(
                          color: t.mutedText,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text('Dharen + Anuka',
                      style: TextStyle(
                          color: t.text,
                          fontSize: 27,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    'Dharen establishes the operational context boundary. Anuka adapts it when requirements, evidence or constraints change.',
                    style: TextStyle(
                        color: t.mutedText, fontSize: 11, height: 1.45),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: LayoutBuilder(builder: (context, constraints) {
                final narrow = constraints.maxWidth < 900;
                final members = [
                  LiveAgentPanel(
                    characterId: 'dharen',
                    responsibility: 'Context Architecture',
                    workDescription:
                        'Establishes scope, baseline, priority and the authoritative context boundary.',
                    state: _agentState('dharen'),
                  ),
                  LiveAgentPanel(
                    characterId: 'anuka',
                    responsibility: 'Adaptive Context',
                    workDescription:
                        'Re-evaluates context when goals, evidence or constraints shift and supports controlled forks.',
                    state: _agentState('anuka'),
                  ),
                ];
                return narrow
                    ? Column(children: [
                        members[0],
                        const SizedBox(height: 10),
                        members[1],
                      ])
                    : Row(children: [
                        Expanded(child: members[0]),
                        const SizedBox(width: 10),
                        Expanded(child: members[1]),
                      ]);
              }),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: t.border),
                ),
                child: const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: '01  OPERATE'),
                    Tab(text: '02  INSPECT'),
                    Tab(text: '03  ANALYZE'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                children: [
                  Home02ContextConsole(
                    state: state,
                    onBuildContext: onBuildContext,
                    onManualAdapt: onManualAdapt,
                    onCreateSandbox: onCreateSandbox,
                    onRunSandbox: onRunSandbox,
                    onInspectSandbox: onInspectSandbox,
                    onPromoteSandbox: onPromoteSandbox,
                    onDiscardSandbox: onDiscardSandbox,
                    sandboxReady: sandboxReady,
                  ),
                  ContextWorkspacePage(
                    state: state,
                    onBuildContext: onBuildContext,
                  ),
                  AnalysisContextWorkspacePage(
                    state: state,
                    busy: busy,
                    task: task,
                    data: data,
                    contextText: contextText,
                    onStart: onStart,
                    onBuildContext: onBuildContext,
                    onChatCharacter: onChatCharacter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
