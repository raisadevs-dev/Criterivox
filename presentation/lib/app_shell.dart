import 'dart:async';
import 'package:flutter/material.dart';
import 'presentation/runtime_client.dart';
import 'presentation/presentation_state.dart';
import 'presentation/criterivox_theme.dart';
import 'interaction/bloom.dart';
import 'bloom_page.dart';
import 'analysis_page.dart';
import 'chat/character_chat_page.dart';

class CriterivoxShell extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const CriterivoxShell({super.key, required this.isDarkMode, required this.onToggleTheme});

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
      setState(() { state = value; busy = false; });
    });
    _errorSubscription = runtime.errors.listen((_) {
      if (mounted) setState(() => busy = false);
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

  void send(String message, {String? target}) {
    setState(() { busy = true; chatTarget = target ?? chatTarget; });
    runtime.sendChat(
      message: message,
      targetCharacter: target ?? chatTarget,
      taskId: state?.taskId,
      data: {'dataset': data.text, 'records': 3},
      context: {'description': ctx.text, 'origin': target == 'dharen' ? 'Direct Dharen Chat' : 'Syvax Routing'},
    );
  }

  void start() {
    setState(() => busy = true);
    runtime.requestApplication(
      intent: 'analyze', task: task.text,
      data: {'dataset': data.text, 'records': 3},
      context: {'description': ctx.text, 'origin': 'Analysis Workspace'},
      source: 'workspace',
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Scaffold(
      backgroundColor: t.page,
      body: SafeArea(
        child: Row(children: [
          _Sidebar(page: page, expanded: railOpen, onOpen: open, onToggle: () => setState(() => railOpen = !railOpen)),
          Expanded(child: Column(children: [
            _TopBar(isDarkMode: widget.isDarkMode, onToggleTheme: widget.onToggleTheme, connectionLive: state != null),
            Expanded(child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: page == 'chat'
                  ? CharacterChatPage(
                      key: const ValueKey('chat'), state: state, busy: busy,
                      selectedAgent: chatTarget,
                      onSelectAgent: (agent) => setState(() => chatTarget = agent),
                      onSend: (message, agent) => send(message, target: agent),
                      onOpenTask: () => open('workspace'),
                    )
                  : page == 'workspace'
                      ? AnalysisPage(key: const ValueKey('workspace'), state: state, busy: busy, task: task, data: data, contextText: ctx, onStart: start, onChat: () => open('chat'))
                      : BloomPage(key: const ValueKey('bloom'), state: state, onSub: (value) => open(value == BloomSuboption.workspace ? 'workspace' : 'chat'), onSyvax: (message) => send(message, target: 'syvax'), busy: busy),
            )),
          ])),
        ]),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String page;
  final bool expanded;
  final ValueChanged<String> onOpen;
  final VoidCallback onToggle;
  const _Sidebar({required this.page, required this.expanded, required this.onOpen, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final width = expanded ? 244.0 : 76.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240), width: width,
      decoration: BoxDecoration(color: t.surface.withValues(alpha: .94), border: Border(right: BorderSide(color: t.border))),
      child: Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(expanded ? 18 : 10, 18, 10, 14),
          child: Row(children: [
            const _BrandMark(size: 34),
            if (expanded) ...[const SizedBox(width: 10), Expanded(child: Text('Criterivox', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)))],
            IconButton(tooltip: expanded ? 'Collapse sidebar' : 'Open sidebar', onPressed: onToggle, icon: Icon(expanded ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: t.mutedText)),
          ]),
        ),
        Expanded(child: Scrollbar(
          thumbVisibility: expanded,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8),
            child: Column(children: [
              _StatusCard(expanded: expanded), const SizedBox(height: 18),
              _section('CAPABILITIES', expanded, t),
              _nav('Analyze', Icons.bar_chart_rounded, page == 'workspace', () => onOpen('workspace'), expanded, t),
              _nav('Compare', Icons.balance_rounded, false, () {}, expanded, t),
              _nav('Explore', Icons.search_rounded, false, () {}, expanded, t),
              _nav('Plan', Icons.calendar_month_rounded, false, () {}, expanded, t),
              _nav('Insights', Icons.lightbulb_outline_rounded, false, () {}, expanded, t),
              _nav('Explain', Icons.chat_bubble_outline_rounded, false, () => onOpen('chat'), expanded, t),
              const SizedBox(height: 16), _section('QUICK ACTIONS', expanded, t),
              _nav('Bloom', Icons.auto_awesome_rounded, page == 'bloom', () => onOpen('bloom'), expanded, t),
              _nav('Analysis Workspace', Icons.dashboard_customize_rounded, page == 'workspace', () => onOpen('workspace'), expanded, t),
              _nav('Character Chat', Icons.forum_rounded, page == 'chat', () => onOpen('chat'), expanded, t),
              if (expanded) Padding(padding: const EdgeInsets.all(10), child: Text('Choose your path. Syvax can route work, while Dharen remains directly reachable for analysis.', style: TextStyle(color: t.mutedText, fontSize: 10, height: 1.45))),
            ]),
          ),
        )),
      ]),
    );
  }

  Widget _section(String text, bool visible, CriterivoxTheme t) => visible ? Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.fromLTRB(10, 4, 10, 6), child: Text(text, style: TextStyle(color: t.mutedText, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.1)))) : const SizedBox(height: 8);

  Widget _nav(String label, IconData icon, bool active, VoidCallback onTap, bool visible, CriterivoxTheme t) => Tooltip(
    message: visible ? '' : label,
    child: ListTile(
      onTap: onTap, selected: active, dense: true, horizontalTitleGap: 12,
      contentPadding: EdgeInsets.symmetric(horizontal: visible ? 10 : 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedTileColor: t.primary.withValues(alpha: .13),
      leading: Icon(icon, size: 19, color: active ? t.primary : t.mutedText),
      title: visible ? Text(label, style: TextStyle(color: active ? t.text : t.mutedText, fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500)) : null,
    ),
  );
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
      child: Row(children: [const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8F77FF), size: 19), if (expanded) ...[const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Living Interaction', style: TextStyle(color: t.text, fontWeight: FontWeight.w600, fontSize: 12)), SizedBox(height: 3), Text('System active', style: TextStyle(color: t.mutedText, fontSize: 10))])), Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: t.success))]),
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
    return Container(
      height: 78, padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(color: t.page.withValues(alpha: .94), border: Border(bottom: BorderSide(color: t.border))),
      child: Row(children: [
        Expanded(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: Container(
          height: 44,
          decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(15), border: Border.all(color: t.border)),
          child: Row(children: [const SizedBox(width: 14), Icon(Icons.search_rounded, color: Color(0xFF8D94AD), size: 19), const SizedBox(width: 10), Expanded(child: Text('Search anything or press /', style: TextStyle(color: t.mutedText, fontSize: 12))), Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: t.page, borderRadius: BorderRadius.circular(8)), child: Text('⌘ K', style: TextStyle(color: t.mutedText, fontSize: 9)))]),
        ))),
        const Spacer(),
        Tooltip(message: isDarkMode ? 'Switch to day mode' : 'Switch to night mode', child: IconButton(onPressed: onToggleTheme, icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: t.text))),
        IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none_rounded, color: t.text)),
        const SizedBox(width: 8), Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: connectionLive ? t.success : t.warning)), const SizedBox(width: 6), Text(connectionLive ? 'LIVE' : 'CONNECTING', style: TextStyle(color: t.mutedText, fontSize: 9, fontWeight: FontWeight.w700)),
        const SizedBox(width: 14), CircleAvatar(radius: 18, backgroundColor: t.surfaceStrong, child: Icon(Icons.person_outline_rounded, color: t.text, size: 19)),
      ]),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final double size;
  const _BrandMark({required this.size});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: Stack(alignment: Alignment.center, children: [
    for (var i = 0; i < 8; i++) Transform.rotate(angle: i * 3.141592653589793 / 4, child: Container(width: size * .2, height: size * .48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(size), gradient: const LinearGradient(colors: [Color(0xFF9D7BFF), Color(0xFF5C4BE6)])))),
    Container(width: size * .22, height: size * .22, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF7B68F4))),
  ]));
}
