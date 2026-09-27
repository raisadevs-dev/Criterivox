import 'dart:convert';

import 'package:flutter/material.dart';

import 's7_nlp_debate_arena.dart';

const _s7Violet = Color(0xffb59cff);
const _s7Amber = Color(0xffffb463);
const _s7Glass = Color(0xff111526);

class S7CharacterStateResolver {
  const S7CharacterStateResolver._();

  static Map<String, dynamic> resolve(String identity, Map<String, dynamic> source) {
    final String raw = (source['state'] ?? 'idle').toString().toLowerCase();
    final bool isVivren = identity.toLowerCase() == 'vivren';
    final (String, String, String) mapped = isVivren ? _vivren(raw) : _tarkis(raw);
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
  const S7FunctionalDock({super.key, required this.room, required this.artifacts, required this.onSelectArtifact});

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
        children: <Widget>[
          if (expanded)
            Container(
              width: 310,
              margin: const EdgeInsets.only(bottom: 54, right: 2),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _s7Glass.withValues(alpha: .91),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accent.withValues(alpha: .24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.hub_rounded, size: 17, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.room == 'collaboration' ? 'ANALYTICAL OBJECTS' : widget.room == 'vivren' ? 'CRITICAL VISUALS' : 'HYPOTHESIS VISUALS',
                          style: TextStyle(fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: .9)),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Collapse',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => expanded = false),
                        icon: const Icon(Icons.remove_rounded, size: 18, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Open an artifact as a traceable floating visualization. Source identity remains attached.',
                    style: TextStyle(fontSize: 9, height: 1.4, color: Colors.white.withValues(alpha: .48)),
                  ),
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
                          final Map<String, dynamic> artifact = widget.artifacts[index];
                          return _ArtifactAction(
                            title: (artifact['title'] ?? artifact['artifact_id'] ?? 'Analytical artifact').toString(),
                            kind: (artifact['kind'] ?? 'artifact').toString(),
                            accent: accent,
                            onInspect: () => widget.onSelectArtifact(artifact),
                            onVisualize: () => _addVisualization(artifact),
                          );
                        },
                      ),
                    ),
                  if (floating.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Text('OPEN FLOATING OBJECTS', style: TextStyle(fontSize: 8, letterSpacing: 1.3, fontWeight: FontWeight.w800, color: accent)),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: floating.asMap().entries.map((entry) => ActionChip(
                        label: Text('${entry.value.title} ${entry.key + 1}', style: const TextStyle(fontSize: 8)),
                        onPressed: () => _open(entry.value),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (widget.room == 'collaboration')
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openDebate(context),
                        icon: const Icon(Icons.forum_outlined, size: 16),
                        label: const Text('OPEN DEBATE ARENA'),
                      ),
                    ),
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
    final S7FloatingVisualization? viz = S7VisualizationFactory.tryFromArtifact(artifact, widget.room);
    if (viz == null) {
      return;
    }
    setState(() {
      if (!floating.any((item) => item.artifactId == viz.artifactId)) {
        floating.add(viz);
      }
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .025), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withValues(alpha: .06))),
      child: Row(
        children: <Widget>[
          Container(width: 5, height: 26, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white70)),
                Text(kind.toUpperCase(), style: const TextStyle(fontSize: 7, letterSpacing: 1.0, color: Colors.white30)),
              ],
            ),
          ),
          IconButton(tooltip: 'Inspect', visualDensity: VisualDensity.compact, onPressed: onInspect, icon: Icon(Icons.search_rounded, size: 16, color: Colors.white.withValues(alpha: .45))),
          IconButton(tooltip: 'Open visualization', visualDensity: VisualDensity.compact, onPressed: onVisualize, icon: Icon(Icons.auto_graph_rounded, size: 16, color: accent)),
        ],
      ),
    );
  }
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

  static S7FloatingVisualization? tryFromArtifact(Map<String, dynamic> artifact, String room) {
    final String kind = (artifact['kind'] ?? '').toString().toLowerCase();
    final String? type = _typeFor(kind, room);
    if (type == null) {
      return null;
    }
    final String id = (artifact['artifact_id'] ?? '').toString();
    if (id.isEmpty) {
      return null;
    }
    final Map<String, dynamic> content = artifact['content'] is Map
        ? Map<String, dynamic>.from(artifact['content'] as Map)
        : <String, dynamic>{'value': artifact['content']};
    return S7FloatingVisualization(
      title: type,
      kind: kind,
      artifactId: id,
      data: content,
      description: 'Traceable view of ${artifact['title'] ?? id}. Source artifact: $id.',
    );
  }

  static S7FloatingVisualization fromArtifact(Map<String, dynamic> artifact, String room) {
    final S7FloatingVisualization? result = tryFromArtifact(artifact, room);
    if (result == null) {
      throw ArgumentError('Artifact kind is not supported in the $room room.');
    }
    return result;
  }

  static String? _typeFor(String kind, String room) {
    if (room == 'vivren') {
      if (kind.contains('contrad')) return 'Contradiction Graph';
      if (kind.contains('evidence')) return 'Evidence Matrix';
      if (kind.contains('provenance') || kind.contains('lineage')) return 'Lineage Graph';
      if (kind.contains('reason')) return 'Reasoning Integrity Map';
      if (kind.contains('assumption')) return 'Assumption Network';
      return null;
    }
    if (room == 'tarkis') {
      if (kind.contains('branch') || kind.contains('hypoth')) return 'Hypothesis Tree';
      if (kind.contains('compar')) return 'Comparison Map';
      if (kind.contains('counterfactual') || kind.contains('scenario')) return 'Scenario Matrix';
      if (kind.contains('revision') || kind.contains('refin')) return 'Hypothesis Evolution Timeline';
      return null;
    }
    if (kind.contains('intervention')) return 'Intervention Timeline';
    if (kind.contains('hypoth')) return 'Hypothesis Tree';
    if (kind.contains('evidence')) return 'Evidence Matrix';
    if (kind.contains('debate')) return 'Debate Map';
    if (kind.contains('reason')) return 'Team Reasoning Graph';
    return null;
  }
}

class _FloatingVisualizationDialog extends StatelessWidget {
  const _FloatingVisualizationDialog({required this.viz, required this.accent});

  final S7FloatingVisualization viz;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final String pretty = const JsonEncoder.withIndent('  ').convert(viz.data);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(22),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: _s7Glass.withValues(alpha: .97), borderRadius: BorderRadius.circular(24), border: Border.all(color: accent.withValues(alpha: .25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.auto_graph_rounded, color: accent),
                const SizedBox(width: 10),
                Expanded(child: Text(viz.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.white))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white54)),
              ],
            ),
            Text(viz.description, style: const TextStyle(fontSize: 10, color: Colors.white54)),
            const SizedBox(height: 14),
            Expanded(child: _TraceGraphic(kind: viz.title, data: viz.data, accent: accent)),
            const SizedBox(height: 12),
            S7FunctionalGlassPanel(
              title: 'SOURCE SNAPSHOT',
              accent: accent,
              child: SelectableText(pretty, style: const TextStyle(fontSize: 9, height: 1.45, color: Colors.white54, fontFamily: 'monospace')),
            ),
          ],
        ),
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
    final Paint grid = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.white.withValues(alpha: .045);
    for (int i = 1; i < 7; i++) {
      canvas.drawLine(Offset(size.width * i / 7, 0), Offset(size.width * i / 7, size.height), grid);
    }
    for (int i = 1; i < 5; i++) {
      canvas.drawLine(Offset(0, size.height * i / 5), Offset(size.width, size.height * i / 5), grid);
    }
    final int count = data.isEmpty ? 1 : data.length.clamp(1, 8);
    final Paint line = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..color = accent;
    final Paint node = Paint()..color = accent.withValues(alpha: .85);
    final List<Offset> points = <Offset>[];
    for (int i = 0; i < count; i++) {
      points.add(Offset(size.width * ((i + 1) / (count + 1)), size.height * (.30 + ((i % 3) * .16))));
    }
    if (points.length > 1) {
      final Path path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final Offset point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, line);
    }
    for (final Offset point in points) {
      canvas.drawCircle(point, 6, node);
    }
    final TextPainter label = TextPainter(
      text: TextSpan(text: kind.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: accent)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    label.paint(canvas, const Offset(10, 10));
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.data != data || oldDelegate.accent != accent;
  }
}

class S7FunctionalGlassPanel extends StatelessWidget {
  const S7FunctionalGlassPanel({super.key, required this.title, required this.accent, required this.child});

  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .025), borderRadius: BorderRadius.circular(14), border: Border.all(color: accent.withValues(alpha: .12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(fontSize: 8, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: accent)),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}
