import 'package:flutter/material.dart';
import 'character/character_presentation.dart';
import 'presentation/presentation_state.dart';
import 'presentation/criterivox_theme.dart';

class AnalysisPage extends StatelessWidget {
  final PresentationState? state;
  final bool busy;
  final TextEditingController task, data, contextText;
  final VoidCallback onStart, onChat;

  const AnalysisPage({super.key, required this.state, required this.busy, required this.task, required this.data, required this.contextText, required this.onStart, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final s = state;
    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 1000;
      final cardWidth = narrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 3;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analysis Workspace', style: TextStyle(color: t.text, fontSize: 23, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text("Dharen's Home  •  Structural Context", style: TextStyle(color: t.mutedText, fontSize: 11)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(width: cardWidth, child: _Card(Icons.dashboard_customize_rounded, 'Open Analysis Workspace', 'Deep dive into data, context, observations and results.')),
                SizedBox(width: cardWidth, child: _Card(Icons.forum_rounded, 'Chat with Dharen', 'Ask directly without leaving the current task.', onChat: onChat)),
                SizedBox(width: cardWidth, child: _Card(Icons.bolt_rounded, 'Active Task', s?.taskId ?? 'No active task')),
              ],
            ),
            const SizedBox(height: 16),
            if (s == null)
              _Form(task: task, data: data, ctx: contextText, busy: busy, start: onStart)
            else ...[
              _Kpis(s),
              const SizedBox(height: 14),
              if (narrow)
                Column(
                  children: [
                    _Panel('Data & Context', Text('${s.taskDataFields ?? 0} data fields\n${s.taskContextFields ?? 0} context fields\nSource: ${s.taskSource ?? 'workspace'}')),
                    const SizedBox(height: 12),
                    _Panel('Analysis Overview', SizedBox(height: 190, child: CustomPaint(painter: _Graph(s.observations.length)))),
                    const SizedBox(height: 12),
                    _Panel('Recent Observations (Live)', Column(children: [for (final o in s.observations.take(5)) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('${o['text'] ?? ''}', style: TextStyle(color: t.mutedText, fontSize: 9.5)))])),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _Panel('Data & Context', Text('${s.taskDataFields ?? 0} data fields\n${s.taskContextFields ?? 0} context fields\nSource: ${s.taskSource ?? 'workspace'}'))),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _Panel('Analysis Overview', SizedBox(height: 190, child: CustomPaint(painter: _Graph(s.observations.length))))),
                    const SizedBox(width: 12),
                    Expanded(child: _Panel('Recent Observations (Live)', Column(children: [for (final o in s.observations.take(5)) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('${o['text'] ?? ''}', style: TextStyle(color: t.mutedText, fontSize: 9.5)))]))),
                  ],
                ),
              const SizedBox(height: 14),
              _Dharen(s, onChat: onChat),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Panel('Task Lifecycle', Text(s.taskState ?? 'CREATED', style: TextStyle(color: t.primary))),
                  _Panel('Activity Feed', Column(children: [for (final a in s.activity.take(6)) Text(a, style: TextStyle(color: t.mutedText, fontSize: 9))])),
                  _Panel('Quick Stats', Text('${s.observations.length} observations  •  ${s.findings.length} findings', style: TextStyle(color: t.text))),
                  _Panel('Data Quality', Text('GOOD', style: TextStyle(color: t.success, fontWeight: FontWeight.w700))),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _Card extends StatelessWidget {
  final IconData icon;
  final String title, body;
  final VoidCallback? onChat;
  const _Card(this.icon, this.title, this.body, {this.onChat});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return InkWell(
      onTap: onChat,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)),
        child: Row(children: [
          Icon(icon, color: t.primary, size: 26),
          const SizedBox(width: 10),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: t.text, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(body, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: t.mutedText, fontSize: 9.5)),
          ])),
        ]),
      ),
    );
  }
}

class _Kpis extends StatelessWidget {
  final PresentationState s;
  const _Kpis(this.s);
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)),
      child: Wrap(spacing: 20, runSpacing: 12, children: [
        _k('Overall Progress', s.taskState == 'COMPLETED' ? '100%' : '68%', t),
        _k('Current Stage', s.taskState ?? 'READY', t),
        _k('Data Items', '${s.taskDataFields ?? 0}', t),
        _k('Observations', '${s.observations.length}', t),
        _k('Findings', '${s.findings.length}', t),
      ]),
    );
  }
  Widget _k(String a, String b, CriterivoxTheme t) => SizedBox(width: 130, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a, style: TextStyle(color: t.mutedText, fontSize: 8)), const SizedBox(height: 5), Text(b, overflow: TextOverflow.ellipsis, style: TextStyle(color: t.text, fontSize: 14, fontWeight: FontWeight.w700))]));
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const _Panel(this.title, this.child);
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: t.text, fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 11), child]),
    );
  }
}

class _Dharen extends StatelessWidget {
  final PresentationState s;
  final VoidCallback onChat;
  const _Dharen(this.s, {required this.onChat});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Container(
      height: 350,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border), boxShadow: [BoxShadow(color: t.primary.withValues(alpha: .07), blurRadius: 30)]),
      child: Row(children: [
        SizedBox(width: 390, child: CharacterPresentation(state: s)),
        const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(s.characterState, style: TextStyle(color: t.primary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 15),
          Text(s.message ?? 'Dharen is processing the task.', style: TextStyle(color: t.text, fontSize: 14, height: 1.45)),
          const SizedBox(height: 16),
          Text('Dharen’s Focus  •  ${s.taskState ?? 'READY'}', style: TextStyle(color: t.mutedText, fontSize: 11)),
          const SizedBox(height: 15),
          OutlinedButton.icon(onPressed: onChat, icon: const Icon(Icons.chat_bubble_outline_rounded), label: const Text('Ask Dharen')),
        ])),
      ]),
    );
  }
}

class _Form extends StatelessWidget {
  final TextEditingController task, data, ctx;
  final bool busy;
  final VoidCallback start;
  const _Form({required this.task, required this.data, required this.ctx, required this.busy, required this.start});
  @override
  Widget build(BuildContext context) => _Panel('Start Analysis', Column(children: [
    TextField(controller: task, maxLines: 2, decoration: const InputDecoration(labelText: 'Task')),
    const SizedBox(height: 9),
    TextField(controller: data, decoration: const InputDecoration(labelText: 'Data')),
    const SizedBox(height: 9),
    TextField(controller: ctx, decoration: const InputDecoration(labelText: 'Context')),
    const SizedBox(height: 14),
    Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: busy ? null : start, icon: const Icon(Icons.play_arrow_rounded), label: Text(busy ? 'Starting…' : 'Start Analysis'))),
  ]));
}

class _Graph extends CustomPainter {
  final int n;
  _Graph(this.n);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.7..color = const Color(0xFF805CFF);
    final path = Path();
    for (var i = 0; i < 9; i++) {
      final x = i * size.width / 8;
      final y = size.height - 20 - ((i * 17 + n * 13) % 120);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, p);
  }
  @override
  bool shouldRepaint(covariant _Graph old) => old.n != n;
}
