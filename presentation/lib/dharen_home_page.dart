import 'package:flutter/material.dart';
import 'presentation/criterivox_theme.dart';
import 'presentation/presentation_state.dart';

class DharenHomePage extends StatelessWidget {
  final List<PresentationState> history;
  final ValueChanged<PresentationState> onOpenTask;

  const DharenHomePage({
    super.key,
    required this.history,
    required this.onOpenTask,
  });

  List<PresentationState> get _active => history
      .where((s) => s.taskId != null && s.taskState != null && s.taskState != 'COMPLETED' && s.taskState != 'FAILED' && s.taskState != 'CANCELLED')
      .toList();

  List<PresentationState> get _completed => history
      .where((s) => s.taskId != null && (s.taskState == 'COMPLETED' || s.taskState == 'FAILED' || s.taskState == 'CANCELLED'))
      .toList();

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dharen', style: TextStyle(color: t.text, fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Analysis Home • active work and completed analytical results', style: TextStyle(color: t.mutedText, fontSize: 11)),
          const SizedBox(height: 18),
          _section(context, 'ACTIVE ANALYSES', _active, Icons.play_circle_outline_rounded),
          const SizedBox(height: 16),
          _section(context, 'COMPLETED ANALYSES', _completed, Icons.task_alt_rounded),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<PresentationState> items, IconData icon) {
    final t = CriterivoxTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: t.primary, size: 19), const SizedBox(width: 8), Text(title, style: TextStyle(color: t.text, fontSize: 13, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text('No analyses in this section yet.', style: TextStyle(color: t.mutedText, fontSize: 10.5))
          else
            ...items.map((item) => _taskTile(context, item)),
        ],
      ),
    );
  }

  Widget _taskTile(BuildContext context, PresentationState item) {
    final t = CriterivoxTheme.of(context);
    final completed = item.taskState == 'COMPLETED';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)),
      child: Row(
        children: [
          Icon(completed ? Icons.check_circle_outline_rounded : Icons.autorenew_rounded, color: completed ? t.success : t.primary, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.taskId ?? 'Unknown task', style: TextStyle(color: t.text, fontSize: 10.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(item.task ?? 'Analysis task', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: t.mutedText, fontSize: 10)),
              const SizedBox(height: 3),
              Text(item.taskState ?? 'UNKNOWN', style: TextStyle(color: t.mutedText, fontSize: 8.5, fontWeight: FontWeight.w700)),
            ]),
          ),
          TextButton.icon(onPressed: () => onOpenTask(item), icon: const Icon(Icons.open_in_new_rounded, size: 15), label: const Text('Open')),
        ],
      ),
    );
  }
}
