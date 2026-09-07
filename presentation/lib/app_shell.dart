import 'package:flutter/material.dart';
import 'presentation/runtime_client.dart';
import 'presentation/presentation_state.dart';
import 'interaction/bloom.dart';
import 'bloom_page.dart';
import 'analysis_page.dart';
import 'chat/character_chat_page.dart';

class CriterivoxShell extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const CriterivoxShell({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<CriterivoxShell> createState() => _ShellState();
}

class _ShellState extends State<CriterivoxShell> {
  final runtime = CharacterRuntimeClient();
  final task = TextEditingController(text: 'Analyze the supplied information in its current context.');
  final data = TextEditingController(text: 'Local sample dataset');
  final ctx = TextEditingController(text: 'Synthetic local research context');
  PresentationState? state;
  String page = 'bloom';
  bool busy = false;

  @override
  void initState() {
    super.initState();
    runtime.states.listen((v) {
      if (mounted) setState(() { state = v; busy = false; });
    });
    runtime.errors.listen((_) {
      if (mounted) setState(() => busy = false);
    });
    runtime.connect();
  }

  @override
  void dispose() {
    runtime.dispose();
    task.dispose();
    data.dispose();
    ctx.dispose();
    super.dispose();
  }

  void open(String p) => setState(() => page = p);

  void send(String m) {
    setState(() => busy = true);
    runtime.sendChat(
      message: m,
      data: {'dataset': data.text, 'records': 3},
      context: {'description': ctx.text, 'origin': 'Syvax'},
    );
  }

  void start() {
    setState(() => busy = true);
    runtime.requestApplication(
      intent: 'analyze',
      task: task.text,
      data: {'dataset': data.text, 'records': 3},
      context: {'description': ctx.text, 'origin': 'Analysis Workspace'},
      source: 'workspace',
    );
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    body: Row(children: [
      _Rail(page: page, onOpen: open),
      Expanded(child: Column(children: [
        _Top(isDarkMode: widget.isDarkMode, onToggleTheme: widget.onToggleTheme),
        Expanded(
          child: page == 'chat'
              ? CharacterChatPage(state: state, busy: busy, onSend: send, onOpenTask: () => open('workspace'))
              : page == 'workspace'
                  ? AnalysisPage(state: state, busy: busy, task: task, data: data, contextText: ctx, onStart: start, onChat: () => open('chat'))
                  : BloomPage(onSub: (v) => open(v == BloomSuboption.workspace ? 'workspace' : 'chat'), onSyvax: send, busy: busy),
        ),
      ])),
    ]),
  );
}

class _Rail extends StatelessWidget {
  final String page;
  final ValueChanged<String> onOpen;
  const _Rail({required this.page, required this.onOpen});

  @override
  Widget build(BuildContext c) => Container(
    width: 220,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(c).brightness == Brightness.dark ? const Color(0xCC050712) : Theme.of(c).colorScheme.surface,
      border: Border(right: BorderSide(color: Theme.of(c).dividerColor)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.all(12), child: Text('CRITERIVOX', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
      const SizedBox(height: 20),
      _nav('BLOOM', Icons.auto_awesome_rounded, page == 'bloom', () => onOpen('bloom')),
      const SizedBox(height: 14),
      _label('CAPABILITIES'),
      _nav('Analyze', Icons.bar_chart_rounded, page == 'workspace', () => onOpen('workspace')),
      _nav('Compare', Icons.balance_rounded, false, () {}),
      _nav('Explore', Icons.search_rounded, false, () {}),
      _nav('Plan', Icons.calendar_month_rounded, false, () {}),
      _nav('Insights', Icons.lightbulb_outline_rounded, false, () {}),
      _nav('Explain', Icons.chat_bubble_outline_rounded, false, () {}),
      const SizedBox(height: 14),
      _label('QUICK ACTIONS'),
      _nav('Analysis Workspace', Icons.dashboard_customize_rounded, page == 'workspace', () => onOpen('workspace')),
      _nav('Character Chat', Icons.forum_rounded, page == 'chat', () => onOpen('chat')),
      const Spacer(),
      Text('Syvax coordinates dialogue and character handoff.', style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant, fontSize: 10)),
    ]),
  );

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700));

  Widget _nav(String t, IconData i, bool active, VoidCallback tap) => ListTile(
    onTap: tap,
    selected: active,
    selectedTileColor: Theme.of(c).colorScheme.primary.withValues(alpha: .14),
    dense: true,
    leading: Icon(i, size: 17, color: active ? Theme.of(c).colorScheme.primary : Theme.of(c).colorScheme.onSurfaceVariant),
    title: Text(t, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
  );
}

class _Top extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const _Top({required this.isDarkMode, required this.onToggleTheme});

  @override
  Widget build(BuildContext c) => Container(
    height: 70,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(c).dividerColor))),
    child: Row(children: [
      Text('Research Intelligence Workspace', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const Spacer(),
      IconButton(
        tooltip: isDarkMode ? 'Switch to day theme' : 'Switch to night theme',
        onPressed: onToggleTheme,
        icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      ),
      const SizedBox(width: 10),
      const Icon(Icons.notifications_none_rounded),
      const SizedBox(width: 20),
      CircleAvatar(radius: 17, child: Icon(Icons.person_outline_rounded, size: 18)),
    ]),
  );
}
