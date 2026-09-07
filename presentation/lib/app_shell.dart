import 'dart:async';

import 'package:flutter/material.dart';

import 'analysis_page.dart';
import 'bloom_page.dart';
import 'chat/character_chat_page.dart';
import 'interaction/bloom.dart';
import 'presentation/criterivox_theme.dart';
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';

class CriterivoxShell extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const CriterivoxShell({
    super.key,
    this.isDarkMode = true,
    this.onToggleTheme = _noop,
  });

  static void _noop() {}

  @override
  State<CriterivoxShell> createState() => _ShellState();
}

class _ShellState extends State<CriterivoxShell> {
  final runtime = CharacterRuntimeClient();
  final task = TextEditingController(
    text: 'Analyze the supplied information in its current context.',
  );
  final data = TextEditingController(text: 'Local sample dataset');
  final ctx = TextEditingController(text: 'Synthetic local research context');

  PresentationState? state;
  String page = 'bloom';
  String chatTarget = 'syvax';
  bool busy = false;
  bool railOpen = true;

  late final StreamSubscription<PresentationState> _stateSubscription;
  late final StreamSubscription<String> _errorSubscription;

  @override
  void initState() {
    super.initState();
    _stateSubscription = runtime.states.listen((value) {
      if (!mounted) return;
      setState(() {
        state = value;
        busy = false;
      });
    });
    _errorSubscription = runtime.errors.listen((_) {
      if (!mounted) return;
      setState(() => busy = false);
    });
    runtime.connect();
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _errorSubscription.cancel();
    runtime.dispose();
    task.dispose();
    data.dispose();
    ctx.dispose();
    super.dispose();
  }

  void open(String value) => setState(() => page = value);

  void showReserved(String capability) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$capability is reserved for a future capability sprint.')),
      );
  }

  void send(String message, {String? target}) {
    final selected = target ?? chatTarget;
    setState(() {
      busy = true;
      chatTarget = selected;
    });
    runtime.sendChat(
      message: message,
      targetCharacter: selected,
      taskId: state?.taskId,
      data: {'dataset': data.text, 'records': 3},
      context: {
        'description': ctx.text,
        'origin': selected == 'dharen' ? 'Direct Dharen Chat' : 'Syvax Routing',
      },
    );
  }

  void start() {
    setState(() => busy = true);
    runtime.requestApplication(
      intent: 'analyze',
      task: task.text,
      data: {'dataset': data.text, 'records': 3},
      context: {
        'description': ctx.text,
        'origin': 'Analysis Workspace',
      },
      source: 'workspace',
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    return Scaffold(
      backgroundColor: t.page,
      body: SafeArea(
        child: Row(
          children: [
            _Sidebar(
              page: page,
              expanded: railOpen,
              onOpen: open,
              onReserved: showReserved,
              onToggle: () => setState(() => railOpen = !railOpen),
            ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(
                    isDarkMode: widget.isDarkMode,
                    onToggleTheme: widget.onToggleTheme,
                    connectionLive: state != null,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: page == 'chat'
                          ? CharacterChatPage(
                              key: const ValueKey('chat'),
                              state: state,
                              busy: busy,
                              selectedAgent: chatTarget,
                              onSelectAgent: (agent) {
                                setState(() => chatTarget = agent);
                              },
                              onSend: (message, agent) {
                                send(message, target: agent);
                              },
                              onOpenTask: () => open('workspace'),
                            )
                          : page == 'workspace'
                              ? AnalysisPage(
                                  key: const ValueKey('workspace'),
                                  state: state,
                                  busy: busy,
                                  task: task,
                                  data: data,
                                  contextText: ctx,
                                  onStart: start,
                                  onChat: () => open('chat'),
                                )
                              : BloomPage(
                                  key: const ValueKey('bloom'),
                                  state: state,
                                  onSub: (value) => open(
                                    value == BloomSuboption.workspace
                                        ? 'workspace'
                                        : 'chat',
                                  ),
                                  onSyvax: (message) => send(
                                    message,
                                    target: 'syvax',
                                  ),
                                  busy: busy,
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String page;
  final bool expanded;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onReserved;
  final VoidCallback onToggle;

  const _Sidebar({
    required this.page,
    required this.expanded,
    required this.onOpen,
    required this.onReserved,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final width = expanded ? 244.0 : 76.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: width,
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: .96),
        border: Border(right: BorderSide(color: t.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(expanded ? 18 : 10, 18, 10, 14),
            child: Row(
              children: [
                const _BrandMark(size: 34),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Criterivox',
                      style: TextStyle(
                        color: t.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                IconButton(
                  tooltip: expanded ? 'Collapse sidebar' : 'Open sidebar',
                  onPressed: onToggle,
                  icon: Icon(
                    expanded
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: t.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: expanded,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8),
                child: Column(
                  children: [
                    _StatusCard(expanded: expanded),
                    const SizedBox(height: 18),
                    _section('CAPABILITIES', expanded, t),
                    _nav('Analyze', Icons.bar_chart_rounded, page == 'workspace', () => onOpen('workspace'), expanded, t),
                    _nav('Compare', Icons.balance_rounded, false, () => onReserved('Compare'), expanded, t),
                    _nav('Explore', Icons.search_rounded, false, () => onReserved('Explore'), expanded, t),
                    _nav('Plan', Icons.calendar_month_rounded, false, () => onReserved('Plan'), expanded, t),
                    _nav('Insights', Icons.lightbulb_outline_rounded, false, () => onReserved('Insights'), expanded, t),
                    _nav('Explain', Icons.chat_bubble_outline_rounded, page == 'chat', () => onOpen('chat'), expanded, t),
                    const SizedBox(height: 16),
                    _section('QUICK ACTIONS', expanded, t),
                    _nav('Bloom', Icons.auto_awesome_rounded, page == 'bloom', () => onOpen('bloom'), expanded, t),
                    _nav('Analysis Workspace', Icons.dashboard_customize_rounded, page == 'workspace', () => onOpen('workspace'), expanded, t),
                    _nav('Character Chat', Icons.forum_rounded, page == 'chat', () => onOpen('chat'), expanded, t),
                    if (expanded)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Choose your path. Syvax can route work, while Dharen remains directly reachable for analysis.',
                          style: TextStyle(color: t.mutedText, fontSize: 10, height: 1.45),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String text, bool visible, CriterivoxTheme t) {
    if (!visible) return const SizedBox(height: 8);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
        child: Text(text, style: TextStyle(color: t.mutedText, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _nav(String label, IconData icon, bool active, VoidCallback onTap, bool visible, CriterivoxTheme t) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: visible ? '' : label,
        child: ListTile(
          onTap: onTap,
          selected: active,
          dense: true,
          horizontalTitleGap: 12,
          contentPadding: EdgeInsets.symmetric(horizontal: visible ? 10 : 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          selectedTileColor: t.primary.withValues(alpha: .13),
          leading: Icon(icon, size: 19, color: active ? t.primary : t.mutedText),
          title: visible
              ? Text(label, style: TextStyle(color: active ? t.text : t.mutedText, fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500))
              : null,
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool expanded;
  const _StatusCard({required this.expanded});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Container(
      padding: EdgeInsets.all(expanded ? 14 : 10),
      decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: t.primary, size: 19),
          if (expanded) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RUNTIME', style: TextStyle(color: t.mutedText, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  const SizedBox(height: 3),
                  Text('Living system', style: TextStyle(color: t.text, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: t.success)),
          ],
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final bool connectionLive;

  const _TopBar({required this.isDarkMode, required this.onToggleTheme, required this.connectionLive});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: t.mutedText, size: 19),
                  const SizedBox(width: 10),
                  Text('Search workspace, characters, tasks...', style: TextStyle(color: t.mutedText, fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: t.border)),
            child: Row(children: [Icon(Icons.circle, size: 7, color: connectionLive ? t.success : t.warning), const SizedBox(width: 7), Text(connectionLive ? 'LIVE' : 'CONNECTING', style: TextStyle(color: t.mutedText, fontSize: 9, fontWeight: FontWeight.w700))]),
          ),
          const SizedBox(width: 8),
          IconButton(tooltip: isDarkMode ? 'Switch to day mode' : 'Switch to night mode', onPressed: onToggleTheme, icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: t.mutedText)),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final double size;
  const _BrandMark({required this.size});
  @override
  Widget build(BuildContext context) => _BloomMark(size: size);
}
