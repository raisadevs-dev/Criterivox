import 'package:flutter/material.dart';

import 'character/live_agent_panel.dart';
import 'presentation/criterivox_theme.dart';
import 'presentation/presentation_state.dart';

class AnalysisContextWorkspacePage extends StatelessWidget {
  final PresentationState? state;
  final bool busy;
  final TextEditingController task;
  final TextEditingController data;
  final TextEditingController contextText;
  final VoidCallback onStart;
  final VoidCallback onBuildContext;
  final VoidCallback onOpenChat;
  final ValueChanged<String>? onChatCharacter;

  const AnalysisContextWorkspacePage(
      {super.key,
      required this.state,
      required this.busy,
      required this.task,
      required this.data,
      required this.contextText,
      required this.onStart,
      required this.onBuildContext,
      required this.onOpenChat,
      this.onChatCharacter});

  String _agentState(String id) {
    final current = state?.characterState.toUpperCase();
    if (current == null) return 'IDLE';
    if (id == state?.agentId.toLowerCase()) return current;
    if (id == 'anuka' &&
        (state?.contextUncertainty.isNotEmpty == true || current == 'WARNING')) {
      return 'RECEIVE';
    }
    return 'IDLE';
  }

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);
    final s = state;
    final narrow = MediaQuery.sizeOf(context).width < 900;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Analysis & Context Workspace',
                    style: TextStyle(
                        color: theme.text,
                        fontSize: 25,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                    'One working surface. Context is built, inspected and used for analysis without splitting the workflow into separate pages.',
                    style: TextStyle(
                        color: theme.mutedText, fontSize: 11, height: 1.45)),
              ])),
          const SizedBox(width: 12),
          OutlinedButton.icon(
              onPressed: onOpenChat,
              icon: const Icon(Icons.forum_outlined, size: 16),
              label: const Text('Character Chat')),
        ]),
        const SizedBox(height: 18),
        if (s == null)
          _StartForm(
              task: task,
              data: data,
              contextText: contextText,
              busy: busy,
              onStart: onStart,
              theme: theme)
        else ...[
          _TaskSummary(s: s, theme: theme),
          const SizedBox(height: 14),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _Metric('Context ID', s.contextId ?? 'Not built', theme),
            _Metric('Baseline', s.contextBaselineStatus ?? 'UNKNOWN', theme),
            _Metric(
                'Evidence',
                s.evidenceCompleteness == null
                    ? 'UNKNOWN'
                    : '${s.evidenceCompleteness}%',
                theme),
            _Metric('Observations', '${s.observations.length}', theme),
            _Metric('Findings', '${s.findings.length}', theme),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            FilledButton.icon(
                onPressed: s.foundationId == null ? null : onBuildContext,
                icon: const Icon(Icons.account_tree_rounded, size: 17),
                label: const Text('Build / refresh context')),
            const SizedBox(width: 9),
            OutlinedButton.icon(
                onPressed: onOpenChat,
                icon: const Icon(Icons.forum_outlined, size: 17),
                label: const Text('Character interaction')),
          ]),
          const SizedBox(height: 18),
          _Section(
              title: 'ANALYSIS RESULT',
              summary:
                  '${s.observations.length} observations • ${s.evidence.length} evidence',
              theme: theme,
              child: _AnalysisResult(s: s, theme: theme)),
          _Section(
              title: 'CONTEXT PROVENANCE GRAPH',
              summary: '${_graphCount(s.provenanceGraph)} nodes',
              theme: theme,
              child: _Graph(s: s, theme: theme)),
          _Section(
              title: 'CONTEXT DIFF',
              summary: _diffSummary(s.contextDiff),
              theme: theme,
              child: _Diff(s: s, theme: theme)),
          _Section(
              title: 'EVIDENCE DEBT',
              summary: s.evidenceCompleteness == null
                  ? 'UNKNOWN'
                  : '${s.evidenceCompleteness}% • ${s.evidenceDebtLevel ?? 'UNKNOWN'}',
              theme: theme,
              child: _Evidence(s: s, theme: theme)),
          _Section(
              title: 'CONTEXT MEMORY WITH EXPIRATION',
              summary: s.memoryStatus ?? 'UNKNOWN',
              theme: theme,
              child: _KeyValues(theme: theme, values: {
                'Status': s.memoryStatus ?? 'UNKNOWN',
                'Recheck at': s.memoryRecheckAt ?? 'UNKNOWN',
                'Reason': s.memoryRecheckReason ??
                    'No research-validated recheck rule supplied'
              })),
          _Section(
              title: 'AGENT OBSERVABILITY TIMELINE',
              summary: '${s.observabilityEvents.length} events',
              theme: theme,
              child: s.observabilityEvents.isEmpty
                  ? Text('No structured activity events have been emitted yet.',
                      style: TextStyle(color: theme.mutedText, fontSize: 10.5))
                  : Column(children: [
                      for (final event in s.observabilityEvents.take(20))
                        _Event(event: event, theme: theme)
                    ])),
          _Section(
              title: 'CONTROLLED MULTI-AGENT HANDOFF',
              summary: s.deliveryStatus ?? 'Not emitted',
              theme: theme,
              child: _KeyValues(theme: theme, values: {
                'Coordination ID': s.coordinationId ?? 'Not emitted',
                'Members': s.coordinationMembers.join(', '),
                'Recipient': s.deliveryRecipient ?? 'Not emitted',
                'Status': s.deliveryStatus ?? 'Not emitted'
              })),
          _Section(
              title: 'INTERPRETATION',
              summary: s.message == null ? 'No interpretation' : 'Available',
              theme: theme,
              child: _Interpretation(s: s, theme: theme)),
          const SizedBox(height: 6),
          Text('LIVE WORKING MEMBERS',
              style: TextStyle(
                  color: theme.mutedText,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2)),
          const SizedBox(height: 9),
          if (narrow) ...[
            LiveAgentPanel(
                characterId: 'dharen',
                responsibility: 'Context Architecture',
                workDescription:
                    'Structures the contextual representation and prepares the context boundary used by downstream analysis.',
                state: _agentState('dharen'),
                onChat: () => onChatCharacter?.call('dharen')),
            const SizedBox(height: 10),
            LiveAgentPanel(
                characterId: 'anuka',
                responsibility: 'Adaptive Context',
                workDescription:
                    'Monitors context change, uncertainty and requirement shifts. She becomes active when the current context needs adaptation or recovery.',
                state: _agentState('anuka'),
                onChat: () => onChatCharacter?.call('anuka')),
          ] else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: LiveAgentPanel(
                      characterId: 'dharen',
                      responsibility: 'Context Architecture',
                      workDescription:
                          'Structures the contextual representation and prepares the context boundary used by downstream analysis.',
                      state: _agentState('dharen'),
                      onChat: () => onChatCharacter?.call('dharen'))),
              const SizedBox(width: 12),
              Expanded(
                  child: LiveAgentPanel(
                      characterId: 'anuka',
                      responsibility: 'Adaptive Context',
                      workDescription:
                          'Monitors context change, uncertainty and requirement shifts. She becomes active when the current context needs adaptation or recovery.',
                      state: _agentState('anuka'),
                      onChat: () => onChatCharacter?.call('anuka'))),
            ]),
        ],
      ]),
    );
  }

  static int _graphCount(Map<String, dynamic>? graph) =>
      graph?['nodes'] is List ? (graph!['nodes'] as List).length : 0;
  static String _diffSummary(Map<String, dynamic>? diff) {
    final changed =
        diff?['changed'] is List ? (diff!['changed'] as List).length : 0;
    final added = diff?['added'] is List ? (diff!['added'] as List).length : 0;
    final removed =
        diff?['removed'] is List ? (diff!['removed'] as List).length : 0;
    return '$changed changed • $added added • $removed removed';
  }
}

class _StartForm extends StatelessWidget {
  final TextEditingController task, data, contextText;
  final bool busy;
  final VoidCallback onStart;
  final CriterivoxTheme theme;
  const _StartForm(
      {required this.task,
      required this.data,
      required this.contextText,
      required this.busy,
      required this.onStart,
      required this.theme});
  @override
  Widget build(BuildContext context) => _Section(
      title: 'START ANALYSIS',
      summary: 'Task + data + context',
      theme: theme,
      initiallyExpanded: true,
      child: Column(children: [
        TextField(
            controller: task,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Task')),
        const SizedBox(height: 9),
        TextField(
            controller: data,
            decoration: const InputDecoration(labelText: 'Data')),
        const SizedBox(height: 9),
        TextField(
            controller: contextText,
            decoration: const InputDecoration(labelText: 'Context')),
        const SizedBox(height: 14),
        Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
                onPressed: busy ? null : onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(busy ? 'Starting…' : 'Start Analysis'))),
      ]));
}

class _TaskSummary extends StatelessWidget {
  final PresentationState s;
  final CriterivoxTheme theme;
  const _TaskSummary({required this.s, required this.theme});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: theme.surfaceStrong,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.border)),
      child: Wrap(spacing: 24, runSpacing: 10, children: [
        _item('TASK', s.task ?? 'Unnamed task'),
        _item('STATUS', s.taskState ?? 'UNKNOWN'),
        _item('FOUNDATION', s.foundationId ?? 'None'),
        _item('CONTEXT', s.contextId ?? 'Not built')
      ]));
  Widget _item(String label, String value) => SizedBox(
      width: 190,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: theme.mutedText,
                fontSize: 8,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: theme.text, fontSize: 11, fontWeight: FontWeight.w700))
      ]));
}

class _AnalysisResult extends StatelessWidget {
  final PresentationState s;
  final CriterivoxTheme theme;
  const _AnalysisResult({required this.s, required this.theme});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (s.message != null)
          Text(s.message!,
              style: TextStyle(color: theme.text, fontSize: 12, height: 1.5)),
        const SizedBox(height: 10),
        Wrap(spacing: 22, runSpacing: 10, children: [
          _num('Observations', s.observations.length),
          _num('Findings', s.findings.length),
          _num('Evidence', s.evidence.length)
        ]),
        if (s.observations.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final item in s.observations.take(8))
            Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text('• ${item['text'] ?? ''}',
                    style: TextStyle(
                        color: theme.mutedText, fontSize: 10, height: 1.4)))
        ]
      ]);
  Widget _num(String label, int value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$value',
            style: TextStyle(
                color: theme.text, fontSize: 19, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: theme.mutedText, fontSize: 9))
      ]);
}

class _Graph extends StatelessWidget {
  final PresentationState s;
  final CriterivoxTheme theme;
  const _Graph({required this.s, required this.theme});
  @override
  Widget build(BuildContext context) {
    final nodes = s.provenanceGraph?['nodes'];
    if (nodes is! List || nodes.isEmpty) {
      return Text('No provenance graph has been built yet.',
          style: TextStyle(color: theme.mutedText, fontSize: 10.5));
    }
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final node in nodes.whereType<Map>())
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
                color: theme.surfaceStrong,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: theme.primary.withValues(alpha: .32))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${node['kind'] ?? 'unknown'}',
                  style: TextStyle(
                      color: theme.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text('${node['label'] ?? 'Unknown'}',
                  style: TextStyle(
                      color: theme.text,
                      fontSize: 10,
                      fontWeight: FontWeight.w600))
            ]))
    ]);
  }
}

class _Diff extends StatelessWidget {
  final PresentationState s;
  final CriterivoxTheme theme;
  const _Diff({required this.s, required this.theme});
  @override
  Widget build(BuildContext context) {
    final d = s.contextDiff;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _row('Added', d?['added']),
      _row('Removed', d?['removed']),
      _row('Changed', d?['changed']),
      _row('Unchanged', d?['unchanged']),
      const SizedBox(height: 7),
      Text('Structural change is not treated as semantic equivalence.',
          style: TextStyle(color: theme.mutedText, fontSize: 9.5))
    ]);
  }

  Widget _row(String label, dynamic values) => Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 85,
            child: Text(label,
                style: TextStyle(color: theme.mutedText, fontSize: 9))),
        Expanded(
            child: Text(
                values is List && values.isNotEmpty
                    ? values.join(', ')
                    : 'None',
                style: TextStyle(color: theme.text, fontSize: 10.5)))
      ]));
}

class _Evidence extends StatelessWidget {
  final PresentationState s;
  final CriterivoxTheme theme;
  const _Evidence({required this.s, required this.theme});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            s.evidenceCompleteness == null
                ? 'UNKNOWN'
                : '${s.evidenceCompleteness}%',
            style: TextStyle(
                color: theme.text, fontSize: 25, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Evidence completeness indicator, not a confidence probability.',
            style: TextStyle(color: theme.mutedText, fontSize: 9.5)),
        const SizedBox(height: 9),
        Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final tag in s.evidenceTags) _Tag(tag, theme)])
      ]);
}

class _Tag extends StatelessWidget {
  final String text;
  final CriterivoxTheme theme;
  const _Tag(this.text, this.theme);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: theme.surfaceStrong,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.border)),
      child: Text(text,
          style: TextStyle(
              color: theme.mutedText,
              fontSize: 9,
              fontWeight: FontWeight.w600)));
}

class _Interpretation extends StatelessWidget {
  final PresentationState s;
  final CriterivoxTheme theme;
  const _Interpretation({required this.s, required this.theme});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.message ?? 'No contextual interpretation has been produced yet.',
            style: TextStyle(color: theme.text, fontSize: 12, height: 1.5)),
        if (s.contextUncertainty.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('UNCERTAINTY  ${s.contextUncertainty.join(' • ')}',
              style: TextStyle(color: theme.mutedText, fontSize: 10))
        ],
        if (s.contextLimitations.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('LIMITATIONS  ${s.contextLimitations.join(' • ')}',
              style: TextStyle(color: theme.mutedText, fontSize: 10))
        ]
      ]);
}

class _Event extends StatelessWidget {
  final Map<String, dynamic> event;
  final CriterivoxTheme theme;
  const _Event({required this.event, required this.theme});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 5, right: 8),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: theme.primary)),
        Expanded(
            child: Text(
                '${event['character_id'] ?? 'unknown'} • ${event['action'] ?? 'event'} • ${event['reason'] ?? ''}',
                style: TextStyle(color: theme.text, fontSize: 10.5)))
      ]));
}

class _Metric extends StatelessWidget {
  final String label, value;
  final CriterivoxTheme theme;
  const _Metric(this.label, this.value, this.theme);
  @override
  Widget build(BuildContext context) => Container(
      width: 195,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: theme.surfaceStrong,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: theme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: theme.mutedText,
                fontSize: 8.5,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: theme.text, fontSize: 12, fontWeight: FontWeight.w700))
      ]));
}

class _KeyValues extends StatelessWidget {
  final CriterivoxTheme theme;
  final Map<String, String> values;
  const _KeyValues({required this.theme, required this.values});
  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 24, runSpacing: 10, children: [
        for (final item in values.entries)
          SizedBox(
              width: 240,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.key,
                        style: TextStyle(color: theme.mutedText, fontSize: 9)),
                    const SizedBox(height: 3),
                    Text(item.value,
                        style: TextStyle(
                            color: theme.text, fontSize: 10.5, height: 1.35))
                  ]))
      ]);
}

class _Section extends StatefulWidget {
  final String title, summary;
  final Widget child;
  final CriterivoxTheme theme;
  final bool initiallyExpanded;
  const _Section(
      {required this.title,
      required this.summary,
      required this.theme,
      required this.child,
      this.initiallyExpanded = false});
  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  late bool expanded = widget.initiallyExpanded;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: widget.theme.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: widget.theme.border)),
      child: Column(children: [
        InkWell(
            onTap: () => setState(() => expanded = !expanded),
            borderRadius: BorderRadius.circular(17),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(children: [
                  Expanded(
                      child: Text(widget.title,
                          style: TextStyle(
                              color: widget.theme.text,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0))),
                  Flexible(
                      child: Text(widget.summary,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: widget.theme.mutedText, fontSize: 9))),
                  const SizedBox(width: 7),
                  Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: widget.theme.mutedText,
                      size: 19)
                ]))),
        if (expanded)
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.child)
      ]));
}
