import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'human_residence_store.dart';
import 'presentation/criterivox_theme.dart';

class PrivateRoomPage extends StatefulWidget {
  final VoidCallback onWorkspace;
  const PrivateRoomPage({super.key, required this.onWorkspace});
  @override State<PrivateRoomPage> createState() => _PrivateRoomPageState();
}

class _PrivateRoomPageState extends State<PrivateRoomPage> {
  final store = HumanResidenceStore();
  final goal = TextEditingController();
  final data = TextEditingController();
  final contextCtl = TextEditingController();
  final resultCtl = TextEditingController();
  HumanResidenceRecord? residence;
  bool running = false;
  bool actApproved = false;
  bool secondFactor = false;
  String status = 'PRIVATE_ROOM_READY';
  List<String> options = const [];
  List<String> challenges = const [];
  List<Map<String, dynamic>> journal = [];
  double speed = 50, cost = 50, reliability = 50;

  @override void initState() { super.initState(); _restore(); }
  @override void dispose() { goal.dispose(); data.dispose(); contextCtl.dispose(); resultCtl.dispose(); super.dispose(); }

  Future<void> _restore() async {
    final r = await store.load();
    if (!mounted) return;
    if (r == null) { setState(() => status = 'NO_HOUSE_FOUND'); return; }
    final md = r.metadata;
    final raw = md['results_journal'];
    setState(() {
      residence = r;
      goal.text = '${md['goal'] ?? ''}';
      data.text = '${md['data'] ?? ''}';
      contextCtl.text = '${md['context'] ?? ''}';
      journal = raw is List ? raw.whereType<Map>().map((e) => Map<String,dynamic>.from(e)).toList() : [];
    });
  }

  Map<String, dynamic> _metadata({required String event}) {
    final base = Map<String,dynamic>.from(residence!.metadata);
    base['rooms'] = ['private', 'collaboration'];
    base['private_room_event'] = event;
    base['goal'] = goal.text.trim();
    base['data'] = data.text.trim();
    base['context'] = contextCtl.text.trim();
    base['last_tradeoff'] = {'speed': speed.round(), 'cost': cost.round(), 'reliability': reliability.round()};
    base['results_journal'] = journal;
    return base;
  }

  Future<void> _persist(String event) async {
    final r = residence!;
    final updated = HumanResidenceRecord(residenceId:r.residenceId, ownerId:r.ownerId, displayName:r.displayName, email:r.email, residenceType:r.residenceType, createdAt:r.createdAt, members:r.members, metadata:_metadata(event:event));
    await store.save(updated);
    residence = updated;
    try {
      await http.post(Uri.base.resolve('/api/human-residence'), headers:{'content-type':'application/json'}, body:jsonEncode(updated.toJson())).timeout(const Duration(seconds:4));
      if (mounted) setState(() => status = 'SAVED • IndexedDB authoritative • Python mirror updated');
    } catch (_) { if (mounted) setState(() => status = 'SAVED LOCALLY • IndexedDB authoritative • Python mirror unavailable'); }
  }

  Future<void> _generateOptions() async {
    if (goal.text.trim().isEmpty || running) return;
    setState(() { running = true; status = 'DHAREN + TARKIS + PRAMON • framing and option sparring'; options = []; challenges = []; });
    try {
      final r = await http.post(Uri.base.resolve('/api/syvax/plan'), headers:{'content-type':'application/json'}, body:jsonEncode({'message':goal.text.trim(),'task_id':'private-${residence!.residenceId}'})).timeout(const Duration(seconds:6));
      if (r.statusCode >= 400) throw Exception('planning request rejected (${r.statusCode})');
      final j = jsonDecode(r.body) as Map<String,dynamic>;
      final steps = ((j['plan'] as Map?)?['steps'] as List?) ?? const [];
      final base = steps.take(6).map((s) => s is Map ? '${s['character_id'] ?? s['agent_id'] ?? 'Agent'}: ${s['action'] ?? s['purpose'] ?? 'inspectable contribution'}' : '$s').toList();
      final generated = [
        'Option A • High Speed / Higher Risk • prioritize rapid execution and accept tighter rollback margin.',
        'Option B • Balanced • trade speed, cost and reliability around your current preference vector.',
        'Option C • Maximum Rigor / Slower Execution • add validation, evidence checks and larger rollback margin.',
      ];
      setState(() { options = [...generated, if (base.isNotEmpty) 'Execution trace: ${base.join(' → ')}']; challenges = ['What assumption would break this option first?', 'What happens if a key constraint changes after execution?', 'Which evidence would make you reject this path?']; running = false; status = 'PARETO_READY • challenge before acceptance'; });
      await _persist('options_generated');
    } catch (e) { if (mounted) setState(() { running = false; status = 'OPTION_GENERATION_PAUSED • $e'; }); }
  }

  Future<void> _saveDecision() async {
    if (residence == null) return;
    journal.insert(0, {'at':DateTime.now().toIso8601String(),'goal':goal.text.trim(),'prediction':'Selected trade-off: speed ${speed.round()} • cost ${cost.round()} • reliability ${reliability.round()}','real_result':null,'variance':null,'learning':'Pending real-world outcome.'});
    await _persist('decision_saved');
  }

  Future<void> _logResult() async {
    if (residence == null || resultCtl.text.trim().isEmpty) return;
    if (journal.isEmpty) await _saveDecision();
    final first = journal.first;
    first['real_result'] = resultCtl.text.trim();
    first['variance'] = 'QUALITATIVE_REVIEW_REQUIRED';
    first['learning'] = 'Outcome recorded for Medrus + Viveda review; no unsupported numeric calibration is invented.';
    resultCtl.clear();
    await _persist('result_logged');
    if (mounted) setState(() {});
  }

  Future<void> _challenge() async {
    setState(() => status = 'MANIS • stress-test bench active');
    if (residence != null) await _persist('challenge_recorded');
  }

  Future<void> _dispatch() async {
    if (!actApproved || !secondFactor) return;
    setState(() => status = 'BODHEX DISPATCH GATE UNLOCKED • awaiting explicit tool execution boundary');
    await _persist('action_approved');
  }

  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    if (residence == null) return Center(child:Text('Create or claim a Human Residence first.',style:TextStyle(color:t.mutedText)));
    return SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      _header(t), const SizedBox(height:14), _inputBay(t), const SizedBox(height:14), _pareto(t), const SizedBox(height:14), _challengeBench(t), const SizedBox(height:14), _actGate(t), const SizedBox(height:14), _journal(t)
    ]));
  }

  Widget _header(CriterivoxTheme t)=>Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(22),border:Border.all(color:t.success.withValues(alpha:.35))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('🏠 PRIVATE ROOM • PERSONAL EXECUTIVE COMMAND CENTER',style:TextStyle(color:t.success,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.2)),const SizedBox(height:8),Text(residence!.displayName,style:TextStyle(color:t.text,fontSize:25,fontWeight:FontWeight.w800)),const SizedBox(height:5),Text(status,style:TextStyle(color:t.mutedText,fontSize:10,fontWeight:FontWeight.w800)),const SizedBox(height:8),Text('Your residence is the authority boundary. Criterivox proposes, challenges and explains. You retain decision authority.',style:TextStyle(color:t.mutedText,fontSize:11,height:1.45))]));
  Widget _inputBay(CriterivoxTheme t)=>_panel(t,'1 • STRUCTURED INGESTION MATRIX',Column(children:[_field(goal,'Goal','Incomplete goals stay explicit. Dharen must not silently invent constraints.'),const SizedBox(height:10),_field(data,'Static Data','Facts, files, measurements or supplied records.'),const SizedBox(height:10),_field(contextCtl,'Dynamic Context','Timing, constraints, stakeholders, assumptions and changing conditions.'),const SizedBox(height:10),Wrap(spacing:8,children:[_tag(t,goal.text.trim().isEmpty?'GOAL_MISSING':'GOAL_PRESENT'),_tag(t,data.text.trim().isEmpty?'DATA_MISSING':'DATA_COMPLETE'),_tag(t,contextCtl.text.trim().isEmpty?'CONTEXT_SLOT_MISSING':'CONTEXT_PRESENT'),_tag(t,(goal.text.trim().isEmpty||contextCtl.text.trim().isEmpty)?'BOUNDS_REVIEW':'BOUNDS_SUPPLIED')]),const SizedBox(height:12),Align(alignment:Alignment.centerLeft,child:FilledButton.icon(onPressed:running?null:_generateOptions,icon:const Icon(Icons.auto_awesome_rounded),label:Text(running?'Sparring…':'Generate decision vectors')))]));
  Widget _field(TextEditingController c,String label,String hint)=>TextField(controller:c,maxLines:3,onChanged:(_)=>setState((){}),decoration:InputDecoration(labelText:label,hintText:hint));
  Widget _tag(CriterivoxTheme t,String text)=>Chip(label:Text(text,style:TextStyle(fontSize:8,fontWeight:FontWeight.w800)),visualDensity:VisualDensity.compact);
  Widget _pareto(CriterivoxTheme t)=>_panel(t,'2 • PARETO DECISION FRONTIER',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[if(options.isEmpty)Text('Generate options to populate three distinct decision vectors.',style:TextStyle(color:t.mutedText,fontSize:10)) else ...options.take(3).toList().asMap().entries.map((e)=>Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:t.surfaceStrong,borderRadius:BorderRadius.circular(14),border:Border.all(color:t.border)),child:Text(e.value,style:TextStyle(color:t.text,fontSize:10,height:1.4,fontWeight:FontWeight.w600))),_slider(t,'Speed',speed,(v)=>setState(()=>speed=v)),_slider(t,'Cost',cost,(v)=>setState(()=>cost=v)),_slider(t,'Reliability',reliability,(v)=>setState(()=>reliability=v)),Text('The sliders define preference, not an unsupported claim of mathematical optimality.',style:TextStyle(color:t.mutedText,fontSize:9))]));
  Widget _slider(CriterivoxTheme t,String label,double value,ValueChanged<double> cb)=>Row(children:[SizedBox(width:90,child:Text(label,style:TextStyle(color:t.mutedText,fontSize:10))),Expanded(child:Slider(value:value,min:0,max:100,onChanged:cb)),SizedBox(width:32,child:Text('${value.round()}',style:TextStyle(color:t.text,fontSize:10,fontWeight:FontWeight.w700)))]);
  Widget _challengeBench(CriterivoxTheme t)=>_panel(t,'3 • MANIS STRESS-TEST BENCH',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Socratic friction before commitment',style:TextStyle(color:t.text,fontWeight:FontWeight.w800)),const SizedBox(height:8),if(challenges.isEmpty)Text('Choose a decision vector, then run the challenge phase.',style:TextStyle(color:t.mutedText,fontSize:10)) else ...challenges.map((c)=>CheckboxListTile(value:false,onChanged:(_)=>_challenge(),title:Text(c,style:TextStyle(color:t.text,fontSize:10)),contentPadding:EdgeInsets.zero,controlAffinity:ListTileControlAffinity.leading)),const SizedBox(height:6),Text('Modify assumptions or reject premises here. A challenge is recorded as a governance event, not a decorative warning.',style:TextStyle(color:t.mutedText,fontSize:9,height:1.4))]));
  Widget _actGate(CriterivoxTheme t)=>_panel(t,'4 • TWO-FACTOR JUDGMENT + ACTION SAFETY GATE',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Cockpit Approval Briefing',style:TextStyle(color:t.text,fontWeight:FontWeight.w800)),const SizedBox(height:8),Text('Action Scope: decision-derived tool action\nBlast Radius: user-controlled and explicitly reviewed\nRollback Plan: must be defined before dispatch\nResource Cost: governed by the selected preference vector',style:TextStyle(color:t.mutedText,fontSize:10,height:1.55)),CheckboxListTile(value:actApproved,onChanged:(v)=>setState(()=>actApproved=v??false),title:const Text('I reviewed scope, blast radius and rollback boundary.'),contentPadding:EdgeInsets.zero),CheckboxListTile(value:secondFactor,onChanged:(v)=>setState(()=>secondFactor=v??false),title:const Text('Second judgment factor confirmed.'),contentPadding:EdgeInsets.zero),FilledButton.icon(onPressed:actApproved&&secondFactor?_dispatch:null,icon:const Icon(Icons.lock_open_rounded),label:const Text('Unlock Bodhex action dispatch'))]));
  Widget _journal(CriterivoxTheme t)=>_panel(t,'5 • BI-TEMPORAL RESULTS JOURNAL',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Prediction → real result → variance → learning',style:TextStyle(color:t.text,fontWeight:FontWeight.w800)),const SizedBox(height:8),if(journal.isEmpty)Text('No decision has been saved yet.',style:TextStyle(color:t.mutedText,fontSize:10)) else ...journal.take(8).map((j)=>Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:t.surfaceStrong,borderRadius:BorderRadius.circular(14)),child:Text('Goal: ${j['goal']}\nPrediction: ${j['prediction']}\nReal result: ${j['real_result'] ?? 'pending'}\nVariance: ${j['variance'] ?? 'pending'}\nLearning: ${j['learning']}',style:TextStyle(color:t.mutedText,fontSize:9,height:1.45))),const SizedBox(height:8),TextField(controller:resultCtl,maxLines:3,decoration:const InputDecoration(labelText:'Log real-world result')),const SizedBox(height:8),Wrap(spacing:8,children:[FilledButton.icon(onPressed:_saveDecision,icon:const Icon(Icons.bookmark_add_rounded),label:const Text('Save Decision')),OutlinedButton.icon(onPressed:_logResult,icon:const Icon(Icons.fact_check_rounded),label:const Text('Log Result')),OutlinedButton.icon(onPressed:widget.onWorkspace,icon:const Icon(Icons.account_tree_rounded),label:const Text('Open full workspace'))]) ]));
  Widget _panel(CriterivoxTheme t,String title,Widget child)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:t.primary,fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1.1)),const SizedBox(height:10),child]));
}
