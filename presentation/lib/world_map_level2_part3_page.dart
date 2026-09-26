import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WorldMapLevel2Part3Page extends StatefulWidget {
  final VoidCallback onBack;
  const WorldMapLevel2Part3Page({super.key, required this.onBack});
  @override State<WorldMapLevel2Part3Page> createState() => _WorldMapLevel2Part3PageState();
}

class _WorldMapLevel2Part3PageState extends State<WorldMapLevel2Part3Page> {
  Map<String,dynamic> state={}; String status='Loading…'; bool loading=true; String selectedRoom='knowledge.hall';
  @override void initState(){super.initState(); _refresh();}
  Future<void> _refresh() async {
    try {
      final r=await http.get(Uri.parse('/api/world/level2/part3/state'));
      if(!mounted)return;
      setState(() { state = Map<String,dynamic>.from(jsonDecode(r.body) as Map); loading = false; status = r.statusCode>=200&&r.statusCode<300 ? 'LIVE • shared Knowledge / Challenge integration' : 'HTTP ${r.statusCode}'; });
    } catch (_) { if(mounted)setState(() { loading = false; status = 'Runtime unavailable • inspection boundary remains visible'; }); }
  }
  Future<void> _post(String path,Map<String,dynamic> body) async {
    try { final r=await http.post(Uri.parse('/api/world/level2/part3$path'),headers:{'content-type':'application/json'},body:jsonEncode(body)); if(!mounted)return; setState(()=>status=r.statusCode>=200&&r.statusCode<300?'LIVE • action accepted':'Action rejected • HTTP ${r.statusCode}'); await _refresh(); } catch(_){if(mounted)setState(()=>status='Runtime unavailable');}
  }
  Future<void> _trajectory() async => _post('/trajectory',{'title':'Human-inspectable trajectory proposal','references':['current-work-materials'],'steps':['inspect evidence','compare context','challenge generalization'],'conditions':['declared scope'],'limitations':['requires Manis review before reuse']});
  Future<void> _challenge() async { final p=List<dynamic>.from(state['proposals']??[]); if(p.isEmpty){await _trajectory(); await _refresh();} final q=List<dynamic>.from(state['proposals']??[]); if(q.isNotEmpty) await _post('/proposal/challenge',{'proposal_id':'${q.last['proposal_id']}','actor_id':'human-reviewer','room':'challenge.generalization','instruction':'Challenge evidence, scope and generalization conditions.'});}
  @override Widget build(BuildContext context){
    final k=Map<String,dynamic>.from(state['knowledge']??{}), c=Map<String,dynamic>.from(state['challenge']??{}), t=Theme.of(context).colorScheme;
    return Scaffold(appBar:AppBar(leading:IconButton(icon:const Icon(Icons.arrow_back),onPressed:widget.onBack),title:const Text('World Map • Level 2 Part III')),body:loading?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.all(20),children:[
      Text(status,style:TextStyle(color:t.primary,fontWeight:FontWeight.w700)),const SizedBox(height:16),
      _card(t,'KNOWLEDGE QUARTER • VIVEDA',k,['Trajectory → pattern proposals','Ontology + mutation ledger','Skill library / packaging','Schema translation + version archive','Utility / decay / reflection / MemSync']),
      const SizedBox(height:12),_card(t,'CHALLENGE & REVIEW QUARTER • MANIS',c,['Existing HumanAuthority + CollaborationEngine','Rule friction and challenge rooms','Challenge links return to Viveda proposals','No duplicate Manis engine']),
      const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('KNOWLEDGE LIFECYCLE',style:TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:8),
        const Text('Evidence / trajectory → proposal → Manis challenge → human review → versioned reusable knowledge.'),
        const SizedBox(height:12),Wrap(spacing:8,children:[FilledButton(onPressed:_trajectory,child:const Text('Create trajectory proposal')),OutlinedButton(onPressed:_challenge,child:const Text('Challenge latest with Manis')),OutlinedButton(onPressed:_refresh,child:const Text('Refresh'))])
      ]))),
      const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('OPERATIONAL DOORS',style:TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:8),Wrap(spacing:6,runSpacing:6,children:[...List<String>.from(k['rooms']??[]),...List<String>.from(c['rooms']??[])].map((room)=>ChoiceChip(label:Text(room),selected:selectedRoom==room,onSelected:(_)=>setState(()=>selectedRoom=room))).toList())]))),const SizedBox(height:12),Text('Selected door: $selectedRoom • inspectable through the shared Part III runtime'),const SizedBox(height:12),Text('Active proposals: ${List<dynamic>.from(state['proposals']??[]).length} • skills: ${List<dynamic>.from(state['skills']??[]).length}',style:TextStyle(color:t.onSurfaceVariant))
    ]));}
  Widget _card(ColorScheme t,String title,Map<String,dynamic> data,List<String> bullets) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: t.primary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Resident: ${data['resident'] ?? '—'} • Truth: ${data['truth'] ?? '—'}'),
          const SizedBox(height: 8),
          ...bullets.map((x) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $x'),
          )),
          if (data['rooms'] is List) Text('Operational doors: ${(data['rooms'] as List).length}'),
        ],
      ),
    ),
  );
}
