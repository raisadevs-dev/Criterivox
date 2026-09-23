import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 's7_visuals.dart';
import 's7_functional_layer.dart';

class S7EnvironmentPage extends StatefulWidget {
  /// S7 is a system-owned reasoning environment. Human task/data intake
  /// happens in Human Residence; this page only observes the resulting session
  /// and exposes bounded human intervention controls.
  final String? sessionId;

  const S7EnvironmentPage({super.key, this.sessionId});

  @override
  State<S7EnvironmentPage> createState() => _S7EnvironmentPageState();
}

class _S7EnvironmentPageState extends State<S7EnvironmentPage>
    with SingleTickerProviderStateMixin {
  static const api = 'http://127.0.0.1:8017/api/s7';

  String room = 'collaboration';
  Map<String, dynamic>? session;
  Map<String, dynamic>? selected;
  String? error;
  bool busy = false;

  late final AnimationController motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  // No direct task/context controllers live here. Intake belongs to Human Residence.

  /*
  "observations": [
    "Signal A increased after event X.",
    "Signal A returned toward baseline when event X stopped.",
    "An independent measurement showed a weaker version of the same pattern."
  ],
  "source": "synthetic S7 research fixture"
}''',
  );

  @override
  void initState() {
    super.initState();
    if (widget.sessionId != null && widget.sessionId!.trim().isNotEmpty) {
      _loadSession(widget.sessionId!.trim());
    }
  }

  Future<void> _loadSession(String sessionId) async {
    try {
      final response = await http.get(Uri.parse('$api/sessions/$sessionId'));
      if (!mounted) return;
      final body = jsonDecode(response.body);
      if (response.statusCode >= 400 || body is! Map) {
        setState(() => error = body is Map ? body['error']?.toString() : 'Unable to load reasoning session.');
        return;
      }
      setState(() => session = Map<String, dynamic>.from(body));
      _connectLive(sessionId);
    } catch (e) {
      if (mounted) setState(() => error = _errorText(e));
    }
  }

  void _connectLive(String sessionId) {
    // Live transport is intentionally observational here. Human commands remain
    // bounded interventions against an already-created Residence-originated task.
  }

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> list(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList();
  }

  Map<String, dynamic> contextValue() {
    final raw = contextText.text.trim();

    if (raw.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final value = jsonDecode(raw);

      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    } on FormatException {
      // Plain text is accepted as a structured description at the boundary.
    }

    return <String, dynamic>{'description': raw};
  }

  Future<void> run() async {
    setState(() {
      busy = true;
      error = null;
      selected = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$api/sessions'),
        headers: const {
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'task': task.text.trim(),
          'context': contextValue(),
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 400) {
        throw Exception(
          body is Map ? body['error'] : 'S7 request failed',
        );
      }

      if (body is! Map) {
        throw Exception('S7 returned an invalid session.');
      }

      setState(() {
        session = Map<String, dynamic>.from(body);
      });
    } catch (e) {
      setState(() {
        error = _errorText(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  String _errorText(Object error) {
    final text = error.toString();

    if (text.contains('ClientException')) {
      return 'S7 backend unreachable at 127.0.0.1:8017. Check the launcher/runtime terminal.';
    }

    return text.replaceFirst('Exception: ', '');
  }

  Map<String, dynamic> characterState(String id) {
    final states = session?['character_states'];
    final value = states is Map ? states[id] : null;

    if (value is Map) {
      final raw = Map<String, dynamic>.from(value);
      return S7CharacterStateResolver.resolve(id, raw);
    }

    return <String, dynamic>{
      'identity': id.toUpperCase(),
      'state': 'idle',
      'role': id == 'vivren'
          ? 'critical intelligence'
          : 'hypothesis exploration',
    };
  }

  void select(Map<String, dynamic> artifact) {
    setState(() {
      selected = artifact;
    });

    inspect(artifact);
  }

  Future<void> inspect(Map<String, dynamic> artifact) async {
    final sid = session?['session_id']?.toString();
    final aid = artifact['artifact_id']?.toString();

    if (sid == null || aid == null) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$api/sessions/$sid/artifacts/$aid/lineage'),
      );

      if (response.statusCode < 400) {
        final body = jsonDecode(response.body);

        if (body is Map) {
          _showInspection(
            Map<String, dynamic>.from(body),
          );
          return;
        }
      }
    } catch (_) {
      // Local snapshot remains available for inspection.
    }

    _showInspection({
      'artifact': artifact,
      'lineage': <String, dynamic>{},
      'provenance': <String, dynamic>{},
    });
  }

  void _showInspection(Map<String, dynamic> body) {
    final rawArtifact = body['artifact'];

    final artifact = rawArtifact is Map
        ? Map<String, dynamic>.from(rawArtifact)
        : selected ?? <String, dynamic>{};

    final lineage = body['lineage'] is Map
        ? Map<String, dynamic>.from(body['lineage'])
        : <String, dynamic>{};

    final provenance = body['provenance'] is Map
        ? Map<String, dynamic>.from(body['provenance'])
        : <String, dynamic>{};

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xff080b14),
      isScrollControlled: true,
      builder: (sheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .68,
        minChildSize: .38,
        maxChildSize: .94,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(22),
          children: [
            Row(
              children: [
                const Icon(
                  Icons.manage_search_rounded,
                  color: Color(0xffc8b7ff),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    artifact['title']?.toString() ??
                        'Analytical artifact',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(sheet),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _inspectBlock(
              'IDENTITY',
              {
                'kind': artifact['kind'],
                'artifact_id': artifact['artifact_id'],
                'version': artifact['version'],
                'branch_id': artifact['branch_id'],
              },
            ),
            _inspectBlock(
              'CONTENT',
              artifact['content'] is Map
                  ? Map<String, dynamic>.from(
                      artifact['content'],
                    )
                  : {
                      'value': artifact['content'],
                    },
            ),
            _inspectBlock('LINEAGE', lineage),
            _inspectBlock('PROVENANCE', provenance),
          ],
        ),
      ),
    );
  }

  Widget _inspectBlock(
    String title,
    Map<String, dynamic> value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: S7GlassPanel(
        title: title,
        accent: const Color(0xffc8b7ff),
        child: SelectableText(
          const JsonEncoder.withIndent('  ').convert(value),
          style: const TextStyle(
            fontSize: 8,
            height: 1.5,
            color: Colors.white60,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Future<void> intervention(
    String action, {
    String instruction = '',
  }) async {
    final sid = session?['session_id']?.toString();
    final aid = selected?['artifact_id']?.toString();

    if (sid == null || aid == null) {
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$api/sessions/$sid/intervene'),
        headers: const {
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'artifact_id': aid,
          'action': action,
          'instruction': instruction,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 400) {
        throw Exception(
          body is Map
              ? body['error']
              : 'S7 intervention failed',
        );
      }

      if (body is! Map) {
        throw Exception('S7 returned an invalid session.');
      }

      setState(() {
        session = Map<String, dynamic>.from(body);
      });
    } catch (e) {
      setState(() {
        error = _errorText(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> challenge() async {
    final controller = TextEditingController();

    final text = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: const Color(0xff111525),
        title: const Text('Challenge analytical object'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText:
                'State the objection or alternative context.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialog,
              controller.text.trim(),
            ),
            child: const Text('CREATE BRANCH'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (text != null && text.isNotEmpty) {
      await intervention(
        'challenge',
        instruction: text,
      );
    }
  }

  Future<void> requestContext() async {
    final controller = TextEditingController();

    final text = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: const Color(0xff111525),
        title: const Text('Request additional context'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText:
                'Describe the information required before continuing.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialog,
              controller.text.trim(),
            ),
            child: const Text('REQUEST'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (text != null && text.isNotEmpty) {
      await intervention(
        'request_context',
        instruction: text,
      );
    }
  }

  void preset(String id) {
    switch (id) {
      case 'normal':
        task.text =
            'Compare two possible explanations for the supplied observations and identify uncertainty and limitations.';
        contextText.text = '''{
  "observations": [
    "Signal A increased after event X.",
    "Signal A returned toward baseline when event X stopped.",
    "An independent measurement showed a weaker version of the same pattern."
  ],
  "source": "synthetic S7 research fixture"
}''';
        break;

      case 'competing':
        task.text =
            'Explore competing explanations for the observation and compare the candidate reasoning paths.';
        contextText.text = '''{
  "observations": [
    "The observed change follows event X.",
    "The same change can also be explained by background condition Y."
  ],
  "candidate_hypotheses": [
    "event X is causal",
    "condition Y is causal"
  ],
  "source": "synthetic competing-hypothesis fixture"
}''';
        break;

      case 'contradiction':
        task.text =
            'Evaluate the observation while preserving contradictory evidence and explicitly reporting unresolved disagreement.';
        contextText.text = '''{
  "observations": [
    "Measurement A supports explanation P.",
    "Measurement B conflicts with explanation P.",
    "Measurement C is inconclusive."
  ],
  "contradictions": [
    "A conflicts with B"
  ],
  "source": "synthetic contradiction fixture"
}''';
        break;

      case 'insufficient':
        task.text =
            'Determine whether the supplied information is sufficient to establish a bounded analytical conclusion.';
        contextText.clear();
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
    final artifacts = list(session?['artifacts']);

    return Scaffold(
      backgroundColor: const Color(0xff03050b),
      body: AnimatedBuilder(
        animation: motion,
        builder: (_, __) => Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: S7BureauBackdrop(
                  progress: motion.value,
                  room: room,
                ),
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  _rail(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, constraints) {
                        final compact =
                            constraints.maxWidth < 980;

                        return SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            compact ? 14 : 26,
                            20,
                            compact ? 14 : 26,
                            24,
                          ),
                          child: room == 'collaboration'
                              ? _collaboration(
                                  artifacts,
                                  compact,
                                )
                              : _chamber(
                                  artifacts,
                                  compact,
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (busy)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  minHeight: 2,
                ),
              ),
            if (error != null) _errorBanner(),
            Positioned(
              right: 18,
              bottom: 18,
              child: S7FunctionalDock(
                room: room,
                artifacts: artifacts,
                onSelectArtifact: select,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rail() {
    return Container(
      width: 214,
      color: const Color(0xff050712).withValues(alpha: .78),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          22,
          16,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'REASONING',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.5,
                color: Colors.white38,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'RESEARCH BUREAU',
              style: TextStyle(
                fontSize: 17,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'S7 · standalone intelligence environment',
              style: TextStyle(
                fontSize: 8,
                color: Colors.white30,
              ),
            ),
            const SizedBox(height: 28),
            _nav(
              'collaboration',
              Icons.groups_rounded,
              'COLLABORATION ROOM',
              'shared intelligence',
            ),
            _nav(
              'vivren',
              Icons.visibility_rounded,
              'CRITICAL INTELLIGENCE CHAMBER',
              'Vivren · critical inspection',
            ),
            _nav(
              'tarkis',
              Icons.account_tree_rounded,
              'HYPOTHESIS EXPLORATION CHAMBER',
              'Tarkis · hypothesis exploration',
            ),
            const Spacer(),
            const S7SectionLabel(
              'Bureau status',
              accent: Colors.white54,
            ),
            const SizedBox(height: 6),
            Text(
              session?['status']?.toString() ?? 'READY',
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.4,
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nav(
    String id,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final active = room == id;
    final accent = id == 'tarkis'
        ? const Color(0xffffb463)
        : const Color(0xffb59cff);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: active
            ? Colors.white.withValues(alpha: .075)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              room = id;
              selected = null;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: active
                      ? accent
                      : Colors.white30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .7,
                          color: active
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.white.withValues(
                            alpha: .25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (active)
                  Icon(
                    Icons.chevron_right,
                    size: 15,
                    color: accent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _collaboration(
    List<Map<String, dynamic>> artifacts,
    bool compact,
  ) {
    final vivren = characterState('vivren');
    final tarkis = characterState('tarkis');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(
          'REASONING RESEARCH BUREAU',
          'COLLABORATION ROOM',
          'Shared intelligence, competing perspectives and human challenge.',
          const Color(0xffc8b7ff),
        ),
        const SizedBox(height: 14),
        _requestPanel(),
        const SizedBox(height: 10),
        _fixtureStrip(),
        const SizedBox(height: 14),
        if (compact) ...[
          SizedBox(
            height: 420,
            child: _sceneCard(
              vivren,
              tarkis,
              true,
            ),
          ),
          const SizedBox(height: 10),
          _analysisPanel(artifacts),
          const SizedBox(height: 10),
          _attentionPanel(artifacts),
        ] else
          SizedBox(
            height: 570,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _sceneCard(
                    vivren,
                    tarkis,
                    false,
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  width: 310,
                  child: _analysisPanel(artifacts),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  width: 280,
                  child: _attentionPanel(artifacts),
                ),
                if (selected != null)
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: _selectedStrip(),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _sceneCard(
    Map<String, dynamic> vivren,
    Map<String, dynamic> tarkis,
    bool compact,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: .08),
        ),
        color: const Color(0xff080b16)
            .withValues(alpha: .40),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            top: 22,
            left: 0,
            right: 0,
            child: Center(
              child: S7SectionLabel(
                'SHARED INTELLIGENCE TABLE',
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: _sharedCore(),
            ),
          ),
          Positioned(
            left: compact ? 4 : 42,
            bottom: 14,
            child: _characterColumn(
              'Vivren',
              vivren,
              compact,
            ),
          ),
          Positioned(
            right: compact ? 4 : 42,
            bottom: 14,
            child: _characterColumn(
              'Tarkis',
              tarkis,
              compact,
            ),
          ),
          const Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: _HumanMarker(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _characterColumn(
    String id,
    Map<String, dynamic> state,
    bool compact,
  ) {
    final accent = id == 'Vivren'
        ? const Color(0xffad92ff)
        : const Color(0xffffb463);

    return Column(
      children: [
        S7BureauCharacter(
          identity: id,
          state: state['state']?.toString() ?? 'idle',
          progress: motion.value,
          scale: compact ? .60 : .78,
        ),
        Text(
          id.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w900,
            color: Colors.white70,
          ),
        ),
        Text(
          state['state']?.toString().toUpperCase() ??
              'IDLE',
          style: TextStyle(
            fontSize: 7,
            letterSpacing: 1.1,
            color: accent,
          ),
        ),
      ],
    );
  }

  Widget _sharedCore() {
    return Container(
      width: 230,
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xff101426)
            .withValues(alpha: .72),
        borderRadius: BorderRadius.circular(80),
        border: Border.all(
          color: const Color(0xffc8b7ff)
              .withValues(alpha: .18),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff9d86ff)
                .withValues(alpha: .08),
            blurRadius: 35,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hub_rounded,
            size: 26,
            color: session == null
                ? Colors.white24
                : const Color(0xffc8b7ff),
          ),
          const SizedBox(height: 7),
          const Text(
            'SHARED WORK',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            session == null
                ? 'awaiting analytical request'
                : 'artifacts · branches · evaluation',
            style: const TextStyle(
              fontSize: 7,
              color: Colors.white30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisPanel(
    List<Map<String, dynamic>> artifacts,
  ) {
    return S7GlassPanel(
      title: 'LIVE ANALYTICAL ACTIVITY',
      accent: const Color(0xffc8b7ff),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              S7Metric(
                'Artifacts',
                '${artifacts.length}',
                accent: const Color(0xffc8b7ff),
              ),
              S7Metric(
                'Branches',
                '${list(session?['branches']).length}',
                accent: const Color(0xffc8b7ff),
              ),
              S7Metric(
                'Interventions',
                '${list(session?['interventions']).length}',
                accent: const Color(0xffc8b7ff),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white10),
          if (artifacts.isEmpty)
            const Text(
              'No analytical artifacts yet. Run a task to populate the Bureau.',
              style: TextStyle(
                fontSize: 8,
                color: Colors.white30,
              ),
            )
          else
            ...artifacts.take(6).map(_artifactTile),
        ],
      ),
    );
  }

  Widget _attentionPanel(
    List<Map<String, dynamic>> artifacts,
  ) {
    final attention = artifacts
        .where(
          (a) =>
              a['kind'] == 'limitation' ||
              a['kind'] == 'objection',
        )
        .length;

    return S7GlassPanel(
      title: 'HUMAN ATTENTION',
      accent: const Color(0xffffc77d),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _stateLine(
            'SESSION',
            session?['status']?.toString() ?? 'READY',
            const Color(0xffc8b7ff),
          ),
          _stateLine(
            'BRANCH',
            session?['branch_id']?.toString() ?? 'main',
            const Color(0xffffb463),
          ),
          _stateLine(
            'LIMITATIONS / OBJECTIONS',
            '$attention',
            const Color(0xffffc77d),
          ),
          const SizedBox(height: 8),
          Text(
            selected == null
                ? 'Select an analytical object to inspect or intervene.'
                : 'Selected: ${selected!['title'] ?? selected!['kind']}',
            style: const TextStyle(
              fontSize: 8,
              color: Colors.white30,
            ),
          ),
          if (selected != null) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                _actionButton(
                  'CHALLENGE',
                  Icons.gavel_rounded,
                  challenge,
                ),
                _actionButton(
                  'REQUEST CONTEXT',
                  Icons.add_comment_rounded,
                  requestContext,
                ),
                _actionButton(
                  'REJECT',
                  Icons.block_rounded,
                  () => intervention('reject'),
                ),
                _actionButton(
                  'CONTINUE',
                  Icons.play_arrow_rounded,
                  () => intervention('continue'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _selectedStrip() {
    return Material(
      color: const Color(0xff0b0f1c)
          .withValues(alpha: .94),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => inspect(selected!),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.manage_search_rounded,
                size: 15,
                color: Color(0xffc8b7ff),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selected!['title']?.toString() ??
                      'Selected analytical object',
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white70,
                  ),
                ),
              ),
              const Text(
                'DEEP INSPECTION',
                style: TextStyle(
                  fontSize: 7,
                  letterSpacing: 1.1,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _artifactTile(
    Map<String, dynamic> artifact,
  ) {
    final kind =
        artifact['kind']?.toString() ?? 'artifact';

    final accent = kind == 'hypothesis' ||
            kind == 'comparison'
        ? const Color(0xffffb463)
        : const Color(0xffc8b7ff);

    final active =
        selected?['artifact_id'] ==
            artifact['artifact_id'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active
            ? accent.withValues(alpha: .10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => select(artifact),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Row(
              children: [
                Icon(
                  _icon(kind),
                  size: 13,
                  color: accent,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    artifact['title']?.toString() ??
                        kind,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white60,
                    ),
                  ),
                ),
                Text(
                  'v${artifact['version'] ?? 1}',
                  style: const TextStyle(
                    fontSize: 7,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chamber(
    List<Map<String, dynamic>> artifacts,
    bool compact,
  ) {
    final vivren = room == 'vivren';
    final accent = vivren
        ? const Color(0xffad92ff)
        : const Color(0xffffb463);

    final identity = vivren ? 'Vivren' : 'Tarkis';

    final filtered = artifacts
        .where(
          (a) => vivren
              ? [
                  'evaluation',
                  'objection',
                  'limitation',
                  'reasoning',
                ].contains(a['kind'])
              : [
                  'hypothesis',
                  'comparison',
                  'reasoning',
                  'result',
                ].contains(a['kind']),
        )
        .toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        _header(
          'REASONING RESEARCH BUREAU',
          vivren
              ? 'CRITICAL INTELLIGENCE CHAMBER'
              : 'HYPOTHESIS EXPLORATION CHAMBER',
          vivren
              ? 'Inspect assumptions, evidence, objections and epistemic limits.'
              : 'Explore alternatives, branches, counterfactuals and refinement.',
          accent,
        ),
        const SizedBox(height: 14),
        if (compact) ...[
          _characterStage(
            identity,
            accent,
            true,
          ),
          const SizedBox(height: 10),
          _roomPanel(
            filtered,
            vivren,
            accent,
          ),
        ] else
          SizedBox(
            height: 620,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _characterStage(
                    identity,
                    accent,
                    false,
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  width: 350,
                  child: _roomPanel(
                    filtered,
                    vivren,
                    accent,
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 14,
                  width: 330,
                  child: _chamberStatus(
                    artifacts,
                    accent,
                  ),
                ),
                if (selected != null)
                  Positioned(
                    left: 14,
                    right: 365,
                    bottom: 14,
                    child: _selectedStrip(),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _characterStage(
    String identity,
    Color accent,
    bool compact,
  ) {
    final state =
        characterState(identity.toLowerCase());

    return Container(
      height: compact ? 430 : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xff090c16)
            .withValues(alpha: .48),
        border: Border.all(
          color: accent.withValues(alpha: .13),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: S7SectionLabel(
                '${identity.toUpperCase()} · ACTIVE RESEARCH STATION',
                accent: accent,
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: S7BureauCharacter(
                identity: identity,
                state:
                    state['state']?.toString() ??
                        'idle',
                progress: motion.value,
                scale: compact ? .90 : 1.15,
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                state['state']?.toString()
                        .toUpperCase() ??
                    'IDLE',
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.3,
                  color: accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomPanel(
    List<Map<String, dynamic>> artifacts,
    bool vivren,
    Color accent,
  ) {
    return S7GlassPanel(
      title: vivren
          ? 'CRITICAL FINDINGS'
          : 'HYPOTHESIS FIELD',
      accent: accent,
      child: artifacts.isEmpty
          ? Text(
              vivren
                  ? 'No critical analytical objects yet.'
                  : 'No hypothesis objects yet. Run a task from the Collaboration Room.',
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white30,
              ),
            )
          : Column(
              children: artifacts
                  .take(9)
                  .map(_artifactTile)
                  .toList(),
            ),
    );
  }

  Widget _chamberStatus(
    List<Map<String, dynamic>> artifacts,
    Color accent,
  ) {
    return S7GlassPanel(
      title: 'INSPECTION STATE',
      accent: accent,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          S7Metric(
            'Artifacts',
            '${artifacts.length}',
            accent: accent,
          ),
          S7Metric(
            'Branch',
            session?['branch_id']?.toString() ??
                'main',
            accent: accent,
          ),
          S7Metric(
            'Status',
            session?['status']?.toString() ??
                'READY',
            accent: accent,
          ),
        ],
      ),
    );
  }

  Widget _requestPanel() {
    return S7GlassPanel(
      title: 'NEW ANALYTICAL REQUEST',
      accent: const Color(0xffc8b7ff),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: task,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Task',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: contextText,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText:
                        'Structured context / internal Criterivox data',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: busy ? null : run,
                icon: const Icon(
                  Icons.play_arrow_rounded,
                ),
                label: const Text('RUN BUREAU'),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Boundary: human or upstream structured request → S7. Characters visualize authoritative state; mechanisms compute.',
              style: TextStyle(
                fontSize: 7,
                color: Colors.white30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fixtureStrip() {
    return S7GlassPanel(
      title: 'TEST CASES · LOCAL FIXTURE LAB',
      accent: const Color(0xffffc77d),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _presetButton('NORMAL', 'normal'),
          _presetButton('COMPETING', 'competing'),
          _presetButton(
            'CONTRADICTION',
            'contradiction',
          ),
          _presetButton(
            'INSUFFICIENT CONTEXT',
            'insufficient',
          ),
        ],
      ),
    );
  }

  Widget _presetButton(
    String label,
    String id,
  ) {
    return OutlinedButton.icon(
      onPressed: busy ? null : () => preset(id),
      icon: const Icon(
        Icons.science_outlined,
        size: 12,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 7,
          letterSpacing: .7,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white60,
        side: BorderSide(
          color: Colors.white.withValues(
            alpha: .10,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 7,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _header(
    String bureau,
    String title,
    String subtitle,
    Color accent,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 50,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(
                  alpha: .35,
                ),
                blurRadius: 18,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                bureau,
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 2.2,
                  color: Colors.white38,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  letterSpacing: .4,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stateLine(
    String label,
    String value,
    Color accent,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 7,
              letterSpacing: .8,
              color: Colors.white30,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white60,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    VoidCallback action,
  ) {
    return OutlinedButton.icon(
      onPressed: busy ? null : action,
      icon: Icon(
        icon,
        size: 11,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 6.2,
          letterSpacing: .4,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 5,
        ),
        foregroundColor: Colors.white60,
        side: BorderSide(
          color: Colors.white.withValues(
            alpha: .10,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    );
  }

  Widget _errorBanner() {
    return Positioned(
      left: 230,
      right: 26,
      bottom: 14,
      child: Material(
        color: const Color(0xff381c29)
            .withValues(alpha: .96),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 15,
                color: Color(0xffffa7b9),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error!,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white70,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    error = null;
                  });
                },
                icon: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(String kind) {
    switch (kind) {
      case 'hypothesis':
        return Icons.account_tree_rounded;
      case 'evaluation':
        return Icons.fact_check_rounded;
      case 'comparison':
        return Icons.compare_arrows_rounded;
      case 'objection':
        return Icons.gavel_rounded;
      case 'limitation':
        return Icons.warning_amber_rounded;
      case 'result':
        return Icons.task_alt_rounded;
      case 'human_intervention':
        return Icons.pan_tool_alt_rounded;
      case 'capability_plan':
        return Icons.hub_rounded;
      default:
        return Icons.description_outlined;
    }
  }
}

class _HumanMarker extends StatelessWidget {
  const _HumanMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff0b0e18)
            .withValues(alpha: .88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: .10,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person_outline_rounded,
            size: 13,
            color: Colors.white54,
          ),
          const SizedBox(width: 6),
          Text(
            'HUMAN INSPECTION',
            style: TextStyle(
              fontSize: 7,
              letterSpacing: 1.1,
              color: Colors.white.withValues(
                alpha: .45,
              ),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}