import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'presentation/criterivox_theme.dart';

class WorldMapLevel2Part4Page extends StatefulWidget {
  final VoidCallback onBack;
  const WorldMapLevel2Part4Page({super.key, required this.onBack});
  @override
  State<WorldMapLevel2Part4Page> createState() => _WorldMapLevel2Part4PageState();
}

class _WorldMapLevel2Part4PageState extends State<WorldMapLevel2Part4Page> {
  Map<String, dynamic>? _state;
  String? _error;
  bool _loading = true;

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.get(Uri.base.resolve('/api/world/level2/part4/state')).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('HTTP ${response.statusCode}');
      final decoded = jsonDecode(response.body);
      if (!mounted) return;
      setState(() { _state = Map<String, dynamic>.from(decoded as Map); _loading = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _loading = false; _error = error.toString(); });
    }
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final homes = (_state?['homes'] as Map?)?.cast<String, dynamic>() ?? {};
    final rooms = (_state?['rooms'] as Map?)?.cast<String, dynamic>() ?? {};
    final counts = (_state?['counts'] as Map?)?.cast<String, dynamic>() ?? {};
    return Scaffold(
      backgroundColor: t.page,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back_rounded), tooltip: 'Return to Civilization'),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('WORLD MAP • LEVEL 2 PART IV', style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text('Intelligence + Decision & Action', style: TextStyle(color: t.text, fontSize: 26, fontWeight: FontWeight.w900)),
                Text('Hypothesis → audit → handoff → plan → action contract → governed execution', style: TextStyle(color: t.mutedText, fontSize: 11)),
              ])),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
            ]),
            const SizedBox(height: 16),
            if (_loading) LinearProgressIndicator(color: t.primary),
            if (_error != null) _card(t, 'RUNTIME UNAVAILABLE', Text(_error!, style: TextStyle(color: t.mutedText, fontSize: 11))),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _homeCard(t, homes['intelligence'] as Map?, 'INTELLIGENCE • VIVREN + TARKIS')),
              const SizedBox(width: 12),
              Expanded(child: _homeCard(t, homes['decision'] as Map?, 'DECISION & ACTION • PRAMON + BODHEX')),
            ]),
            const SizedBox(height: 14),
            _card(t, 'LIVE CAPABILITY COUNTS', Wrap(spacing: 8, runSpacing: 8, children: counts.entries.map((e) => _chip(t, '${e.key}: ${e.value}')).toList())),
            const SizedBox(height: 14),
            _card(t, 'CANONICAL ROOMS', Column(children: rooms.entries.map((entry) {
              final value = Map<String, dynamic>.from(entry.value as Map);
              return ListTile(
                dense: true, contentPadding: EdgeInsets.zero,
                title: Text(entry.key, style: TextStyle(color: t.text, fontWeight: FontWeight.w800, fontSize: 12)),
                subtitle: Text('${value['owner']} • ${value['truth']}', style: TextStyle(color: t.mutedText, fontSize: 10)),
                trailing: _chip(t, value['truth'].toString()),
              );
            }).toList())),
            const SizedBox(height: 14),
            _card(t, 'ARCHITECTURE RULE', Text('Part IV integrates Parts I–III. It does not create replacement routing, collaboration, evidence, sandbox, replay, or telemetry engines.', style: TextStyle(color: t.mutedText, fontSize: 11, height: 1.4))),
          ]),
        )),
      )),
    );
  }

  Widget _homeCard(CriterivoxTheme t, Map<String, dynamic>? home, String title) {
    final rooms = (home?['rooms'] as List?)?.length ?? 0;
    return _card(t, title, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Resident: ${home?['resident'] ?? '-'}', style: TextStyle(color: t.text, fontWeight: FontWeight.w800)),
      Text('Partner: ${home?['partner'] ?? '-'}', style: TextStyle(color: t.mutedText, fontSize: 10)),
      const SizedBox(height: 8),
      _chip(t, '${rooms} canonical rooms'),
      const SizedBox(height: 8),
      Text('Truth: ${home?['truth'] ?? '-'}', style: TextStyle(color: t.success, fontSize: 10, fontWeight: FontWeight.w700)),
    ]));
  }

  Widget _card(CriterivoxTheme t, String title, Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: t.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
      const SizedBox(height: 10), child,
    ]),
  );

  Widget _chip(CriterivoxTheme t, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.border)),
    child: Text(text, style: TextStyle(color: t.text, fontSize: 9, fontWeight: FontWeight.w700)),
  );
}
