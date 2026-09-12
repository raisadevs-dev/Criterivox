import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'human_residence_store.dart';
import 'presentation/criterivox_theme.dart';

class GuestPassExperiencePage extends StatefulWidget {
  final VoidCallback onWorkspace;
  const GuestPassExperiencePage({super.key, required this.onWorkspace});
  @override State<GuestPassExperiencePage> createState() => _GuestPassExperiencePageState();
}

class _GuestPassExperiencePageState extends State<GuestPassExperiencePage> {
  String? sessionId;
  DateTime? expiresAt;
  Timer? timer;
  Duration remaining = const Duration(minutes: 15);
  bool loading = true, running = false, claiming = false;
  String status = 'Starting isolated guest session…';
  String goal = '';
  String data = '';
  String contextText = '';
  final goalCtl = TextEditingController();
  final dataCtl = TextEditingController();
  final contextCtl = TextEditingController();
  double budget = 50, speed = 50, risk = 50;
  final List<Map<String, String>> trace = [];
  final List<String> decisions = [];

  @override void initState() { super.initState(); _start(); }
  @override void dispose() { timer?.cancel(); goalCtl.dispose(); dataCtl.dispose(); contextCtl.dispose(); _leave(silent: true); super.dispose(); }

  Future<void> _start() async {
    try {
      final r = await http.post(Uri.base.resolve('/api/guest-pass/session')).timeout(const Duration(seconds: 5));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final j = jsonDecode(r.body) as Map<String, dynamic>;
        sessionId = '${j['session_id']}'; expiresAt = DateTime.parse('${j['expires_at']}');
        _clock();
        setState(() { loading = false; status = 'ISOLATED_EPHEMERAL_STATE'; });
        return;
      }
      throw Exception('guest session endpoint returned ${r.statusCode}');
    } catch (e) { if (mounted) setState(() { loading = false; status = 'Guest sandbox could not be started: $e'; }); }
  }

  void _clock() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final e = expiresAt; if (e == null || !mounted) return;
      final d = e.difference(DateTime.now());
      if (d.isNegative || d == Duration.zero) { timer?.cancel(); setState(() { remaining = Duration.zero; status = 'SESSION_VAPORIZED'; }); }
      else setState(() => remaining = d);
    });
  }

  Future<void> _run() async {
    if (sessionId == null || goalCtl.text.trim().isEmpty) return;
    setState(() { running = true; status = 'Anukor routing • Dharen framing • Pramon comparing • Manis challenging'; trace.clear(); decisions.clear(); });
    final payload = {'goal': goalCtl.text.trim(), 'data': dataCtl.text.trim(), 'context': {'description': contextCtl.text.trim(), 'budget': budget.round(), 'speed': speed.round(), 'risk': risk.round()}};
    try {
      final input = await http.post(Uri.base.resolve('/api/guest-pass/session/$sessionId/input'), headers: {'content-type':'application/json'}, body: jsonEncode(payload));
      if (input.statusCode >= 400) throw Exception('guest input rejected');
      final plan = await http.post(Uri.base.resolve('/api/syvax/plan'), headers: {'content-type':'application/json'}, body: jsonEncode({'message':goalCtl.text.trim(),'task_id':'guest-$sessionId'}));
      if (plan.statusCode >= 400) throw Exception('routing rejected');
      final p = jsonDecode(plan.body) as Map<String,dynamic>;
      _addTrace('Anukor', 'Routes the guest goal into an inspectable execution plan.');
      _addTrace('Dharen', 'Frames supplied context and identifies missing dimensions.');
      _addTrace('Pramon', 'Evaluates options against budget, speed and risk constraints.');
      _addTrace('Manis', 'Challenges assumptions and records adversarial questions.');
      final steps = ((p['plan'] as Map?)?['steps'] as List?) ?? const [];
      decisions.addAll(steps.take(4).map((s) => '${s is Map ? (s['character_id'] ?? s['agent_id'] ?? 'Agent') : 'Agent'}: ${s is Map ? (s['action'] ?? s['purpose'] ?? 'inspectable contribution') : s}'));
      if (decisions.isEmpty) decisions.add('No downstream option was produced yet. Inspect the trace and adjust constraints.');
      setState(() { running = false; status = 'TRACE_READY • trade-off canvas remains ephemeral'; });
    } catch (e) { if (mounted) setState(() { running = false; status = 'Guest evaluation paused: $e'; }); }
  }

  void _addTrace(String character, String reason) {
    trace.add({'character': character, 'reason': reason});
    final id = sessionId; if (id != null) { http.post(Uri.base.resolve('/api/guest-pass/session/$id/trace'), headers:{'content-type':'application/json'}, body:jsonEncode({'character':character,'reason':reason,'at':DateTime.now().toIso8601String()})); }
  }

  Future<void> _leave({bool silent = false}) async {
    final id = sessionId; if (id == null) return; sessionId = null; timer?.cancel();
    try { await http.delete(Uri.base.resolve('/api/guest-pass/session/$id')).timeout(const Duration(seconds:2)); } catch (_) {}
    if (!silent && mounted) setState(() => status = 'SESSION_VAPORIZED • no guest residence was created');
  }

  Future<void> _claim() async {
    final id = sessionId; if (id == null || claiming) return;
    setState(() { claiming = true; status = 'Migrating the ephemeral decision thread into a Human Residence…'; });
    try {
      final r = await http.post(Uri.base.resolve('/api/guest-pass/session/$id/claim')).timeout(const Duration(seconds:5));
      if (r.statusCode >= 400) throw Exception('claim rejected');
      final j = jsonDecode(r.body) as Map<String,dynamic>; final m = Map<String,dynamic>.from(j['migratable'] as Map);
      final now = DateTime.now(); final rid = 'res-guest-${now.millisecondsSinceEpoch}';
      final record = HumanResidenceRecord(residenceId:rid, ownerId:'local-${now.millisecondsSinceEpoch}', displayName:'My Criterivox House', email:null, residenceType:'private', createdAt:now, members:[{'role':'owner','owner_id':'local'}], metadata:{'rooms':['private','collaboration'],'claimed_from_guest':m['claimed_from_guest'],'guest_decisions':m['decisions'],'guest_trace':m['trace'],'goal':m['goal'],'data':m['data'],'context':m['context']});
      await HumanResidenceStore().save(record);
      try { await http.post(Uri.base.resolve('/api/human-residence'),headers:{'content-type':'application/json'},body:jsonEncode(record.toJson())).timeout(const Duration(seconds:4)); } catch (_) {}
      sessionId = null; timer?.cancel();
      if (mounted) setState(() { claiming = false; status = 'CLAIMED • decision migrated to your Human Residence'; });
      if (mounted) widget.onWorkspace();
    } catch (e) { if (mounted) setState(() { claiming = false; status = 'Claim failed: $e'; }); }
  }

  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    if (loading) return Center(child: CircularProgressIndicator(color:t.primary));
    final mins = remaining.inMinutes.toString().padLeft(2,'0'), secs = (remaining.inSeconds % 60).toString().padLeft(2,'0');
    return SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      _hud(t, mins, secs), const SizedBox(height:14),
      _hero(t), const SizedBox(height:14),
      _inputs(t), const SizedBox(height:14),
      _trace(t), const SizedBox(height:14),
      _tradeoffs(t), const SizedBox(height:14),
      _exit(t),
    ]));
  }

  Widget _hud(CriterivoxTheme t,String m,String s)=>Container(padding:const EdgeInsets.symmetric(horizontal:18,vertical:13),decoration:BoxDecoration(color:t.surfaceStrong,borderRadius:BorderRadius.circular(18),border:Border.all(color:t.success.withValues(alpha:.45))),child:Row(children:[Icon(Icons.shield_rounded,color:t.success),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(status,style:TextStyle(color:t.success,fontWeight:FontWeight.w800,fontSize:10,letterSpacing:1)),Text('Guest memory is session-scoped and excluded from Human Residence persistence.',style:TextStyle(color:t.mutedText,fontSize:9))])),Text('$m:$s',style:TextStyle(color:t.text,fontWeight:FontWeight.w900,fontSize:18)),const SizedBox(width:5),Text('TTL',style:TextStyle(color:t.mutedText,fontSize:9,fontWeight:FontWeight.w700))]));
  Widget _hero(CriterivoxTheme t)=>Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(22),border:Border.all(color:t.primary.withValues(alpha:.35))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('🎟️ GUEST PASS ROOM',style:TextStyle(color:t.primary,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.5)),const SizedBox(height:7),Text('Prove the value before you build a house.',style:TextStyle(color:t.text,fontSize:24,fontWeight:FontWeight.w800)),const SizedBox(height:7),Text('A temporary evaluation room for Goal + Data + Context. Inspect the reasoning, challenge trade-offs, then leave or claim the work.',style:TextStyle(color:t.mutedText,fontSize:11,height:1.5))]));
  Widget _inputs(CriterivoxTheme t)=>_panel(t,'1 • GOAL + DATA + CONTEXT',Column(children:[TextField(controller:goalCtl,maxLines:2,decoration:const InputDecoration(labelText:'Goal',hintText:'What decision are you evaluating?')),const SizedBox(height:10),TextField(controller:dataCtl,maxLines:3,decoration:const InputDecoration(labelText:'Data',hintText:'Paste trial data or describe the dataset')),const SizedBox(height:10),TextField(controller:contextCtl,maxLines:2,decoration:const InputDecoration(labelText:'Context',hintText:'Constraints, assumptions, timing, stakeholders')),const SizedBox(height:14),Align(alignment:Alignment.centerLeft,child:FilledButton.icon(onPressed:running?null:_run,icon:const Icon(Icons.play_arrow_rounded),label:Text(running?'Running…':'Run isolated evaluation')))]));
  Widget _trace(CriterivoxTheme t)=>_panel(t,'2 • DECISION LOGIC X-RAY',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Civilization Reasoning Trace',style:TextStyle(color:t.text,fontWeight:FontWeight.w800)),const SizedBox(height:8),if(trace.isEmpty)Text('Run the evaluation to inspect which characters contributed and why.',style:TextStyle(color:t.mutedText,fontSize:10)) else ...trace.map((x)=>Padding(padding:const EdgeInsets.only(bottom:8),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:8,height:8,margin:const EdgeInsets.only(top:4),decoration:BoxDecoration(shape:BoxShape.circle,color:t.primary)),const SizedBox(width:9),Expanded(child:RichText(text:TextSpan(style:TextStyle(color:t.mutedText,fontSize:10,height:1.4),children:[TextSpan(text:'${x['character']}  ',style:TextStyle(color:t.text,fontWeight:FontWeight.w800)),TextSpan(text:x['reason'])])))]))),if(decisions.isNotEmpty)...[const Divider(),Text('DECISIONS + OPTIONS',style:TextStyle(color:t.primary,fontWeight:FontWeight.w800,fontSize:9)),const SizedBox(height:6),...decisions.map((d)=>Padding(padding:const EdgeInsets.only(bottom:5),child:Text('• $d',style:TextStyle(color:t.mutedText,fontSize:10))))]));
  Widget _tradeoffs(CriterivoxTheme t)=>_panel(t,'3 • EPHEMERAL TRADE-OFF SPARRING DECK',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Experience how Criterivox adapts options as you challenge its assumptions!',style:TextStyle(color:t.text,fontWeight:FontWeight.w700,fontSize:11)),const SizedBox(height:10),_slider(t,'Budget',budget,(v)=>setState(()=>budget=v)),_slider(t,'Speed',speed,(v)=>setState(()=>speed=v)),_slider(t,'Risk tolerance',risk,(v)=>setState(()=>risk=v)),Text('These values live only in the guest session until you explicitly claim it.',style:TextStyle(color:t.mutedText,fontSize:9))]));
  Widget _slider(CriterivoxTheme t,String label,double value,ValueChanged<double> onChanged)=>Row(children:[SizedBox(width:100,child:Text(label,style:TextStyle(color:t.mutedText,fontSize:10))),Expanded(child:Slider(value:value,min:0,max:100,onChanged:onChanged)),SizedBox(width:34,child:Text('${value.round()}',style:TextStyle(color:t.text,fontSize:10,fontWeight:FontWeight.w700)))]);
  Widget _exit(CriterivoxTheme t)=>_panel(t,'4 • EXIT OPTIONS',Wrap(spacing:10,runSpacing:10,children:[OutlinedButton.icon(onPressed:claiming?null:_leave,icon:const Icon(Icons.logout_rounded),label:const Text('Leave & Vaporize')),FilledButton.icon(onPressed:claiming?null:_claim,icon:const Icon(Icons.home_work_rounded),label:Text(claiming?'Claiming…':'Claim House & Save Decision'))]));
  Widget _panel(CriterivoxTheme t,String title,Widget child)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:t.primary,fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1.2)),const SizedBox(height:10),child]));
}
