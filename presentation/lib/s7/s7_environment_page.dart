import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 's7_visuals.dart';

class S7EnvironmentPage extends StatefulWidget {
  const S7EnvironmentPage({super.key});

  @override
  State<S7EnvironmentPage> createState() => _S7EnvironmentPageState();
}

class _S7EnvironmentPageState extends State<S7EnvironmentPage>
    with SingleTickerProviderStateMixin {
  static const _api = 'http://127.0.0.1:8017/api/s7';

  String room = 'collaboration';
  Map<String, dynamic>? session;
  Map<String, dynamic>? selected;
  bool busy = false;
  String? error;

  late final AnimationController motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  final task = TextEditingController(
    text: 'Compare two possible explanations for the supplied observations and identify uncertainty and limitations.',
  );

  final contextText = TextEditingController(
    text: '{\n  "observations": [\n    "Signal A increased after event X.",\n    "Signal A returned toward baseline when event X stopped.",\n    "A second independent measurement showed a weaker version of the same pattern."\n  ],\n  "source": "synthetic S7 research fixture"\n}',
  );

  @override
  void dispose() {
    motion.dispose();
    task.dispose();
    contextText.dispose();
    super.dispose();
  }

  Future<void> run() async {
    setState(() {
      busy = true;
      error = null;
      selected = null;
    });

    try {
      final context = _decodeContext(contextText.text);
      final response = await http.post(
        Uri.parse('$_api/sessions'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'task': task.text.trim(), 'context': context}),
      );
      final body = _decodeResponse(response);
      if (response.statusCode >= 400) {
        throw Exception(body['error'] ?? 'S7 request failed');
      }
      setState(() => session = Map<String, dynamic>.from(body));
    } catch (e) {
      setState(() => error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Map<String, dynamic> _decodeContext(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return {};
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      // Plain-language context is still valid S7 input.
    }
    return {'description': text};
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'error': 'S7 returned an unexpected response.'};
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('ClientException')) {
      return 'Cannot reach the S7 backend at 127.0.0.1:8017. Check the launcher/backend terminal.';
    }
    return text.replaceFirst('Exception: ', '');
  }

  Future<void> intervene(String action, {String instruction = ''}) async {
    final currentSession = session;
    final currentSelected = selected;
    if (currentSession == null || currentSelected == null) return;

    final sessionId = currentSession['session_id']?.toString();
    final artifactId = currentSelected['artifact_id']?.toString();
    if (sessionId == null || artifactId == null) return;

    setState(() {
      busy = true;
      error = null;
    });
    try {
      final response = await http.post(
        Uri.parse('$_api/sessions/$sessionId/intervene'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'artifact_id': artifactId,
          'action': action,
          'instruction': instruction,
        }),
      );
      final body = _decodeResponse(response);
      if (response.statusCode >= 400) {
        throw Exception(body['error'] ?? 'S7 intervention failed');
      }
      setState(() => session = Map<String, dynamic>.from(body));
    } catch (e) {
      setState(() => error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> challenge() async {
    if (selected == null) return;
    final controller = TextEditingController();
    final instruction = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff111525),
        title: const Text('Challenge analytical object'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'State the objection, missing assumption, or alternative context.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('CREATE BRANCH')),
        ],
      ),
    );
    controller.dispose();
    if (instruction != null && instruction.isNotEmpty) {
      await intervene('challenge', instruction: instruction);
    }
  }

  Future<void> requestContext() async {
    if (selected == null) return;
    final controller = TextEditingController();
    final instruction = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff111525),
        title: const Text('Request additional context'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Describe the information S7 needs before continuing.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('REQUEST')),
        ],
      ),
    );
    controller.dispose();
    if (instruction != null && instruction.isNotEmpty) {
      await intervene('request_context', instruction: instruction);
    }
  }

  void preset(String id) {
    switch (id) {
      case 'normal':
        task.text = 'Compare two possible explanations for the supplied observations and identify uncertainty and limitations.';
        contextText.text = '{\n  "observations": [\n    "Signal A increased after event X.",\n    "Signal A returned toward baseline when event X stopped.",\n    "An independent measurement showed a weaker version of the same pattern."\n  ],\n  "source": "synthetic S7 research fixture"\n}';
        break;
      case 'competing':
        task.text = 'Explore competing explanations for the observation and compare the candidate reasoning paths.';
        contextText.text = '{\n  "observations": [\n    "The observed change follows event X.",\n    "The same change can also be explained by background condition Y."\n  ],\n  "candidate_hypotheses": ["event X is causal", "condition Y is causal"],\n  "source": "synthetic competing-hypothesis fixture"\n}';
        break;
      case 'contradiction':
        task.text = 'Evaluate the observation while preserving contradictory evidence and explicitly reporting unresolved disagreement.';
        contextText.text = '{\n  "observations": [\n    "Measurement A supports explanation P.",\n    "Measurement B conflicts with explanation P.",\n    "Measurement C is inconclusive."\n  ],\n  "contradictions": ["A conflicts with B"],\n  "source": "synthetic contradiction fixture"\n}';
        break;
      case 'insufficient':
        task.text = 'Determine whether the supplied information is sufficient to establish a bounded analytical conclusion.';
        contextText.text = '';
        break;
    }
    setState(() {
      session = null;
      selected = null;
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final artifacts = _list(session?['artifacts']);
    return Scaffold(
      backgroundColor: const Color(0xff03050b),
      body: AnimatedBuilder(
        animation: motion,
        builder: (context, child) => Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: S7BureauBackdrop(progress: motion.value, room: room),
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  _rail(),
                  Expanded(child: _environment(artifacts)),
                ],
              ),
            ),
            if (busy)
              const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
            if (error != null) _errorBanner(),
          ],
        ),
      ),
    );
  }

  Widget _rail() {
    final status = session?['status']?.toString() ?? 'READY';
    return Container(
      width: 214,
      decoration: BoxDecoration(
        color: const Color(0xff050712).withValues(alpha: .78),
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: .06))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('REASONING', style: TextStyle(fontSize: 10, letterSpacing: 2.5, color: Colors.white38, fontWeight: FontWeight.w700)),
            const Text('RESEARCH BUREAU', style: TextStyle(fontSize: 17, letterSpacing: 1.1, color: Colors.white, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('S7 · standalone intelligence environment', style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: .35))),
            const SizedBox(height: 28),
            _nav('collaboration', Icons.groups_rounded, 'COLLABORATION ROOM', 'shared intelligence'),
            _nav('vivren', Icons.visibility_rounded, 'VIVREN', 'critical inspection'),
            _nav('tarkis', Icons.account_tree_rounded, 'TARKIS', 'hypothesis exploration'),
            const Spacer(),
            S7SectionLabel('Bureau status', accent: Colors.white54),
            const SizedBox(height: 6),
            Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 1.4, color: Colors.white70, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(session == null ? 'No analytical session loaded' : 'Session ${session!['session_id']}', style: const TextStyle(fontSize: 7, color: Colors.white30), maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _nav(String id, IconData icon, String title, String subtitle) {
    final active = room == id;
    final accent = id == 'tarkis' ? const Color(0xffffb463) : const Color(0xffb59cff);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: active ? Colors.white.withValues(alpha: .075) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() {
            room = id;
            selected = null;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: active ? accent : Colors.white30),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .7, color: active ? Colors.white : Colors.white45)),
                  Text(subtitle, style: const TextStyle(fontSize: 7, color: Colors.white25)),
                ])),
                if (active) Icon(Icons.chevron_right, size: 15, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _environment(List<Map<String, dynamic>> artifacts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 20, compact ? 16 : 28, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
            child: room == 'collaboration'
                ? _collaboration(artifacts, compact)
                : _chamber(artifacts, compact),
          ),
        );
      },
    );
  }

  Widget _collaboration(List<Map<String, dynamic>> artifacts, bool compact) {
    final vivrenState = _characterState('vivren');
    final tarkisState = _characterState('tarkis');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(
          'REASONING RESEARCH BUREAU',
          'COLLABORATION ROOM',
          'A shared reasoning workspace for Vivren, Tarkis and human inspection.',
          const Color(0xffc8b7ff),
        ),
        const SizedBox(height: 14),
        _requestPanel(),
        const SizedBox(height: 12),
        _fixtureStrip(),
        const SizedBox(height: 16),
        if (compact)
          Column(children: [
            _sceneCard(vivrenState, tarkisState, compact),
            const SizedBox(height: 12),
            _analysisPanel(artifacts),
            const SizedBox(height: 12),
            _attentionPanel(artifacts),
          ])
        else
          SizedBox(
            height: 500,
            child: Stack(
              children: [
                Positioned.fill(child: _sceneCard(vivrenState, tarkisState, compact)),
                Positioned(left: 14, top: 14, width: 300, child: _analysisPanel(artifacts)),
                Positioned(right: 14, top: 14, width: 270, child: _attentionPanel(artifacts)),
                if (selected != null)
                  Positioned(left: 14, bottom: 14, right: 14, child: _selectedStrip()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _sceneCard(Map<String, dynamic> vivrenState, Map<String, dynamic> tarkisState, bool compact) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
        color: const Color(0xff080b16).withValues(alpha: .40),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: compact ? 20 : 32, child: const S7SectionLabel('SHARED INTELLIGENCE TABLE')),
          Positioned(
            left: compact ? 18 : 65,
            bottom: 15,
            child: Column(children: [
              S7BureauCharacter(identity: 'Vivren', state: vivrenState['state']?.toString() ?? 'idle', progress: motion.value, scale: compact ? .68 : .9),
              const Text('VIVREN', style: TextStyle(fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w900, color: Colors.white70)),
              Text(vivrenState['state']?.toString().toUpperCase() ?? 'IDLE', style: const TextStyle(fontSize: 7, color: Color(0xffb59cff))),
            ]),
          ),
          Positioned(
            right: compact ? 18 : 65,
            bottom: 15,
            child: Column(children: [
              S7BureauCharacter(identity: 'Tarkis', state: tarkisState['state']?.toString() ?? 'idle', progress: motion.value, scale: compact ? .68 : .9),
              const Text('TARKIS', style: TextStyle(fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w900, color: Colors.white70)),
              Text(tarkisState['state']?.toString().toUpperCase() ?? 'IDLE', style: const TextStyle(fontSize: 7, color: Color(0xffffb463))),
            ]),
          ),
          Positioned(top: compact ? 100 : 125, child: _sharedCore()),
          Positioned(bottom: compact ? 10 : 20, child: const _HumanMarker()),
        ],
      ),
    );
  }

  Widget _sharedCore() {
    final hasSession = session != null;
    return Container(
      width: 220,
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xff101426).withValues(alpha: .68),
        borderRadius: BorderRadius.circular(80),
        border: Border.all(color: const Color(0xffc8b7ff).withValues(alpha: .18)),
        boxShadow: [BoxShadow(color: const Color(0xff9d86ff).withValues(alpha: .08), blurRadius: 35)],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.hub_rounded, size: 25, color: hasSession ? const Color(0xffc8b7ff) : Colors.white24),
        const SizedBox(height: 7),
        const Text('SHARED WORK', style: TextStyle(fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w900, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(hasSession ? 'artifacts · branches · evaluation' : 'awaiting analytical request', style: const TextStyle(fontSize: 7, color: Colors.white30)),
      ]),
    );
  }

  Widget _analysisPanel(List<Map<String, dynamic>> artifacts) {
    return S7GlassPanel(
      title: 'LIVE ANALYTICAL ACTIVITY',
      accent: const Color(0xffc8b7ff),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          S7Metric('Artifacts', '${artifacts.length}', accent: const Color(0xffc8b7ff)),
          S7Metric('Branches', '${_list(session?['branches']).length}', accent: const Color(0xffc8b7ff)),
          S7Metric('Interventions', '${_list(session?['interventions']).length}', accent: const Color(0xffc8b7ff)),
        ]),
        const SizedBox(height: 12),
        const Divider(color: Colors.white10),
        if (artifacts.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('No analytical artifacts yet. Run a task to populate the Bureau.', style: TextStyle(fontSize: 8, color: Colors.white30)))
        else
          ...artifacts.take(5).map((a) => _artifactTile(a)),
      ]),
    );
  }

  Widget _attentionPanel(List<Map<String, dynamic>> artifacts) {
    final status = session?['status']?.toString() ?? 'READY';
    final limitations = artifacts.where((a) => a['kind'] == 'limitation' || a['kind'] == 'objection').toList();
    return S7GlassPanel(
      title: 'HUMAN ATTENTION',
      accent: const Color(0xffffc77d),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stateLine('SESSION', status, const Color(0xffc8b7ff)),
        _stateLine('BRANCH', session?['branch_id']?.toString() ?? 'main', const Color(0xffffb463)),
        _stateLine('LIMITATIONS', '${limitations.length}', const Color(0xffffc77d)),
        const SizedBox(height: 10),
        const Text('Inspect an artifact to activate human actions.', style: TextStyle(fontSize: 8, color: Colors.white30)),
        if (selected != null) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _actionButton('CHALLENGE', Icons.gavel_rounded, challenge),
            _actionButton('REQUEST CONTEXT', Icons.add_comment_rounded, requestContext),
            _actionButton('REJECT', Icons.block_rounded, () => intervene('reject')),
            _actionButton('CONTINUE', Icons.play_arrow_rounded, () => intervene('continue')),
          ]),
        ],
      ]),
    );
  }

  Widget _selectedStrip() {
    final item = selected!;
    return Material(
      color: const Color(0xff0b0f1c).withValues(alpha: .92),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _inspect(item),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Row(children: [
          const Icon(Icons.open_in_new_rounded, size: 15, color: Color(0xffc8b7ff)),
          const SizedBox(width: 8),
          Expanded(child: Text(item['title']?.toString() ?? 'Selected analytical object', style: const TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.w700))),
          const Text('DEEP INSPECTION', style: TextStyle(fontSize: 7, letterSpacing: 1.2, color: Colors.white38)),
        ])),
      ),
    );
  }

  Widget _artifactTile(Map<String, dynamic> artifact) {
    final active = selected?['artifact_id'] == artifact['artifact_id'];
    final kind = artifact['kind']?.toString() ?? 'artifact';
    final accent = kind == 'hypothesis' || kind == 'comparison' ? const Color(0xffffb463) : const Color(0xffc8b7ff);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: active ? accent.withValues(alpha: .10) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () => setState(() => selected = artifact),
          child: Padding(padding: const EdgeInsets.all(8), child: Row(children: [
            Icon(_artifactIcon(kind), size: 13, color: accent),
            const SizedBox(width: 7),
            Expanded(child: Text(artifact['title']?.toString() ?? kind, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Colors.white60))),
            Text('v${artifact['version'] ?? 1}', style: const TextStyle(fontSize: 7, color: Colors.white24)),
          ])),
        ),
      ),
    );
  }

  Widget _chamber(List<Map<String, dynamic>> artifacts, bool compact) {
    final isVivren = room == 'vivren';
    final accent = isVivren ? const Color(0xffad92ff) : const Color(0xffffb463);
    final title = isVivren ? 'CRITICAL INTELLIGENCE CHAMBER' : 'HYPOTHESIS EXPLORATION CHAMBER';
    final identity = isVivren ? 'Vivren' : 'Tarkis';
    final filtered = artifacts.where((a) {
      if (isVivren) return ['evaluation', 'objection', 'limitation', 'reasoning'].contains(a['kind']);
      return ['hypothesis', 'comparison', 'reasoning', 'result'].contains(a['kind']);
    }).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _header('REASONING RESEARCH BUREAU', title, isVivren ? 'Critical inspection, assumptions, evidence quality and epistemic limits.' : 'Alternative hypotheses, branching, search, counterfactuals and refinement.', accent),
      const SizedBox(height: 16),
      if (compact)
        Column(children: [
          _characterStage(identity, accent, compact),
          const SizedBox(height: 12),
          _roomPanel(filtered, isVivren, accent),
        ])
      else
        SizedBox(
          height: 620,
          child: Stack(children: [
            Positioned.fill(child: _characterStage(identity, accent, compact)),
            Positioned(left: 16, top: 16, width: 340, child: _roomPanel(filtered, isVivren, accent)),
            Positioned(right: 16, bottom: 16, width: 340, child: _chamberStatus(artifacts, accent)),
            if (selected != null) Positioned(left: 16, bottom: 16, right: 370, child: _selectedStrip()),
          ]),
        ),
    ]);
  }

  Widget _characterStage(String identity, Color accent, bool compact) {
    final state = _characterState(identity.toLowerCase());
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xff090c16).withValues(alpha: .48),
        border: Border.all(color: accent.withValues(alpha: .13)),
      ),
      child: Stack(alignment: Alignment.center, children: [
        Positioned(top: 22, child: S7SectionLabel('${identity.toUpperCase()} · ACTIVE RESEARCH STATION', accent: accent)),
        Positioned(top: 55, child: Container(width: compact ? 240 : 330, height: 90, decoration: BoxDecoration(borderRadius: BorderRadius.circular(80), border: Border.all(color: accent.withValues(alpha: .12)), boxShadow: [BoxShadow(color: accent.withValues(alpha: .06), blurRadius: 50)]))),
        Positioned(bottom: compact ? 18 : 28, child: Column(children: [
          S7BureauCharacter(identity: identity, state: state['state']?.toString() ?? 'idle', progress: motion.value, scale: compact ? .88 : 1.12),
          Text(identity.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 2.3, fontWeight: FontWeight.w900, color: Colors.white70)),
          Text(state['state']?.toString().toUpperCase() ?? 'IDLE', style: TextStyle(fontSize: 7, letterSpacing: 1.3, color: accent)),
        ])),
      ]),
    );
  }

  Widget _roomPanel(List<Map<String, dynamic>> artifacts, bool vivren, Color accent) {
    final title = vivren ? 'CRITICAL FINDINGS' : 'HYPOTHESIS FIELD';
    return S7GlassPanel(
      title: title,
      accent: accent,
      child: artifacts.isEmpty
          ? Text(vivren ? 'No critical analytical objects yet.' : 'No hypothesis objects yet. Run a task from the Collaboration Room.', style: const TextStyle(fontSize: 8, color: Colors.white30))
          : Column(children: artifacts.take(8).map((a) => _artifactTile(a)).toList()),
    );
  }

  Widget _chamberStatus(List<Map<String, dynamic>> artifacts, Color accent) {
    return S7GlassPanel(
      title: 'INSPECTION STATE',
      accent: accent,
      initiallyExpanded: true,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        S7Metric('Artifacts', '${artifacts.length}', accent: accent),
        S7Metric('Branch', session?['branch_id']?.toString() ?? 'main', accent: accent),
        S7Metric('Status', session?['status']?.toString() ?? 'READY', accent: accent),
      ]),
    );
  }

  Widget _requestPanel() {
    return S7GlassPanel(
      title: 'NEW ANALYTICAL REQUEST',
      accent: const Color(0xffc8b7ff),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: TextField(controller: task, maxLines: 2, decoration: const InputDecoration(labelText: 'Task', hintText: 'Describe the analytical objective.'))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: contextText, maxLines: 3, decoration: const InputDecoration(labelText: 'Structured context / internal Criterivox data', hintText: 'JSON object or plain-language context.'))),
          const SizedBox(width: 12),
          FilledButton.icon(onPressed: busy ? null : run, icon: const Icon(Icons.play_arrow_rounded), label: const Text('RUN BUREAU')),
        ]),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerLeft, child: Text('Input boundary: human or upstream structured request → S7. The visual characters represent state; mechanisms perform computation.', style: TextStyle(fontSize: 7, color: Colors.white.withValues(alpha: .28)))),
      ]),
    );
  }

  Widget _fixtureStrip() {
    return S7GlassPanel(
      title: 'TEST CASES · LOCAL FIXTURE LAB',
      accent: const Color(0xffffc77d),
      child: Wrap(spacing: 7, runSpacing: 7, children: [
        _presetButton('NORMAL REASONING', 'normal'),
        _presetButton('COMPETING HYPOTHESES', 'competing'),
        _presetButton('CONTRADICTORY EVIDENCE', 'contradiction'),
        _presetButton('INSUFFICIENT CONTEXT', 'insufficient'),
      ]),
    );
  }

  Widget _presetButton(String label, String id) {
    return OutlinedButton.icon(
      onPressed: busy ? null : () => preset(id),
      icon: const Icon(Icons.science_outlined, size: 13),
      label: Text(label, style: const TextStyle(fontSize: 7, letterSpacing: .8)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white60,
        side: BorderSide(color: Colors.white.withValues(alpha: .10)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    );
  }

  Widget _header(String bureau, String title, String subtitle, Color accent) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 4, height: 50, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: accent.withValues(alpha: .35), blurRadius: 18)])),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(bureau, style: const TextStyle(fontSize: 9, letterSpacing: 2.2, color: Colors.white38, fontWeight: FontWeight.w800)),
        Text(title, style: const TextStyle(fontSize: 22, letterSpacing: .5, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(fontSize: 8, color: Colors.white38)),
      ])),
      if (session != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: accent.withValues(alpha: .08), borderRadius: BorderRadius.circular(10), border: Border.all(color: accent.withValues(alpha: .12))), child: Text(session!['status']?.toString() ?? 'READY', style: TextStyle(fontSize: 7, letterSpacing: 1.1, color: accent, fontWeight: FontWeight.w800))),
    ]);
  }

  Widget _stateLine(String label, String value, Color accent) {
    return Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(children: [Container(width: 5, height: 5, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 7, letterSpacing: 1, color: Colors.white30)), const Spacer(), Flexible(child: Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Colors.white60, fontWeight: FontWeight.w700)))]));
  }

  Widget _actionButton(String label, IconData icon, VoidCallback action) {
    return OutlinedButton.icon(onPressed: busy ? null : action, icon: Icon(icon, size: 12), label: Text(label, style: const TextStyle(fontSize: 6.5, letterSpacing: .5)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6), side: BorderSide(color: Colors.white.withValues(alpha: .10)), foregroundColor: Colors.white60, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
  }

  Map<String, dynamic> _characterState(String id) {
    final states = session?['character_states'];
    if (states is Map) {
      final item = states[id];
      if (item is Map) return Map<String, dynamic>.from(item);
    }
    return {'identity': id.toUpperCase(), 'state': 'idle', 'role': id == 'vivren' ? 'critical intelligence' : 'hypothesis exploration'};
  }

  Future<void> _inspect(Map<String, dynamic> artifact) async {
    final sessionId = session?['session_id']?.toString();
    final artifactId = artifact['artifact_id']?.toString();
    if (sessionId == null || artifactId == null) return;
    setState(() => selected = artifact);
    try {
      final response = await http.get(Uri.parse('$_api/sessions/$sessionId/artifacts/$artifactId/lineage'));
      if (response.statusCode < 400) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          _showInspection(body);
          return;
        }
      }
    } catch (_) {
      // The selected artifact remains inspectable from the local snapshot.
    }
    _showInspection({'artifact': artifact, 'lineage': {}, 'provenance': {}});
  }

  void _showInspection(Map<String, dynamic> body) {
    final artifact = body['artifact'] is Map ? Map<String, dynamic>.from(body['artifact']) : selected!;
    final lineage = body['lineage'] is Map ? Map<String, dynamic>.from(body['lineage']) : <String, dynamic>{};
    final provenance = body['provenance'] is Map ? Map<String, dynamic>.from(body['provenance']) : <String, dynamic>{};
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff080b14),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .70,
        maxChildSize: .94,
        minChildSize: .40,
        builder: (_, controller) => ListView(controller: controller, padding: const EdgeInsets.all(24), children: [
          Row(children: [const Icon(Icons.manage_search_rounded, color: Color(0xffc8b7ff)), const SizedBox(width: 10), Expanded(child: Text(artifact['title']?.toString() ?? 'Analytical artifact', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))), IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close))]),
          const SizedBox(height: 16),
          _inspectBlock('IDENTITY', {'kind': artifact['kind'], 'artifact_id': artifact['artifact_id'], 'version': artifact['version'], 'branch_id': artifact['branch_id']}),
          _inspectBlock('CONTENT', artifact['content'] is Map ? Map<String, dynamic>.from(artifact['content']) : {'value': artifact['content']}),
          _inspectBlock('LINEAGE', lineage),
          _inspectBlock('PROVENANCE', provenance),
        ]),
      ),
    );
  }

  Widget _inspectBlock(String title, Map<String, dynamic> value) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: S7GlassPanel(title: title, accent: const Color(0xffc8b7ff), child: SelectableText(const JsonEncoder.withIndent('  ').convert(value), style: const TextStyle(fontSize: 8, height: 1.55, color: Colors.white60, fontFamily: 'monospace'))));
  }

  Widget _errorBanner() {
    return Positioned(left: 235, right: 28, bottom: 14, child: Material(color: const Color(0xff381c29).withValues(alpha: .94), borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), child: Row(children: [const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xffffa7b9)), const SizedBox(width: 9), Expanded(child: Text(error!, style: const TextStyle(fontSize: 8, color: Colors.white70))), IconButton(onPressed: () => setState(() => error = null), icon: const Icon(Icons.close, size: 15, color: Colors.white54))]))));
  }

  Widget _inspectButton(Map<String, dynamic> artifact) => _artifactTile(artifact);

  List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) return [];
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  IconData _artifactIcon(String kind) {
    switch (kind) {
      case 'hypothesis': return Icons.account_tree_rounded;
      case 'evaluation': return Icons.fact_check_rounded;
      case 'comparison': return Icons.compare_arrows_rounded;
      case 'objection': return Icons.gavel_rounded;
      case 'limitation': return Icons.warning_amber_rounded;
      case 'result': return Icons.task_alt_rounded;
      case 'human_intervention': return Icons.pan_tool_alt_rounded;
      case 'capability_plan': return Icons.hub_rounded;
      default: return Icons.description_outlined;
    }
  }
}

class _HumanMarker extends StatelessWidget {
  const _HumanMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xff0b0e18).withValues(alpha: .84), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: .10))),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.person_outline_rounded, size: 13, color: Colors.white54), SizedBox(width: 6), Text('HUMAN INSPECTION', style: TextStyle(fontSize: 7, letterSpacing: 1.2, color: Colors.white45, fontWeight: FontWeight.w800))]),
    );
  }
}
