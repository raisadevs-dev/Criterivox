import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'presentation/criterivox_theme.dart';
import 'human_residence_store.dart';
import 'package:http/http.dart' as http;

class DecisionHistoryPage extends StatefulWidget {
  final VoidCallback? onBack;
  const DecisionHistoryPage({super.key, this.onBack});
  @override State<DecisionHistoryPage> createState() => _DecisionHistoryPageState();
}
class _DecisionHistoryPageState extends State<DecisionHistoryPage> {
  final query = TextEditingController();
  final List<Map<String,dynamic>> decisions = [];
  final HumanResidenceStore store = HumanResidenceStore();
  String status = 'Previous decisions are stored locally in Criterivox SQLite.';
  @override void initState(){ super.initState(); _load(); }
  @override void dispose(){ query.dispose(); super.dispose(); }
  Future<void> _load() async {
    final residence = await store.load();
    final token = residence?.metadata['session_token']?.toString();
    if(token == null) { if(mounted) setState(()=>status='No authenticated Human Residence session is available.'); return; }
    try {
      final response = await http.get(Uri.base.resolve('/api/human-decisions?session_token=${Uri.encodeQueryComponent(token)}&query=${Uri.encodeQueryComponent(query.text.trim())}'));
      if(response.statusCode < 200 || response.statusCode >= 300) throw Exception();
      final body=jsonDecode(response.body) as Map<String,dynamic>;
      final raw=body['decisions'];
      if(mounted) setState(()=>decisions..clear()..addAll(raw is List ? raw.whereType<Map>().map((e)=>Map<String,dynamic>.from(e)) : const []));
    } catch (_) { if(mounted) setState(()=>status='Local decision history could not be read from Python SQLite.'); }
  }

  Future<void> _download(Map<String,dynamic> d, String ext) async {
    final payload = <String,dynamic>{'decision':d,'strategy':d['strategy'] ?? {},'trace':d['trace'] ?? []};
    final text = ext == 'json'
      ? const JsonEncoder.withIndent('  ').convert(payload)
      : '# Criterivox Strategy\n\nGoal: ${d['goal'] ?? ''}\n\nStrategy\n${d['strategy'] ?? {}}\n\nTrace\n${d['trace'] ?? []}';
    await FilePicker.platform.saveFile(fileName:'criterivox-decision.$ext',bytes:utf8.encode(text));
  }

  @override Widget build(BuildContext context){
    final t=CriterivoxTheme.of(context);
    return SingleChildScrollView(
      padding:const EdgeInsets.all(24),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(children:[
          if(widget.onBack!=null) IconButton(onPressed:widget.onBack,icon:const Icon(Icons.arrow_back_rounded)),
          Text('PREVIOUS DECISIONS',style:TextStyle(color:t.primary,fontWeight:FontWeight.w900,letterSpacing:1.2)),
        ]),
        const SizedBox(height:12),
        TextField(controller:query,onSubmitted:(_)=>_load(),decoration:const InputDecoration(prefixIcon:Icon(Icons.search_rounded),labelText:'Find a previous decision')),
        const SizedBox(height:16),
        Text(status,style:TextStyle(color:t.mutedText,fontSize:11)),
        const SizedBox(height:12),
        if(decisions.isEmpty) Text('No decisions are loaded into this session view yet.',style:TextStyle(color:t.mutedText)),
        ...decisions.map((d)=>Container(
          margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(16),
          decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(18),border:Border.all(color:t.border)),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text((d['title'] ?? 'Criterivox Strategy').toString(),style:TextStyle(color:t.text,fontWeight:FontWeight.w800)),
            const SizedBox(height:5), Text((d['goal'] ?? '').toString(),style:TextStyle(color:t.mutedText,fontSize:10)),
            const SizedBox(height:10),
            Wrap(spacing:8,children:[
              OutlinedButton(onPressed:()=>_download(d,'md'),child:const Text('Markdown')),
              OutlinedButton(onPressed:()=>_download(d,'json'),child:const Text('JSON')),
              OutlinedButton(onPressed:()=>_download(d,'txt'),child:const Text('Text')),
            ]),
          ]),
        )),
      ]),
    );
  }
}
