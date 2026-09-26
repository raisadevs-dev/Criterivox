import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'presentation/criterivox_theme.dart';
import 'presentation/runtime_client.dart';

class WorldMapLevel2Part1Page extends StatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<String>? onOpenCharacter;
  final ValueChanged<String>? onOpenHome;
  const WorldMapLevel2Part1Page({super.key, required this.onBack, this.onOpenCharacter, this.onOpenHome});
  @override State<WorldMapLevel2Part1Page> createState() => _WorldMapLevel2Part1PageState();
}

class _WorldMapLevel2Part1PageState extends State<WorldMapLevel2Part1Page> {
  Map<String, dynamic>? model;
  Map<String, dynamic>? network;
  String? selectedCharacter;
  String? selectedHome;
  String status = 'LOADING';
  String truth = 'LIVE';
  final intent = TextEditingController(text: 'inspect current collaboration');
  final contextInput = TextEditingController(text: 'task, constraints, relevant evidence');

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { intent.dispose(); contextInput.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final a = await http.get(_runtimeUri('/api/world/level2/roster'));
      final b = await http.get(_runtimeUri('/api/world/level2/network'));
      if (a.statusCode < 200 || a.statusCode >= 300) throw Exception();
      if (!mounted) return;
      setState(() {
        model = jsonDecode(a.body) as Map<String, dynamic>;
        network = b.statusCode >= 200 ? jsonDecode(b.body) as Map<String, dynamic> : null;
        status = 'READY';
        truth = model?['truth']?.toString() ?? 'LIVE';
      });
    } catch (_) {
      if (mounted) setState(() { status = 'UNAVAILABLE'; model = null; });
    }
  }

  Future<void> _handshake() async {
    final source = selectedCharacter ?? 'syvax';
    final homes = (model?['homes'] as List? ?? const []).cast<Map>();
    final selected = homes.firstWhere((h) => h['home_id'] == selectedHome, orElse: () => {'residents': ['dharen']});
    final residents = selected['residents'] as List? ?? const ['dharen'];
    final destination = residents.isEmpty ? 'dharen' : residents.first.toString();
    try {
      final r = await http.post(
        _runtimeUri('/api/world/level2/handshake'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'source': source, 'destination': destination, 'intent': intent.text.trim(),
          'simulation': true, 'required_context': {'description': contextInput.text.trim()},
        }),
      );
      if (!mounted) return;
      if (r.statusCode >= 200 && r.statusCode < 300) {
        setState(() { network = jsonDecode(r.body) as Map<String, dynamic>; truth = 'SIMULATED'; status = 'SIMULATED HANDSHAKE COMPLETE'; });
      } else { setState(() => status = 'HANDSHAKE FAILED'); }
    } catch (_) { if (mounted) setState(() => status = 'HANDSHAKE UNAVAILABLE'); }
  }

  Uri _runtimeUri(String path) => Uri.base.resolve(path);

  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    if (model == null) {
      return _shell(t, [_header(t), _truth(t, 'NO LIVE MODEL', 'The runtime could not be reached. No live state is fabricated.'), FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry'))]);
    }
    final homes = (model!['homes'] as List? ?? const []).cast<Map>().map((x) => Map<String,dynamic>.from(x)).toList();
    final chars = (model!['characters'] as List? ?? const []).cast<Map>().map((x) => Map<String,dynamic>.from(x)).toList();
    final rels = (model!['relationships'] as List? ?? const []).cast<Map>().map((x) => Map<String,dynamic>.from(x)).toList();
    return _shell(t, [
      _header(t), _truth(t, truth, 'LIVE, SIMULATED, HISTORICAL and PLANNED states are kept distinct.'), const SizedBox(height: 14),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _card(t, 'SPATIAL ROSTER · ALL 15 RESIDENTS', [
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final h in homes) ChoiceChip(label: Text(h['name'].toString()), selected: selectedHome == h['home_id'], onSelected: (_) => setState(() { selectedHome = h['home_id'].toString(); selectedCharacter = null; })),
            ChoiceChip(label: const Text('ANUKOR · NETWORK'), selected: selectedCharacter == 'anukor', onSelected: (_) => setState(() { selectedCharacter = 'anukor'; selectedHome = null; })),
          ]),
          const Divider(),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final c in chars) ActionChip(label: Text(c['name'].toString()), onPressed: () { setState(() => selectedCharacter = c['character_id'].toString()); widget.onOpenCharacter?.call(c['character_id'].toString()); }),
          ]),
          const SizedBox(height: 8),
          Text('Home selection and character selection are distinct. Anukor has no permanent Home.', style: TextStyle(color: t.mutedText, fontSize: 10)),
        ])),
        const SizedBox(width: 12),
        Expanded(child: _briefing(t, chars)),
      ]),
      const SizedBox(height: 12),
      _card(t, 'ANUKOR · NETWORK INSPECTION', [
        Wrap(spacing: 7, children: [
          _metric(t, 'routes', ((network?['routes'] as List?)?.length ?? 0).toString()),
          _metric(t, 'envelopes', ((network?['envelopes'] as List?)?.length ?? 0).toString()),
          _metric(t, 'traces', ((network?['traces'] as List?)?.length ?? 0).toString()),
        ]),
        const Divider(),
        Wrap(spacing: 6, runSpacing: 6, children: [for (final r in rels) Chip(label: Text(r['source'].toString() + ' → ' + r['target'].toString() + ' · ' + r['kind'].toString(), style: const TextStyle(fontSize: 9)))]),
        const SizedBox(height: 7),
        Text('Loop protection, dynamic edge metrics, protocol translation, distributed trace, event dispatch and controlled parallel routing are backed by the development runtime; parallel execution is explicitly labelled LIVE_SIMULATION.', style: TextStyle(color: t.mutedText, fontSize: 10)),
      ]),
      const SizedBox(height: 12),
      _card(t, 'CROSS-HOME HANDSHAKE · SAFE SANDBOX', [
        TextField(controller: intent, decoration: const InputDecoration(labelText: 'Test intent', border: OutlineInputBorder())),
        const SizedBox(height: 7),
        TextField(controller: contextInput, decoration: const InputDecoration(labelText: 'Required context only', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Text('SIMULATION ONLY · never presented as production', style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w800))),
          FilledButton.icon(onPressed: _handshake, icon: const Icon(Icons.route), label: const Text('Run')),
        ]),
        if (network?['route'] != null) ...[
          const Divider(),
          Text('Route truth: ' + network!['route']['truth'].toString(), style: TextStyle(color: t.text, fontWeight: FontWeight.w800)),
          Text(network!['route']['source'].toString() + ' → ' + network!['route']['destination'].toString() + ' · trace ' + network!['route']['trace_id'].toString(), style: TextStyle(color: t.mutedText, fontSize: 10)),
        ],
      ]),
      const SizedBox(height: 12),
      _card(t, 'ANUKOR CAPABILITY MATRIX', [
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final e in ((network?['capabilities'] as Map?)?.entries ?? const <MapEntry<String,dynamic>>[]))
            Chip(label: Text(e.key.replaceAll('_', ' ') + ' · ' + e.value.toString(), style: const TextStyle(fontSize: 9))),
        ]),
      ]),
      const SizedBox(height: 12),
      _card(t, 'GATE 2 · GUEST PASS BOUNDARY', [
        const Text('Guest Pass is the temporary human entry. Its existing session, TTL, X-Ray and claim APIs remain the single implementation. This page only exposes the architectural boundary.'),
        const SizedBox(height: 8),
        const Wrap(spacing: 6, children: [Chip(label: Text('EPHEMERAL')), Chip(label: Text('ISOLATED')), Chip(label: Text('CLAIM CONFIRMED'))]),
      ]),
      const SizedBox(height: 14),
      Row(children: [Text(status, style: TextStyle(color: t.mutedText, fontSize: 9, fontWeight: FontWeight.w900)), const Spacer(), TextButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 15), label: const Text('Refresh')), TextButton(onPressed: widget.onBack, child: const Text('Back to Bloom'))]),
    ]);
  }

  Widget _shell(CriterivoxTheme t, List<Widget> children) => SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 18, 22, 70), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children));
  Widget _header(CriterivoxTheme t) => Row(children: [IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('LEVEL 2 · PART I', style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4)), Text('Supervision Briefing Control Plane', style: TextStyle(color: t.text, fontSize: 25, fontWeight: FontWeight.w800)), Text('Roster → briefing → relationships → network → guest boundary', style: TextStyle(color: t.mutedText, fontSize: 10))]))]);
  Widget _truth(CriterivoxTheme t, String title, String body) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: t.border)), child: Row(children: [Icon(Icons.verified_outlined, color: t.primary, size: 17), const SizedBox(width: 8), Text(title, style: TextStyle(color: t.primary, fontWeight: FontWeight.w900, fontSize: 9)), const SizedBox(width: 8), Expanded(child: Text(body, style: TextStyle(color: t.mutedText, fontSize: 10)))]));
  Widget _card(CriterivoxTheme t, String title, List<Widget> children) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: t.surface.withValues(alpha: .82), borderRadius: BorderRadius.circular(18), border: Border.all(color: t.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)), const SizedBox(height: 10), ...children]));
  Widget _briefing(CriterivoxTheme t, List<Map<String,dynamic>> chars) { final id = selectedCharacter ?? 'syvax'; final c = chars.firstWhere((x) => x['character_id'] == id, orElse: () => chars.first); return _card(t, 'DIAGNOSTIC BRIEFING', [Text(c['name'].toString(), style: TextStyle(color: t.text, fontSize: 21, fontWeight: FontWeight.w800)), Text(c['role'].toString(), style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text('Home: ' + (c['home_id']?.toString() ?? 'CROSS-HOME NETWORK')), Text(c['responsibility'].toString(), style: TextStyle(color: t.mutedText, fontSize: 10)), const SizedBox(height: 8), Text('Capabilities: ' + ((c['capabilities'] as List?) ?? const []).join(', '), style: TextStyle(color: t.mutedText, fontSize: 10)), const SizedBox(height: 8), const Text('Text/audio/visual/accessibility channels must consume this same model; none may invent runtime facts.')]); }
  Widget _metric(CriterivoxTheme t, String label, String value) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: t.border), borderRadius: BorderRadius.circular(10)), child: Text(label + ': ' + value, style: TextStyle(color: t.text, fontSize: 9, fontWeight: FontWeight.w800)));
}
