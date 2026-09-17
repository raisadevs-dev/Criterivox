import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 's8_presentation_state.dart';
import 's8_explanation_pipeline.dart';

class S8XaiDashboard extends StatelessWidget {
  final S8PresentationSnapshot snapshot;

  const S8XaiDashboard({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final panels = S8XaiPanels.fromSnapshot(snapshot);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final children = [
          _Panel(title: 'Recent Activity', icon: Icons.history, lines: panels.recentActivity),
          _Panel(title: 'Key Insights', icon: Icons.lightbulb_outline, lines: panels.keyInsights),
          _Panel(title: 'Information Flow', icon: Icons.account_tree_outlined, lines: panels.informationFlow),
        ];
        final content = wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.all(6), child: c))).toList())
            : Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
        return content;
      },
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> lines;

  const _Panel({required this.title, required this.icon, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleMedium)]),
          const SizedBox(height: 12),
          ...lines.take(8).map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(line, maxLines: 3, overflow: TextOverflow.ellipsis),
              )),
        ]),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: .04, end: 0, duration: 300.ms);
  }
}
