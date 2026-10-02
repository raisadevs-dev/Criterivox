import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../human/residence/store.dart';
import '../../presentation/shared/api_client.dart';
import '../../presentation/shared/criterivox_theme.dart';

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
      _loadLocalDraft(r, 'Local-only result. Sign in to sync and retrieve server-saved decisions.');
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
      _loadLocalDraft(r, 'Server record unavailable. Showing locally saved work where available. ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  void _loadLocalDraft(HumanResidenceRecord r, String message) {
    final metadata = r.metadata;
    final rawStrategy = metadata['decision_support_strategy'];
    final strategy = rawStrategy is Map ? Map<String, dynamic>.from(rawStrategy) : <String, dynamic>{};
    final goal = metadata['goal']?.toString() ?? '';
    final statusValue = metadata['decision_support_last_status']?.toString() ?? '';
    if (goal.isNotEmpty && strategy.isNotEmpty) {
      entries = [<String, dynamic>{'title': 'Recent local decision', 'goal': goal, 'strategy': strategy, 'trace': metadata['decision_support_trace'] is List ? metadata['decision_support_trace'] : [], 'decision_id': metadata['decision_support_decision_id'], 'local_only': true, 'status': statusValue}];
    }
    if (!mounted) return;
    setState(() { loading = false; status = message; });
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
      if (e['local_only'] == true) Container(padding: const EdgeInsets.all(8), margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(9)), child: Text('LOCAL COPY • NOT SYNCED', style: TextStyle(color: t.primary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),),
      _v(t, 'Goal', e['goal']),
      if (options.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('CRITERIVOX STRATEGY PACKAGE', style: TextStyle(color: t.primary, fontWeight: FontWeight.w800, fontSize: 10)),
        const SizedBox(height: 6),
        for (var i = 0; i < options.length; i++)
          if (options[i] is Map) _strategyCard(t, Map<String,dynamic>.from(options[i] as Map), i),
      ],
      if (strategy['challenges'] is List && (strategy['challenges'] as List).isNotEmpty)
        _v(t, 'Challenges to review', (strategy['challenges'] as List).map((x) => '• $x').join('\\n')),
      if (e['trace'] is List && (e['trace'] as List).isNotEmpty)
        _v(t, 'Recorded execution', (e['trace'] as List).whereType<Map>().map((x) => '${x['agent_label'] ?? x['actor'] ?? x['agent'] ?? 'Step'}: ${x['detail'] ?? x['summary'] ?? ''}').join('\\n')),
      if (strategy['research'] is Map) _v(t, 'Research record', strategy['research']),
      const SizedBox(height: 8),
      _v(t, 'Recorded', e['created_at']),
      _v(t, 'Decision ID', e['decision_id']),
      Text('Outcome is not assumed. It must be recorded separately after the real-world result is known.', style: TextStyle(color: t.mutedText, fontSize: 9, height: 1.4)),
    ]));
  }

  String _value(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is num || value is bool) return value.toString();
    return const JsonEncoder.withIndent('  ').convert(value);
  }

  Widget _strategyCard(CriterivoxTheme t, Map<String,dynamic> option, int index) {
    Widget textField(String title, dynamic value) {
      final text = _value(value);
      if (text.isEmpty) return const SizedBox.shrink();
      return Padding(padding: const EdgeInsets.only(top:7), child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,style:TextStyle(color:t.primary,fontSize:9,fontWeight:FontWeight.w800)),
        const SizedBox(height:2),
        Text(text,style:TextStyle(color:t.text,fontSize:10,height:1.4)),
      ]));
    }
    Widget listField(String title,dynamic raw) {
      if(raw is! List || raw.isEmpty)return const SizedBox.shrink();
      return textField(title,raw.map((x)=>'• ${_value(x)}').join('\\n'));
    }
    final tradeoffs=option['tradeoffs'];
    final generatedBy=option['generated_by'] is Map?(option['generated_by'] as Map)['agent_label']?.toString():null;
    return Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:t.surfaceStrong,borderRadius:BorderRadius.circular(12),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('${index+1}. ${_value(option['label']).isEmpty?'Strategy':_value(option['label'])}',style:TextStyle(color:t.text,fontWeight:FontWeight.w800,fontSize:11)),
      if(generatedBy!=null)Text('GENERATED BY $generatedBy',style:TextStyle(color:t.primary,fontSize:8,fontWeight:FontWeight.w900,letterSpacing:.5)),
      textField('OBJECTIVE',option['objective']),
      textField('APPROACH',option['approach']),
      listField('STEPS',option['steps']),
      listField('BENEFITS',option['benefits']),
      if(tradeoffs is Map)textField('TRADE-OFFS',tradeoffs),
      textField('RISKS',option['risk']),
      textField('EVIDENCE BASIS',option['evidence_basis']),
      listField('EVIDENCE / SOURCES',option['evidence']),
      listField('ASSUMPTIONS',option['assumptions']),
      textField('CONTINGENCY',option['contingency']),
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
