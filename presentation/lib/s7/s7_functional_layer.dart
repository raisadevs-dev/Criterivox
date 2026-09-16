import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 's7_local_nlp.dart';
import 's7_nlp_debate_arena.dart';
import 's7_nlp_debate_arena.dart';

const _s7Violet = Color(0xffb59cff);
const _s7Amber = Color(0xffffb463);
const _s7Glass = Color(0xff111526);

/// Character-specific presentation state. The backend remains authoritative;
/// this layer translates backend states into distinct visual behavior without
/// changing the S7 API/session/intervention contract.
class S7CharacterStateResolver {
  const S7CharacterStateResolver._();

  static Map<String, dynamic> resolve(String identity, Map<String, dynamic> source) {
    final raw = (source['state'] ?? 'idle').toString().toLowerCase();
    final isVivren = identity.toLowerCase() == 'vivren';
    final mapped = isVivren ? _vivren(raw) : _tarkis(raw);
    return <String, dynamic>{
      ...source,
      'presentation_state': mapped.$1,
      'behavior': mapped.$2,
      'state': raw,
      'animation_state': mapped.$3,
      'state_machine': isVivren ? 'VivrenCriticalInspectionStateMachine' : 'TarkisHypothesisExplorationStateMachine',
    };
  }

  static (String, String, String) _vivren(String raw) {
    switch (raw) {
      case 'observing': return ('observing', 'scans context and compares evidence', 'focused');
      case 'inspecting': return ('inspecting', 'traces evidence and provenance', 'work');
      case 'thinking': return ('thinking', 'holds competing interpretations', 'focused');
      case 'critiquing': return ('critiquing', 'tests reasoning integrity and assumptions', 'communicate');
      case 'flagging': return ('flagging', 'raises a critical finding for review', 'handoff');
      case 'explaining': return ('explaining', 'makes the inspection path human-readable', 'communicate');
      case 'resolving': return ('resolving', 'tracks whether the contradiction is bounded', 'work');
      case 'complete': return ('complete', 'inspection is complete and preserved', 'focused');
      default: return ('idle', 'awaits analytical evidence', 'idle');
    }
  }

  static (String, String, String) _tarkis(String raw) {
    switch (raw) {
      case 'receiving': return ('receiving', 'absorbs a new observation or constraint', 'receive');
      case 'exploring': return ('exploring', 'searches the hypothesis field', 'focused');
      case 'generating': return ('generating', 'constructs candidate explanations', 'work');
      case 'branching': return ('branching', 'opens alternative reasoning paths', 'communicate');
      case 'comparing': return ('comparing', 'contrasts candidate hypotheses', 'focused');
      case 'testing': return ('testing', 'checks a hypothesis against available evidence', 'work');
      case 'reflecting': return ('reflecting', 'reviews what changed and why', 'focused');
      case 'refining': return ('refining', 'narrows or revises candidate paths', 'work');
      case 'presenting': return ('presenting', 'exposes the explored alternatives', 'communicate');
      default: return ('idle', 'awaits a hypothesis task', 'idle');
    }
  }
}

class S7FunctionalDock extends StatefulWidget {
  const S7FunctionalDock({
    super.key,
    required this.room,
    required this.artifacts,
    required this.onSelectArtifact,
  });

  final String room;
  final List<Map<String, dynamic>> artifacts;
  final ValueChanged<Map<String, dynamic>> onSelectArtifact;

  @override
  State<S7FunctionalDock> createState() => _S7FunctionalDockState();
}

class _S7FunctionalDockState extends State<S7FunctionalDock> {
  final List<S7FloatingVisualization> floating = <S7FloatingVisualization>[];
  bool expanded = true;

  Color get accent => widget.room == 'tarkis' ? _s7Amber : _s7Violet;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (expanded)
            Container(
              width: 310,
              margin: const EdgeInsets.only(bottom: 54, right: 2),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _s7Glass.withValues(alpha: .91),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accent.withValues(alpha: .24)),
                boxShadow: [BoxShadow(color: accent.withValues(alpha: .08), blurRadius: 28)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.hub_rounded, size: 17, color: accent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(widget.room == 'collaboration' ? 'ANALYTICAL OBJECTS' : widget.room == 'vivren' ? 'CRITICAL VISUALS' : 'HYPOTHESIS VISUALS', style: TextStyle(fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: .9)))),
                    IconButton(tooltip: 'Collapse', visualDensity: VisualDensity.compact, onPressed: () => setState(() => expanded = false), icon: const Icon(Icons.remove_rounded, size: 18, color: Colors.white54)),
                  ]),
                  const SizedBox(height: 5),
                  Text('Open an artifact as a traceable floating visualization. Source identity remains attached.', style: TextStyle(fontSize: 9, height: 1.4, color: Colors.white.withValues(alpha: .48))),
                  const SizedBox(height: 9),
                  if (widget.artifacts.isEmpty)
                    Text('Run an S7 session to populate analytical objects.', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: .42)))
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 210),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.artifacts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 5),
                        itemBuilder: (_, index) {
                          final artifact = widget.artifacts[index];
                          final kind = (artifact['kind'] ?? 'artifact').toString();
                          final title = (artifact['title'] ?? artifact['artifact_id'] ?? 'Analytical artifact').toString();
                          return _ArtifactAction(
                            title: title,
                            kind: kind,
                            accent: accent,
                            onInspect: () => widget.onSelectArtifact(artifact),
                            onVisualize: () => _addVisualization(artifact),
                          );
                        },
                      ),
                    ),
                  if (floating.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('OPEN FLOATING OBJECTS', style: TextStyle(fontSize: 8, letterSpacing: 1.3, fontWeight: FontWeight.w800, color: accent)),
                    const SizedBox(height: 5),
                    Wrap(spacing: 5, runSpacing: 5, children: floating.asMap().entries.map((entry) => ActionChip(label: Text('${entry.value.title} ${entry.key + 1}', style: const TextStyle(fontSize: 8)), onPressed: () => _open(entry.value), side: BorderSide(color: accent.withValues(alpha: .14)), backgroundColor: accent.withValues(alpha: .06))).toList()),
                  ],
                  const SizedBox(height: 8),
                  if (widget.room == 'collaboration')
                    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => _openDebate(context), icon: const Icon(Icons.forum_outlined, size: 16), label: const Text('OPEN DEBATE ARENA'))),
                ],
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.small(
              heroTag: 's7-functional-dock',
              backgroundColor: _s7Glass,
              foregroundColor: accent,
              onPressed: () => setState(() => expanded = !expanded),
              child: Icon(expanded ? Icons.close_fullscreen_rounded : Icons.hub_rounded),
            ),
          ),
        ],
      ),
    );
  }

  void _addVisualization(Map<String, dynamic> artifact) {
    final viz = S7VisualizationFactory.fromArtifact(artifact, widget.room);
    setState(() {
      if (!floating.any((v) => v.artifactId == viz.artifactId)) floating.add(viz);
    });
    _open(viz);
  }

  void _open(S7FloatingVisualization viz) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .56),
      builder: (_) => _FloatingVisualizationDialog(viz: viz, accent: accent),
    );
  }

  void _openDebate(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .68),
      builder: (_) => const S7NlpDebateArena(),
    );
  }
}

class _ArtifactAction extends StatelessWidget {
  const _ArtifactAction({required this.title, required this.kind, required this.accent, required this.onInspect, required this.onVisualize});
  final String title;
  final String kind;
  final Color accent;
  final VoidCallback onInspect;
  final VoidCallback onVisualize;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .025), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withValues(alpha: .06))),
    child: Row(children: [
      Container(width: 5, height: 26, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white70)), Text(kind.toUpperCase(), style: const TextStyle(fontSize: 7, letterSpacing: 1.0, color: Colors.white30))])),
      IconButton(tooltip: 'Inspect', visualDensity: VisualDensity.compact, onPressed: onInspect, icon: const Icon(Icons.search_rounded, size: 16, color: Colors.white.withValues(alpha: .45))),
      IconButton(tooltip: 'Open visualization', visualDensity: VisualDensity.compact, onPressed: onVisualize, icon: Icon(Icons.auto_graph_rounded, size: 16, color: accent)),
    ]),
  );
}

class S7FloatingVisualization {
  const S7FloatingVisualization({required this.title, required this.kind, required this.artifactId, required this.data, required this.description});
  final String title;
  final String kind;
  final String artifactId;
  final Map<String, dynamic> data;
  final String description;
}

class S7VisualizationFactory {
  const S7VisualizationFactory._();

  static S7FloatingVisualization fromArtifact(Map<String, dynamic> artifact, String room) {
    final kind = (artifact['kind'] ?? 'artifact').toString().toLowerCase();
    final id = (artifact['artifact_id'] ?? DateTime.now().microsecondsSinceEpoch).toString();
    final content = artifact['content'] is Map ? Map<String, dynamic>.from(artifact['content']) : <String, dynamic>{'value': artifact['content']};
    final type = _typeFor(kind, room);
    return S7FloatingVisualization(
      title: type,
      kind: kind,
      artifactId: id,
      data: content,
      description: 'Traceable view of ${artifact['title'] ?? id}. Source artifact: $id.',
    );
  }

  static String _typeFor(String kind, String room) {
    if (room == 'vivren') {
      if (kind.contains('contrad')) return 'Contradiction Graph';
      if (kind.contains('evidence')) return 'Evidence Matrix';
      if (kind.contains('provenance') || kind.contains('lineage')) return 'Lineage Graph';
      return 'Reasoning Integrity Map';
    }
    if (room == 'tarkis') {
      if (kind.contains('branch') || kind.contains('hypoth')) return 'Hypothesis Tree';
      if (kind.contains('compar')) return 'Comparison Map';
      return 'Exploration Map';
    }
    if (kind.contains('intervention')) return 'Intervention Timeline';
    if (kind.contains('hypoth')) return 'Hypothesis Tree';
    if (kind.contains('evidence')) return 'Evidence Matrix';
    return 'Team Reasoning Graph';
  }
}

class _FloatingVisualizationDialog extends StatelessWidget {
  const _FloatingVisualizationDialog({required this.viz, required this.accent});
  final S7FloatingVisualization viz;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final pretty = const JsonEncoder.withIndent('  ').convert(viz.data);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(22),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: _s7Glass.withValues(alpha: .97), borderRadius: BorderRadius.circular(24), border: Border.all(color: accent.withValues(alpha: .25)), boxShadow: [BoxShadow(color: accent.withValues(alpha: .10), blurRadius: 38)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.auto_graph_rounded, color: accent), const SizedBox(width: 10), Expanded(child: Text(viz.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.white, shadows: [Shadow(color: accent.withValues(alpha: .45), blurRadius: 10)]))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white54))]),
          Text(viz.description, style: const TextStyle(fontSize: 10, color: Colors.white54)),
          const SizedBox(height: 14),
          Expanded(child: _TraceGraphic(kind: viz.title, data: viz.data, accent: accent)),
          const SizedBox(height: 12),
          S7FunctionalGlassPanel(title: 'SOURCE SNAPSHOT', accent: accent, child: SelectableText(pretty, style: const TextStyle(fontSize: 9, height: 1.45, color: Colors.white54, fontFamily: 'monospace'))),
        ]),
      ),
    );
  }
}

class _TraceGraphic extends StatelessWidget {
  const _TraceGraphic({required this.kind, required this.data, required this.accent});
  final String kind;
  final Map<String, dynamic> data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _TracePainter(kind: kind, data: data, accent: accent), child: const SizedBox.expand());
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({required this.kind, required this.data, required this.accent});
  final String kind;
  final Map<String, dynamic> data;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.white.withValues(alpha: .045);
    for (var i = 1; i < 7; i++) canvas.drawLine(Offset(size.width * i / 7, 0), Offset(size.width * i / 7, size.height), grid);
    for (var i = 1; i < 5; i++) canvas.drawLine(Offset(0, size.height * i / 5), Offset(size.width, size.height * i / 5), grid);
    final glow = Paint()..color = accent.withValues(alpha: .10)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..color = accent;
    final node = Paint()..color = accent.withValues(alpha: .85);
    final count = mathMax(3, data.length + 1);
    if (kind.contains('Graph') || kind.contains('Map') || kind.contains('Tree')) {
      final center = Offset(size.width * .5, size.height * .48);
      canvas.drawCircle(center, 50, glow);
      canvas.drawCircle(center, 11, node);
      for (var i = 0; i < count; i++) {
        final a = -mathPi / 2 + i * mathPi2 / count;
        final r = mathMin(size.width, size.height) * .34;
        final p = center + Offset(mathCos(a) * r, mathSin(a) * r);
        canvas.drawLine(center, p, line);
        canvas.drawCircle(p, 7, node);
      }
    } else {
      final bars = mathMin(10, mathMax(3, data.length + 2));
      final w = size.width / (bars * 1.7);
      for (var i = 0; i < bars; i++) {
        final h = size.height * (.18 + ((i * 37) % 70) / 100 * .58);
        final rect = Rect.fromLTWH(28 + i * w * 1.55, size.height - h - 22, w, h);
        canvas.drawRect(rect, glow);
        canvas.drawRect(rect, Paint()..color = accent.withValues(alpha: .72));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) => oldDelegate.kind != kind || oldDelegate.data != data || oldDelegate.accent != accent;
}

class S7DebateArena extends StatefulWidget {
  const S7DebateArena({super.key});

  @override
  State<S7DebateArena> createState() => _S7DebateArenaState();
}

class _S7DebateArenaState extends State<S7DebateArena> {
  final input = TextEditingController();
  final messages = <S7DebateMessage>[
    const S7DebateMessage('VIVREN', 'I will inspect the evidence, context, contradictions, and limits of the current conclusion.', _s7Violet),
    const S7DebateMessage('TARKIS', 'I will explore alternatives, branches, and scenarios that could explain the observations differently.', _s7Amber),
    const S7DebateMessage('HUMAN', 'Challenge or redirect the reasoning here. The arena keeps the exchange visible.', Colors.white),
  ];

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void send() {
    final text = input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add(S7DebateMessage('HUMAN', text, Colors.white));
      messages.add(S7DebateMessage('VIVREN', 'Critical inspection requested: separate evidence from assumption, identify missing context, and expose any contradiction.', _s7Violet));
      messages.add(S7DebateMessage('TARKIS', 'Hypothesis exploration requested: generate an alternative path and identify what observation would distinguish it.', _s7Amber));
      input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(18),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 700),
        decoration: BoxDecoration(color: _s7Glass.withValues(alpha: .97), borderRadius: BorderRadius.circular(26), border: Border.all(color: Colors.white.withValues(alpha: .12)), boxShadow: [BoxShadow(color: _s7Violet.withValues(alpha: .06), blurRadius: 40)]),
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 17, 12, 12), child: Row(children: [const Icon(Icons.forum_rounded, color: _s7Violet), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DEBATE ARENA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: Colors.white)), SizedBox(height: 3), Text('Vivren ↔ Tarkis ↔ Human', style: TextStyle(fontSize: 9, color: Colors.white38))])), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white54))])),
          const Divider(height: 1, color: Colors.white10),
          Expanded(child: ListView.builder(padding: const EdgeInsets.all(18), itemCount: messages.length, itemBuilder: (_, i) => _DebateBubble(message: messages[i]))),
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: Row(children: [Expanded(child: TextField(controller: input, minLines: 1, maxLines: 4, onSubmitted: (_) => send(), decoration: const InputDecoration(hintText: 'Challenge, compare, request context, or redirect...', prefixIcon: Icon(Icons.psychology_outlined)))), const SizedBox(width: 8), IconButton.filled(onPressed: send, icon: const Icon(Icons.send_rounded))])),
        ]),
      ),
    );
  }
}

class S7DebateMessage {
  const S7DebateMessage(this.actor, this.text, this.accent);
  final String actor;
  final String text;
  final Color accent;
}

class _DebateBubble extends StatelessWidget {
  const _DebateBubble({required this.message});
  final S7DebateMessage message;

  @override
  Widget build(BuildContext context) => Align(alignment: message.actor == 'HUMAN' ? Alignment.centerRight : Alignment.centerLeft, child: Container(width: MediaQuery.sizeOf(context).width * .72, margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: message.accent.withValues(alpha: .055), borderRadius: BorderRadius.circular(15), border: Border.all(color: message.accent.withValues(alpha: .16))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(message.actor, style: TextStyle(fontSize: 8, letterSpacing: 1.4, fontWeight: FontWeight.w900, color: message.accent)), const SizedBox(height: 5), Text(message.text, style: const TextStyle(fontSize: 11, height: 1.45, color: Colors.white70))])));
}

class S7FunctionalGlassPanel extends StatelessWidget {
  const S7FunctionalGlassPanel({super.key, required this.title, required this.child, this.accent});
  final String title;
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .025), borderRadius: BorderRadius.circular(12), border: Border.all(color: (accent ?? Colors.white).withValues(alpha: .10))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 8, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: accent ?? Colors.white38)), const SizedBox(height: 7), child]));
}

const mathPi = 3.141592653589793;
const mathPi2 = 6.283185307179586;
double mathSin(double value) => math.sin(value);
double mathCos(double value) => math.cos(value);
double mathMin(double a, double b) => a < b ? a : b;
double mathMax(double a, double b) => a > b ? a : b;
