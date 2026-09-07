import 'package:flutter/material.dart';
import '../presentation/presentation_state.dart';
import '../presentation/criterivox_theme.dart';

class CharacterChatPage extends StatefulWidget {
  final PresentationState? state;
  final bool busy;
  final String selectedAgent;
  final ValueChanged<String> onSelectAgent;
  final void Function(String message, String agent) onSend;
  final VoidCallback onOpenTask;

  const CharacterChatPage({
    super.key,
    required this.state,
    required this.busy,
    required this.selectedAgent,
    required this.onSelectAgent,
    required this.onSend,
    required this.onOpenTask,
  });

  @override
  State<CharacterChatPage> createState() => _CharacterChatPageState();
}

class _CharacterChatPageState extends State<CharacterChatPage> {
  final input = TextEditingController();

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void _send() {
    final text = input.text.trim();
    if (text.isEmpty || widget.busy) return;
    input.clear();
    widget.onSend(text, widget.selectedAgent);
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 900;
      return Container(
        color: t.page,
        child: Row(children: [
          if (!narrow) SizedBox(width: 235, child: _CharacterPicker(selected: widget.selectedAgent, onSelect: widget.onSelectAgent)),
          Expanded(child: _Conversation(
            state: widget.state,
            busy: widget.busy,
            target: widget.selectedAgent,
            input: input,
            onSend: _send,
            onOpenTask: widget.onOpenTask,
            onSelectAgent: widget.onSelectAgent,
          )),
          if (!narrow) SizedBox(width: 290, child: _Context(state: widget.state, target: widget.selectedAgent)),
        ]),
      );
    });
  }
}

class _CharacterPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _CharacterPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Container(
      decoration: BoxDecoration(border: Border(right: BorderSide(color: t.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(18, 24, 18, 16), child: Text('CHARACTER NETWORK', style: TextStyle(color: t.mutedText, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2))),
        _Agent(name: 'Syvax', role: 'Dialogue + routing', icon: Icons.hub_rounded, selected: selected == 'syvax', onTap: () => onSelect('syvax')),
        _Agent(name: 'Dharen', role: 'Structural analysis', icon: Icons.analytics_rounded, selected: selected == 'dharen', onTap: () => onSelect('dharen')),
        const Spacer(),
        Padding(padding: const EdgeInsets.all(18), child: Text('The chat is independent as a surface, not isolated from the application. Every conversation can open or continue the same analysis task.', style: TextStyle(color: t.mutedText, fontSize: 10, height: 1.45))),
      ]),
    );
  }
}

class _Agent extends StatelessWidget {
  final String name, role;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _Agent({required this.name, required this.role, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return ListTile(
      onTap: onTap,
      selected: selected,
      selectedTileColor: t.primary.withValues(alpha: .12),
      leading: CircleAvatar(backgroundColor: t.surfaceStrong, child: Icon(icon, color: t.primary, size: 18)),
      title: Text(name, style: TextStyle(color: t.text, fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(role, style: TextStyle(color: t.mutedText, fontSize: 9)),
    );
  }
}

class _Conversation extends StatelessWidget {
  final PresentationState? state;
  final bool busy;
  final String target;
  final TextEditingController input;
  final VoidCallback onSend;
  final VoidCallback onOpenTask;
  final ValueChanged<String> onSelectAgent;

  const _Conversation({required this.state, required this.busy, required this.target, required this.input, required this.onSend, required this.onOpenTask, required this.onSelectAgent});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final name = target == 'dharen' ? 'Dharen' : 'Syvax';
    final role = target == 'dharen' ? 'Structural analysis + task execution' : 'Human-system dialogue + routing';
    return Column(children: [
      Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.border))),
        child: Row(children: [
          CircleAvatar(backgroundColor: t.surfaceStrong, child: Icon(target == 'dharen' ? Icons.analytics_rounded : Icons.hub_rounded, color: t.primary, size: 19)),
          const SizedBox(width: 12),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Chat with $name', style: TextStyle(color: t.text, fontSize: 18, fontWeight: FontWeight.w700)), Text(role, style: TextStyle(color: t.mutedText, fontSize: 10))])),
          if (MediaQuery.sizeOf(context).width < 900) PopupMenuButton<String>(initialValue: target, onSelected: onSelectAgent, itemBuilder: (_) => const [PopupMenuItem(value: 'syvax', child: Text('Syvax · Route work')), PopupMenuItem(value: 'dharen', child: Text('Dharen · Analyze directly'))]),
          Icon(Icons.more_horiz_rounded, color: t.mutedText),
        ]),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.all(24), children: [
        _Welcome(target: target),
        if (state?.message != null) _Bubble(who: name, text: state!.message!),
        if (state?.taskId != null) _Task(state!, onOpenTask),
      ])),
      Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: t.border))),
        child: Row(children: [
          Expanded(child: TextField(controller: input, minLines: 1, maxLines: 5, onSubmitted: (_) => onSend(), decoration: InputDecoration(hintText: 'Message $name…'))),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: busy ? null : onSend, icon: const Icon(Icons.arrow_upward_rounded)),
        ]),
      ),
    ]);
  }
}

class _Welcome extends StatelessWidget {
  final String target;
  const _Welcome({required this.target});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final direct = target == 'dharen';
    return Container(
      margin: const EdgeInsets.only(bottom: 18), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(18), border: Border.all(color: t.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(direct ? 'Direct analysis with Dharen' : 'Start with Syvax', style: TextStyle(color: t.text, fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        Text(direct ? 'Give Dharen a task, data, context, or a question about the current analysis.' : 'Tell Syvax what you want. He keeps the task context and routes work to the appropriate character.', style: TextStyle(color: t.mutedText, fontSize: 11.5, height: 1.5)),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String who, text;
  const _Bubble({required this.who, required this.text});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(who, style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text(text, style: TextStyle(color: t.text, fontSize: 12.5, height: 1.45))]));
  }
}

class _Task extends StatelessWidget {
  final PresentationState state;
  final VoidCallback open;
  const _Task(this.state, this.open);
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)), child: Row(children: [Expanded(child: Text('${state.taskId} • ${state.taskState ?? 'ACTIVE'}', style: TextStyle(color: t.text, fontSize: 11))), TextButton(onPressed: open, child: const Text('Open workspace'))]));
  }
}

class _Context extends StatelessWidget {
  final PresentationState? state;
  final String target;
  const _Context({required this.state, required this.target});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final name = target == 'dharen' ? 'Dharen' : 'Syvax';
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(border: Border(left: BorderSide(color: t.border))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ACTIVE CONTEXT', style: TextStyle(color: t.mutedText, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      const SizedBox(height: 16), Text(name, style: TextStyle(color: t.text, fontSize: 20, fontWeight: FontWeight.w700)),
      Text(target == 'dharen' ? 'Structural analysis' : 'Dialogue + routing', style: TextStyle(color: t.mutedText, fontSize: 10)),
      const SizedBox(height: 25),
      _line('Connection', 'LIVE', t), _line('Task', state?.taskId ?? 'None', t), _line('State', state?.taskState ?? 'IDLE', t),
      const SizedBox(height: 25), Text('TASK RELATIONSHIP', style: TextStyle(color: t.mutedText, fontSize: 10, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10), Text('Chat and Analysis Workspace share the same authoritative runtime state. Opening the workspace never creates a second task.', style: TextStyle(color: t.mutedText, fontSize: 11, height: 1.5)),
      const Spacer(),
      if (state?.taskId != null) FilledButton.icon(onPressed: openTask(context), icon: const Icon(Icons.dashboard_customize_rounded, size: 16), label: const Text('Open current task')),
    ]));
  }

  VoidCallback openTask(BuildContext context) => () {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(const SnackBar(content: Text('Use the task card above to open the shared workspace.')));
  };

  Widget _line(String label, String value, CriterivoxTheme t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [SizedBox(width: 80, child: Text(label, style: TextStyle(color: t.mutedText, fontSize: 10))), Expanded(child: Text(value, style: TextStyle(color: t.text, fontSize: 10, fontWeight: FontWeight.w600)))]));
}
