import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'human_residence_store.dart';
import 'presentation/api_client.dart';
import 'presentation/criterivox_theme.dart';

class ResultsJournalPage extends StatefulWidget {
  final VoidCallback? onDecisionDesk;
  const ResultsJournalPage({super.key, this.onDecisionDesk});
  @override State<ResultsJournalPage> createState() => _ResultsJournalPageState();
}

class _ResultsJournalPageState extends State<ResultsJournalPage> {
  final store = HumanResidenceStore();
  HumanResidenceRecord? residence;
  List<Map<String, dynamic>> entries = [];
  bool loading = true;
  String status = '';

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await store.load();
    if (!mounted) return;
    setState(() { residence = r; loading = true; });
    if (r == null) {
      setState(() { loading = false; status = 'Sign in to see saved decisions.'; });
      return;
    }
    final token = r.metadata['session_token']?.toString() ?? '';
    if (token.isEmpty) {
      setState(() { loading = false; status = 'This residence has no active session. Open Human Territory and sign in again.'; });
      return;
    }
    try {
      final response = await http.get(
        CriterivoxApi.uri('/api/human-decisions?session_token=' + Uri.encodeQueryComponent(token)),
      ).timeout(const Duration(seconds: 8));
      final body = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300 || body is! Map) {
        throw Exception(body is Map ? body['error'] ?? 'Could not load decisions' : 'Could not load decisions');
      }
      final raw = body['decisions'];
      entries = raw is List ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : [];
      setState(() { loading = false; status = ''; });
    } catch (e) {
      setState(() { loading = false; status = 'Could not load the saved decision record: ${e.toString().replaceFirst('Exception: ', '')}'; });
    }
  }

  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return SingleChildScrollView(
      key: const ValueKey('results-journal'),
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('RESULTS JOURNAL', style: TextStyle(color: t.primary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.8)),
        const SizedBox(height: 6),
        Text('Your decision record', style: TextStyle(color: t.text, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('This records what Criterivox considered and what the human decided. Real-world outcomes appear only when they are actually recorded.', style: TextStyle(color: t.mutedText, fontSize: 12, height: 1.45)),
        const SizedBox(height: 18),
        if (loading) _panel(t, 'LOADING', const LinearProgressIndicator()),
        if (!loading && status.isNotEmpty) _panel(t, 'STATUS', Text(status, style: TextStyle(color: t.mutedText, fontSize: 11))),
        if (!loading && entries.isEmpty && status.isEmpty) _panel(t, 'NO SAVED DECISIONS', Text('Run a situation through Decision Desk while signed in. The strategy will be saved here automatically.', style: TextStyle(color: t.mutedText, fontSize: 11))),
        for (final e in entries) Padding(padding: const EdgeInsets.only(bottom: 12), child: _entry(t, e)),
        if (widget.onDecisionDesk != null) OutlinedButton.icon(onPressed: widget.onDecisionDesk, icon: const Icon(Icons.fact_check_outlined), label: const Text('Open Decision Desk')),
      ]),
    );
  }

  Widget _entry(CriterivoxTheme t, Map<String, dynamic> e) {
    final strategy = e['strategy'] is Map ? Map<String, dynamic>.from(e['strategy']) : <String, dynamic>{};
    final options = strategy['options'] is List ? strategy['options'] as List : const [];
    return _panel(t, (e['title'] ?? 'Decision').toString(), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _v(t, 'Goal', e['goal']),
      if (options.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('Strategy options', style: TextStyle(color: t.primary, fontWeight: FontWeight.w800, fontSize: 10)),
        const SizedBox(height: 6),
        for (final raw in options.whereType<Map>()) Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text('• ${raw['label'] ?? 'Option'}: ${raw['approach'] ?? ''}', style: TextStyle(color: t.text, fontSize: 10, height: 1.4)),
        ),
      ],
      const SizedBox(height: 8),
      _v(t, 'Recorded', e['created_at']),
      _v(t, 'Decision ID', e['decision_id']),
      Text('Outcome is not assumed. It must be recorded separately after the real-world result is known.', style: TextStyle(color: t.mutedText, fontSize: 9, height: 1.4)),
    ]));
  }

  Widget _v(CriterivoxTheme t, String label, dynamic value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: t.primary, fontWeight: FontWeight.w800, fontSize: 10)),
      Text((value ?? '').toString(), style: TextStyle(color: t.text, fontSize: 11, height: 1.4)),
    ]),
  );

  Widget _panel(CriterivoxTheme t, String title, Widget child) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: t.primary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      const SizedBox(height: 10),
      child,
    ]),
  );
}
