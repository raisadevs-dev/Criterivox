import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReasoningResearchBureauPage extends StatefulWidget {
  const ReasoningResearchBureauPage({super.key});
  @override
  State<ReasoningResearchBureauPage> createState() => _S7State();
}

class _S7State extends State<ReasoningResearchBureauPage> {
  final _task = TextEditingController(text: 'Compare two possible explanations for the supplied observation.');
  final _context = TextEditingController(text: 'Local synthetic research context supplied by the human.');
  String _room = 'collaboration';
  Map<String, dynamic>? _session;
  bool _busy = false;
  String? _error;

  Future<void> _start() async {
    setState(() { _busy = true; _error = null; });
    try {
      final response = await http.post(Uri.parse('http://127.0.0.1:8017/api/s7/sessions'), headers: {'content-type': 'application/json'}, body: jsonEncode({'task': _task.text, 'context': {'description': _context.text}}));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) throw Exception(body['error'] ?? 'S7 request failed');
      setState(() => _session = body);
    } catch (e) {
      setState(() => _error = 'S7 runtime unavailable: $e');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _challenge(String artifactId) async {
    final challenge = await showDialog<String>(context: context, builder: (context) => _ChallengeDialog());
    if (challenge == null || challenge.trim().isEmpty || _session == null) return;
    setState(() => _busy = true);
    try {
      final id = _session!['session_id'];
      final response = await http.post(Uri.parse('http://127.0.0.1:8017/api/s7/sessions/$id/challenge'), headers: {'content-type': 'application/json'}, body: jsonEncode({'artifact_id': artifactId, 'challenge': challenge}));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) throw Exception(body['error'] ?? 'Challenge failed');
      setState(() => _session = body);
    } catch (e) { setState(() => _error = '$e'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) {
    final artifacts = (_session?['artifacts'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final events = (_session?['events'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return Scaffold(
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff090a18), Color(0xff171127), Color(0xff080d16)]))),
        SafeArea(child: Column(children: [
          _topBar(),
          Expanded(child: Row(children: [
            _roomRail(),
            Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: _roomContent(artifacts, events))),
          ])),
        ])),
        if (_busy) const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator()),
      ]),
    );
  }

  Widget _topBar() => Padding(padding: const EdgeInsets.fromLTRB(24, 18, 24, 14), child: Row(children: [
    const Icon(Icons.hub_rounded, color: Color(0xffc6b4ff), size: 28),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('REASONING RESEARCH BUREAU', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 1.2)), Text('S7 • computational intelligence environment', style: TextStyle(color: Colors.white54, fontSize: 12))])),
    _statusChip(),
  ]));

  Widget _statusChip() => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .07), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)), child: Text(_session?['status']?.toString().toUpperCase() ?? 'READY', style: const TextStyle(fontSize: 11, letterSpacing: .8)));

  Widget _roomRail() => SizedBox(width: 150, child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
    _roomButton('collaboration', Icons.groups_rounded, 'Collaboration'),
    _roomButton('vivren', Icons.visibility_rounded, 'Vivren'),
    _roomButton('tarkis', Icons.account_tree_rounded, 'Tarkis'),
    const Spacer(),
    const Text('3 ROOMS', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
  ])));

  Widget _roomButton(String id, IconData icon, String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Material(color: _room == id ? Colors.white.withValues(alpha: .11) : Colors.transparent, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: () => setState(() => _room = id), borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Row(children: [Icon(icon, size: 19, color: _room == id ? const Color(0xffc6b4ff) : Colors.white54), const SizedBox(width: 9), Flexible(child: Text(label, style: TextStyle(color: _room == id ? Colors.white : Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)))])))));

  Widget _roomContent(List<Map<String, dynamic>> artifacts, List<Map<String, dynamic>> events) {
    if (_room == 'vivren') return _inspectionRoom(artifacts);
    if (_room == 'tarkis') return _explorationRoom(artifacts);
    return _collaborationRoom(artifacts, events);
  }

  Widget _collaborationRoom(List<Map<String, dynamic>> artifacts, List<Map<String, dynamic>> events) => Padding(padding: const EdgeInsets.fromLTRB(8, 8, 24, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _hero('COLLABORATION ROOM', 'Observe • inspect • compare • challenge • intervene', const Color(0xffc6b4ff)),
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 3, child: _glass('ANALYTICAL REQUEST', Column(children: [TextField(controller: _task, maxLines: 3, decoration: const InputDecoration(labelText: 'Task')), const SizedBox(height: 10), TextField(controller: _context, maxLines: 2, decoration: const InputDecoration(labelText: 'Context')), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: _busy ? null : _start, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Run analysis')))]))),
      const SizedBox(width: 14),
      Expanded(flex: 4, child: _glass('SHARED INTELLIGENCE', artifacts.isEmpty ? const _EmptyState() : _artifactList(artifacts))),
    ]),
    if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12))),
  ]));

  Widget _inspectionRoom(List<Map<String, dynamic>> artifacts) => Padding(padding: const EdgeInsets.fromLTRB(8, 8, 24, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_hero('VIVREN ROOM', 'Critical inspection • assumptions • defects • epistemic boundaries', const Color(0xffb9a4ff)), Expanded(child: _glass('CRITICAL INSPECTION', artifacts.isEmpty ? const _EmptyState() : _artifactList(artifacts, filter: {'evaluation', 'limitation'})))]));

  Widget _explorationRoom(List<Map<String, dynamic>> artifacts) => Padding(padding: const EdgeInsets.fromLTRB(8, 8, 24, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_hero('TARKIS ROOM', 'Explore • branch • compare • reflect • refine', const Color(0xffffbd72)), Expanded(child: _glass('HYPOTHESIS / BRANCH EXPLORATION', artifacts.isEmpty ? const _EmptyState() : _artifactList(artifacts, filter: {'hypothesis', 'reasoning', 'result'})))]));

  Widget _hero(String title, String subtitle, Color accent) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: [Container(width: 4, height: 44, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12))])])));

  Widget _glass(String title, Widget child) => Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .055), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: .10))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700)), const SizedBox(height: 12), Expanded(child: child)]));

  Widget _artifactList(List<Map<String, dynamic>> artifacts, {Set<String>? filter}) { final shown = filter == null ? artifacts : artifacts.where((a) => filter.contains(a['kind'])).toList(); return ListView.separated(itemCount: shown.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) { final a = shown[i]; return ListTile(tileColor: Colors.white.withValues(alpha: .035), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), title: Text('${a['title']}  ·  v${a['version']}'), subtitle: Text('${a['kind']}  •  branch ${a['branch_id']}\n${a['content']}'), trailing: IconButton(tooltip: 'Challenge', onPressed: () => _challenge(a['artifact_id']), icon: const Icon(Icons.gavel_rounded, size: 19)); }); }
}

class _EmptyState extends StatelessWidget { const _EmptyState(); @override Widget build(BuildContext context) => const Center(child: Text('No analytical activity yet. Submit a task to begin.', style: TextStyle(color: Colors.white38))); }

class _ChallengeDialog extends StatelessWidget {
  final _controller = TextEditingController();
  _ChallengeDialog({super.key});
  @override Widget build(BuildContext context) => AlertDialog(title: const Text('Challenge analytical artifact'), content: TextField(controller: _controller, maxLines: 4, decoration: const InputDecoration(hintText: 'State the substantive challenge...')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('Record challenge'))]);
}
