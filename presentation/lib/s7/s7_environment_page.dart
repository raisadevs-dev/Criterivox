import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class S7EnvironmentPage extends StatefulWidget {
  const S7EnvironmentPage({super.key});

  @override
  State<S7EnvironmentPage> createState() => _S7EnvironmentPageState();
}

class _S7EnvironmentPageState extends State<S7EnvironmentPage>
    with SingleTickerProviderStateMixin {
  String room = 'collaboration';
  Map<String, dynamic>? session;
  Map<String, dynamic>? selected;
  bool busy = false;
  String? error;

  late final AnimationController motion =
      AnimationController(
        vsync: this,
        duration: const Duration(seconds: 14),
      )..repeat();

  final task = TextEditingController(
    text: 'Compare two possible explanations for the supplied observation.',
  );

  final contextText = TextEditingController(
    text: 'Local synthetic research context supplied by the human.',
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
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8017/api/s7/sessions'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'task': task.text,
          'context': {
            'description': contextText.text,
          },
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 400) {
        throw Exception(body['error'] ?? 'S7 request failed');
      }

      setState(() {
        session = Map<String, dynamic>.from(body);
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> intervene(
    String action, {
    String instruction = '',
  }) async {
    final currentSession = session;
    final currentSelected = selected;

    if (currentSession == null || currentSelected == null) {
      return;
    }

    final sessionId = currentSession['session_id']?.toString();
    final artifactId = currentSelected['artifact_id']?.toString();

    if (sessionId == null || artifactId == null) {
      setState(() {
        error = 'Selected S7 artifact is missing its identifier.';
      });
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'http://127.0.0.1:8017/api/s7/sessions/'
          '$sessionId/intervene',
        ),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'artifact_id': artifactId,
          'action': action,
          'instruction': instruction,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 400) {
        throw Exception(body['error'] ?? 'S7 intervention failed');
      }

      setState(() {
        session = Map<String, dynamic>.from(body);
      });
    } catch (e) {
      setState(() {
        error = '$e';
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
    final currentSelected = selected;

    if (currentSelected == null) {
      return;
    }

    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Challenge analytical object'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'State the objection or alternative context.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim().isNotEmpty,
                );
              },
              child: const Text('CREATE BRANCH'),
            ),
          ],
        );
      },
    );

    final instruction = controller.text.trim();
    controller.dispose();

    if (confirmed == true && instruction.isNotEmpty) {
      await intervene(
        'challenge',
        instruction: instruction,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final artifacts =
        (session?['artifacts'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: const Color(0xff04060d),
      body: AnimatedBuilder(
        animation: motion,
        builder: (context, child) {
          return Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _Backdrop(
                  motion.value,
                  room,
                ),
              ),
              SafeArea(
                child: Row(
                  children: [
                    _rail(),
                    Expanded(
                      child: _body(artifacts),
                    ),
                  ],
                ),
              ),
              if (busy)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
              if (error != null)
                Positioned(
                  bottom: 12,
                  left: 230,
                  right: 30,
                  child: _error(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _error() {
    return Material(
      color: Colors.red.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber,
              size: 15,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error ?? 'Unknown error',
                style: const TextStyle(fontSize: 9),
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
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rail() {
    final status = session?['status']?.toString();

    return SizedBox(
      width: 205,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'S7',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'REASONING RESEARCH BUREAU',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.5,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 28),
            _nav(
              'collaboration',
              Icons.groups_rounded,
              'Collaboration Room',
              'shared intelligence',
            ),
            _nav(
              'vivren',
              Icons.visibility_rounded,
              'Critical Intelligence',
              'Vivren',
            ),
            _nav(
              'tarkis',
              Icons.account_tree_rounded,
              'Hypothesis Exploration',
              'Tarkis',
            ),
            const Spacer(),
            Text(
              status == null ? 'READY' : status.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white38,
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
    String sub,
  ) {
    final active = room == id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: active
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () {
            setState(() {
              room = id;
              selected = null;
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: active
                      ? const Color(0xffc8b7ff)
                      : Colors.white38,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
                      Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(List<Map<String, dynamic>> artifacts) {
    if (room == 'vivren') {
      return _chamber(
        'CRITICAL INTELLIGENCE CHAMBER',
        'VIVREN',
        'Inspect assumptions, evidence, objections and epistemic limits.',
        const Color(0xffc4b2ff),
        artifacts
            .where(
              (artifact) => [
                'evaluation',
                'limitation',
                'objection',
              ].contains(artifact['kind']),
            )
            .toList(),
      );
    }

    if (room == 'tarkis') {
      return _chamber(
        'HYPOTHESIS EXPLORATION CHAMBER',
        'TARKIS',
        'Explore alternatives, branches, counterfactuals and refinement.',
        const Color(0xffffbd78),
        artifacts
            .where(
              (artifact) => [
                'hypothesis',
                'comparison',
                'reasoning',
                'result',
              ].contains(artifact['kind']),
            )
            .toList(),
      );
    }

    return _collaboration(artifacts);
  }

  Widget _collaboration(
    List<Map<String, dynamic>> artifacts,
  ) {
    return _frame(
      'COLLABORATION ROOM',
      'VIVREN ↔ SHARED WORK ↔ TARKIS ↕ HUMAN',
      const Color(0xffc8b7ff),
      Column(
        children: [
          _request(),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _panel(
                    'REASONING DEPENDENCY MAP',
                    _graph(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _panel(
                    'CURRENT INTELLIGENCE',
                    ListView(
                      children: [
                        _stat('Artifacts', artifacts.length),
                        _stat(
                          'Branches',
                          ((session?['branches'] as List?)?.length ?? 0),
                        ),
                        _stat(
                          'Interventions',
                          ((session?['interventions'] as List?)?.length ??
                              0),
                        ),
                        const Divider(
                          color: Colors.white10,
                        ),
                        ...artifacts.take(10).map(_compact),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _request() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
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
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: contextText,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Structured context',
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: busy ? null : run,
            icon: const Icon(Icons.play_arrow),
            label: const Text('RUN'),
          ),
        ],
      ),
    );
  }

  Widget _graph() {
    final nodes =
        (session?['reasoning_graph']?['nodes'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];

    if (nodes.isEmpty) {
      return const _Empty(
        'Run a request to populate the live reasoning map.',
      );
    }

    return ListView(
      children: [
        for (final node in nodes) _graphNode(node),
      ],
    );
  }

  Widget _graphNode(Map<String, dynamic> node) {
    return InkWell(
      onTap: () {
        _select(node);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.radio_button_unchecked,
              size: 14,
              color: Colors.white38,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                node['label']?.toString() ??
                    node['title']?.toString() ??
                    'Reasoning node',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              node['stage']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chamber(
    String title,
    String character,
    String sub,
    Color accent,
    List<Map<String, dynamic>> artifacts,
  ) {
    return _frame(
      title,
      '$character · $sub',
      accent,
      Row(
        children: [
          Expanded(
            flex: 2,
            child: _panel(
              'CANONICAL PARTICIPANT',
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _orb(character, accent),
                    const SizedBox(height: 12),
                    Text(
                      character,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      _characterState(character),
                      style: TextStyle(
                        fontSize: 8,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: _panel(
              character == 'VIVREN'
                  ? 'CRITICAL FINDINGS'
                  : 'HYPOTHESIS FIELD',
              artifacts.isEmpty
                  ? const _Empty(
                      'No matching analytical objects yet.',
                    )
                  : ListView(
                      children: [
                        for (final artifact in artifacts)
                          _object(artifact, accent),
                      ],
                    ),
            ),
          ),
          if (selected != null) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _panel(
                'DEEP INSPECTION',
                _inspection(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _characterState(String character) {
    final states = session?['character_states'];

    if (states is! Map) {
      return 'idle';
    }

    final state = states[character.toLowerCase()];

    if (state is! Map) {
      return 'idle';
    }

    return state['state']?.toString() ?? 'idle';
  }

  Widget _orb(
    String who,
    Color accent,
  ) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accent.withValues(alpha: 0.32),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 36,
          ),
        ],
      ),
      child: Icon(
        who == 'VIVREN'
            ? Icons.visibility_rounded
            : Icons.account_tree_rounded,
        size: 43,
        color: accent,
      ),
    );
  }

  Widget _object(
    Map<String, dynamic> artifact,
    Color accent,
  ) {
    return InkWell(
      onTap: () {
        _select(artifact);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    artifact['title']?.toString() ??
                        'Analytical object',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'v${artifact['version'] ?? 1}',
                  style: TextStyle(
                    fontSize: 8,
                    color: accent,
                  ),
                ),
              ],
            ),
            Text(
              '${artifact['kind']} · branch ${artifact['branch_id']}',
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white30,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _json(artifact['content']),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inspection() {
    final currentSelected = selected;

    if (currentSelected == null) {
      return const _Empty(
        'Select an analytical object for inspection.',
      );
    }

    final artifactId = currentSelected['artifact_id'];

    final lineage = session?['lineage'];
    final provenance = session?['provenance'];

    dynamic lineageEntry;
    dynamic provenanceEntry;

    if (lineage is Map) {
      lineageEntry = lineage[artifactId];
    }

    if (provenance is Map) {
      provenanceEntry = provenance[artifactId];
    }

    final parents =
        currentSelected['parent_ids'] is List
            ? (currentSelected['parent_ids'] as List)
                .map((value) => value.toString())
                .join(', ')
            : '';

    final children =
        lineageEntry is Map && lineageEntry['children'] is List
            ? (lineageEntry['children'] as List)
                .map((value) => value.toString())
                .join(', ')
            : '';

    return ListView(
      children: [
        Text(
          currentSelected['title']?.toString() ?? 'Artifact',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        _kv(
          'Kind',
          currentSelected['kind']?.toString() ?? '',
        ),
        _kv(
          'Version',
          '${currentSelected['version'] ?? ''}',
        ),
        _kv(
          'Branch',
          currentSelected['branch_id']?.toString() ?? '',
        ),
        _kv(
          'Parents',
          parents,
        ),
        _kv(
          'Children',
          children,
        ),
        const Divider(
          color: Colors.white10,
        ),
        const Text(
          'PROVENANCE',
          style: TextStyle(
            fontSize: 8,
            color: Colors.white38,
          ),
        ),
        Text(
          _json(provenanceEntry),
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'CONTENT',
          style: TextStyle(
            fontSize: 8,
            color: Colors.white38,
          ),
        ),
        Text(
          _json(currentSelected['content']),
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 12),
        _interventionBar(),
      ],
    );
  }

  Widget _interventionBar() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        OutlinedButton(
          onPressed: busy ? null : challenge,
          child: const Text(
            'CHALLENGE',
            style: TextStyle(fontSize: 8),
          ),
        ),
        OutlinedButton(
          onPressed: busy
              ? null
              : () {
                  intervene(
                    'request_context',
                    instruction:
                        'Supply additional structured context.',
                  );
                },
          child: const Text(
            'REQUEST CONTEXT',
            style: TextStyle(fontSize: 8),
          ),
        ),
        OutlinedButton(
          onPressed: busy
              ? null
              : () {
                  intervene(
                    'reject',
                    instruction: 'Human rejected this object.',
                  );
                },
          child: const Text(
            'REJECT',
            style: TextStyle(fontSize: 8),
          ),
        ),
        OutlinedButton(
          onPressed: busy
              ? null
              : () {
                  intervene('continue');
                },
          child: const Text(
            'CONTINUE',
            style: TextStyle(fontSize: 8),
          ),
        ),
      ],
    );
  }

  Widget _compact(Map<String, dynamic> artifact) {
    return ListTile(
      dense: true,
      onTap: () {
        _select(artifact);
      },
      title: Text(
        artifact['title']?.toString() ?? 'Artifact',
        style: const TextStyle(fontSize: 9),
      ),
      subtitle: Text(
        '${artifact['kind']} · ${artifact['branch_id']}',
        style: const TextStyle(
          fontSize: 8,
          color: Colors.white30,
        ),
      ),
    );
  }

  Widget _stat(
    String label,
    int value,
  ) {
    return ListTile(
      dense: true,
      leading: const Icon(
        Icons.data_object,
        size: 15,
        color: Colors.white30,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white54,
        ),
      ),
      trailing: Text(
        '$value',
        style: const TextStyle(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _kv(
    String key,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white30,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white60,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _json(dynamic value) {
    if (value is Map || value is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(value);
      } catch (_) {
        return value.toString();
      }
    }

    return value?.toString() ?? 'No content';
  }

  void _select(Map<String, dynamic> node) {
    final id = node['artifact_id'];

    final artifacts =
        (session?['artifacts'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];

    for (final artifact in artifacts) {
      if (artifact['artifact_id'] == id) {
        setState(() {
          selected = artifact;
        });
        return;
      }
    }

    setState(() {
      selected = node;
    });
  }

  Widget _frame(
    String title,
    String sub,
    Color accent,
    Widget child,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        6,
        8,
        24,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _panel(
    String title,
    Widget child,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 8,
              letterSpacing: 1.4,
              color: Colors.white38,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Flexible(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;

  const _Empty(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white30,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _Backdrop extends CustomPainter {
  final double t;
  final String room;

  _Backdrop(
    this.t,
    this.room,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Color base = room == 'vivren'
        ? const Color(0xff17102b)
        : room == 'tarkis'
            ? const Color(0xff24170d)
            : const Color(0xff10172b);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: 1.2,
          colors: [
            base,
            const Color(0xff04060d),
          ],
        ).createShader(
          Offset.zero & size,
        ),
    );

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06);

    for (var i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(
          (i * 91 + t * 20) % size.width,
          (i * 47 + t * 8) % size.height,
        ),
        1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _Backdrop oldDelegate,
  ) {
    return oldDelegate.t != t ||
        oldDelegate.room != room;
  }
}