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
  final bool connectRuntime;
  final CharacterRuntimeClient? runtimeClient;

  const CriterivoxShell({super.key, this.isDarkMode = true, this.onToggleTheme = _noop, this.connectRuntime = true, this.runtimeClient});
  static void _noop() {}

  @override
  State<CriterivoxShell> createState() => _ShellState();
}

class _ShellState extends State<CriterivoxShell> {
  late final CharacterRuntimeClient runtime = widget.runtimeClient ?? CharacterRuntimeClient();
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
    _errorSubscription = runtime.errors.listen((error) {
      if (!mounted) return;
      setState(() => busy = false);
      ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(error)));
    });
    if (widget.connectRuntime) runtime.connect();
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _errorSubscription.cancel();
    if (widget.runtimeClient == null) runtime.dispose();
    task.dispose(); data.dispose(); ctx.dispose();
    super.dispose();
  }

  void open(String value) => setState(() => page = value);

  void showReserved(String capability) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text('$capability is reserved for a future capability sprint.')));
  }

  void handleBloomCapability(BloomCapability capability) {
    if (capability == BloomCapability.analyze) return;
    showReserved(Bloom.labels[capability]!);
  }

  void send(String message, {String? target}) {
    final selected = target ?? chatTarget;
    setState(() { busy = true; chatTarget = selected; });
    runtime.sendChat(message: message, targetCharacter: selected, taskId: state?.taskId, data: {'dataset': data.text, 'records': 3}, context: {'description': ctx.text, 'origin': selected == 'dharen' ? 'Direct Dharen Chat' : 'Syvax Routing'});
  }

  void start() {
    final taskText = task.text.trim();
    if (taskText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter an analysis task before starting.')));
      return;
    }
    setState(() => busy = true);
    runtime.requestApplication(intent: 'analyze', task: taskText, data: {'dataset': data.text, 'records': 3}, context: {'description': ctx.text, 'origin': 'Analysis Workspace'}, source: 'workspace');
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Scaffold(
      backgroundColor: t.page,
      body: SafeArea(child: Row(children: [
        _Sidebar(page: page, expanded: railOpen, onOpen: open, onReserved: showReserved, onToggle: () => setState(() => railOpen = !railOpen)),
        Expanded(child: Column(children: [
          _TopBar(isDarkMode: widget.isDarkMode, onToggleTheme: widget.onToggleTheme, connectionLive: state != null, onSearch: (value) { if (value.trim().isNotEmpty && state?.taskId?.toLowerCase() == value.trim().toLowerCase()) open('workspace'); }),
          Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 260), child: page == 'chat'
              ? CharacterChatPage(key: const ValueKey('chat'), state: state, busy: busy, selectedAgent: chatTarget, onSelectAgent: (agent) => setState(() => chatTarget = agent), onSend: (message, agent) => send(message, target: agent), onOpenTask: () => open('workspace'))
              : page == 'workspace'
                  ? AnalysisPage(key: const ValueKey('workspace'), state: state, busy: busy, task: task, data: data, contextText: ctx, onStart: start, onChat: () => open('chat'))
                  : BloomPage(key: const ValueKey('bloom'), state: state, onCapability: handleBloomCapability, onSub: (value) => open(value == BloomSuboption.workspace ? 'workspace' : 'chat'), onSyvax: (message) => send(message, target: 'syvax'), busy: busy))),
        ])),
      ])),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String page; final bool expanded; final ValueChanged<String> onOpen; final ValueChanged<String> onReserved; final VoidCallback onToggle;
  const _Sidebar({required this.page, required this.expanded, required this.onOpen, required this.onReserved, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context); final width = expanded ? 244.0 : 76.0;
    return AnimatedContainer(duration: const Duration(milliseconds: 240), width: width, decoration: BoxDecoration(color: t.surface.withValues(alpha: .96), border: Border(right: BorderSide(color: t.border))), child: Column(children: [
      Padding(padding: EdgeInsets.fromLTRB(expanded ? 18 : 10, 18, 10, 14), child: Row(children: [const _BrandMark(size: 34), if (expanded) ...[const SizedBox(width: 10), Expanded(child: Text('Criterivox', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)))], IconButton(tooltip: expanded ? 'Collapse sidebar' : 'Open sidebar', onPressed: onToggle, icon: Icon(expanded ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: t.mutedText))])),
      Expanded(child: Scrollbar(thumbVisibility: expanded, child: SingleChildScrollView(padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8), child: Column(children: [
        _StatusCard(expanded: expanded), const SizedBox(height: 18),
        _section('NAVIGATION', expanded, t),
        _nav('Bloom', Icons.auto_awesome_rounded, page == 'bloom', () => onOpen('bloom'), expanded, t),
        _nav('Analysis Workspace', Icons.dashboard_customize_rounded, page == 'workspace', () => onOpen('workspace'), expanded, t),
        _nav('Character Chat', Icons.forum_rounded, page == 'chat', () => onOpen('chat'), expanded, t),
        const SizedBox(height: 16),
        _section('FUTURE CAPABILITIES', expanded, t),
        _nav('Compare', Icons.balance_rounded, false, () => onReserved('Compare'), expanded, t),
        _nav('Explore', Icons.search_rounded, false, () => onReserved('Explore'), expanded, t),
        _nav('Plan', Icons.calendar_month_rounded, false, () => onReserved('Plan'), expanded, t),
        _nav('Insights', Icons.lightbulb_outline_rounded, false, () => onReserved('Insights'), expanded, t),
        _nav('Explain', Icons.chat_bubble_outline_rounded, false, () => onReserved('Explain'), expanded, t),
        if (expanded) Padding(padding: const EdgeInsets.all(10), child: Text('Navigation moves between surfaces. Bloom provides capability discovery; it does not duplicate this traffic-control layer.', style: TextStyle(color: t.mutedText, fontSize: 10, height: 1.45))),
      ]))),
    ]));
  }
  Widget _section(String text, bool visible, CriterivoxTheme t) => visible ? Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.fromLTRB(10, 4, 10, 6), child: Text(text, style: TextStyle(color: t.mutedText, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.1)))) : const SizedBox(height: 8);
  Widget _nav(String label, IconData icon, bool active, VoidCallback onTap, bool visible, CriterivoxTheme t) => Material(color: Colors.transparent, child: Tooltip(message: visible ? '' : label, child: ListTile(onTap: onTap, selected: active, dense: true, horizontalTitleGap: 12, contentPadding: EdgeInsets.symmetric(horizontal: visible ? 10 : 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), selectedTileColor: t.primary.withValues(alpha: .13), leading: Icon(icon, size: 19, color: active ? t.primary : t.mutedText), title: visible ? Text(label, style: TextStyle(color: active ? t.text : t.mutedText, fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500)) : null)));
}

class _StatusCard extends StatelessWidget {
  final bool expanded; const _StatusCard({required this.expanded});
  @override
  Widget build(BuildContext context) { final t = CriterivoxTheme.of(context); return Container(padding: EdgeInsets.all(expanded ? 14 : 10), decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)), child: Row(children: [Icon(Icons.auto_awesome_rounded, color: t.primary, size: 19), if (expanded) ...[const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('RUNTIME', style: TextStyle(color: t.mutedText, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1)), const SizedBox(height: 3), Text('Living system', style: TextStyle(color: t.text, fontSize: 11, fontWeight: FontWeight.w600))])), Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: t.success))])); }
}

class _TopBar extends StatelessWidget {
  final bool isDarkMode; final VoidCallback onToggleTheme; final bool connectionLive; final ValueChanged<String> onSearch;
  const _TopBar({required this.isDarkMode, required this.onToggleTheme, required this.connectionLive, required this.onSearch});
  @override
  Widget build(BuildContext context) { final t = CriterivoxTheme.of(context); return Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 10), child: Row(children: [Expanded(child: SizedBox(height: 42, child: TextField(onSubmitted: onSearch, decoration: InputDecoration(prefixIcon: Icon(Icons.search_rounded, color: t.mutedText, size: 19), hintText: 'Search current task by name or ID...')))), const SizedBox(width: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: t.border)), child: Row(children: [Icon(Icons.circle, size: 7, color: connectionLive ? t.success : t.warning), const SizedBox(width: 7), Text(connectionLive ? 'LIVE' : 'CONNECTING', style: TextStyle(color: t.mutedText, fontSize: 9, fontWeight: FontWeight.w700))])), const SizedBox(width: 8), IconButton(tooltip: isDarkMode ? 'Switch to day mode' : 'Switch to night mode', onPressed: onToggleTheme, icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: t.mutedText))])); }
}

class _BrandMark extends StatelessWidget { final double size; const _BrandMark({required this.size}); @override Widget build(BuildContext context) => _BloomMark(size: size); }

class _BloomMark extends StatelessWidget {
  final double size; const _BloomMark({required this.size});
  @override Widget build(BuildContext context) => SizedBox(width: size, height: size, child: Stack(alignment: Alignment.center, children: [for (var i = 0; i < 8; i++) Transform.rotate(angle: i * 3.1415926535 / 4, child: Container(width: size * .22, height: size * .48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF9A7BFF), Color(0xFF6654E8)])))), Container(width: size * .24, height: size * .24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF7D68F7)))]));
}
