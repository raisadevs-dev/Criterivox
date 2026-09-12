import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'human_residence_store.dart';
import 'presentation/criterivox_theme.dart';

class CollaborationRoomPage extends StatefulWidget {
  const CollaborationRoomPage({super.key});
  @override State<CollaborationRoomPage> createState() => _CollaborationRoomPageState();
}

class _CollaborationRoomPageState extends State<CollaborationRoomPage> {
  final store = HumanResidenceStore();
  HumanResidenceRecord? residence;
  String role = 'owner';
  String visibility = 'PUBLIC_TO_ROOM';
  String selectedOption = 'Option B';
  final memberCtl = TextEditingController();
  final messageCtl = TextEditingController();
  final resultCtl = TextEditingController();
  final List<Map<String,dynamic>> members = [
    {'name':'You','role':'House Owner','access':'FULL_CONTEXT_ACCESS'},
    {'name':'Resident A','role':'Resident','access':'SCOPED_WORKSPACE_ACCESS'},
    {'name':'Guest reviewer','role':'Guest','access':'READ_ONLY_MASKED_ACCESS'},
  ];
  final Map<String,int> votes = {'Option A':0,'Option B':0,'Option C':0};
  final List<String> contextStream = [];
  final List<String> challenges = [];
  final Set<String> signatures = {'House Owner'};
  String status = 'Room ready';
  bool saving = false;
  bool requireTwoKeys = true;

  @override void initState(){super.initState(); _restore();}
  @override void dispose(){memberCtl.dispose();messageCtl.dispose();resultCtl.dispose();super.dispose();}

  Future<void> _restore() async {
    final r = await store.load();
    if(!mounted)return;
    if(r!=null) setState((){residence=r;});
  }

  Future<void> _persist() async {
    final r = residence;
    if(r==null)return;
    setState(()=>saving=true);
    final metadata = Map<String,dynamic>.from(r.metadata);
    metadata['collaboration_room'] = {
      'role': role,
      'visibility': visibility,
      'members': members,
      'votes': votes,
      'selected_option': selectedOption,
      'context_stream': contextStream,
      'challenges': challenges,
      'signatures': signatures.toList(),
      'two_key_dispatch_required': requireTwoKeys,
      'outcomes': metadata['collaboration_room'] is Map ? (metadata['collaboration_room']['outcomes'] ?? []) : [],
    };
    final updated = HumanResidenceRecord(
      residenceId:r.residenceId, ownerId:r.ownerId, displayName:r.displayName, email:r.email,
      residenceType:r.residenceType, createdAt:r.createdAt, members:members, metadata:metadata,
    );
    await store.save(updated);
    try {
      final response=await http.post(Uri.base.resolve('/api/human-residence'),headers:{'content-type':'application/json'},body:jsonEncode(updated.toJson())).timeout(const Duration(seconds:4));
      status=response.statusCode<300?'Synced to browser authority + Python local mirror':'Saved locally; Python mirror unavailable.';
    } catch(_){status='Saved to browser authority; Python mirror will sync when runtime is available.';}
    if(mounted)setState(()=>{residence=updated;saving=false;});
  }

  void _addContext(){final text=messageCtl.text.trim();if(text.isEmpty)return;setState((){contextStream.add('${role.toUpperCase()} • $text → Syvax/Dharen classification pending');messageCtl.clear();status='Team message isolated from agent memory until classified.';});}
  void _challenge(){setState((){challenges.add('What assumption changes the recommendation if the constraint moves materially?');challenges.add('Which evidence would make the team reject this option?');});}
  void _vote(String option){setState((){votes[option]=(votes[option]??0)+1;selectedOption=option;});}
  int get totalVotes=>votes.values.fold(0,(a,b)=>a+b);
  int get consensus=>totalVotes==0?0:((votes[selectedOption]??0)*100/totalVotes).round();
  bool get dispatchUnlocked=>!requireTwoKeys || signatures.contains('House Owner') && signatures.contains('Resident');

  Future<void> _addMember(){final name=memberCtl.text.trim();if(name.isEmpty)return Future.value();setState((){members.add({'name':name,'role':'Resident','access':'SCOPED_WORKSPACE_ACCESS'});memberCtl.clear();status='Resident added with scoped access.';});return Future.value();}
  Future<void> _recordOutcome() async {
    final result=resultCtl.text.trim();if(result.isEmpty)return;
    final r=residence;if(r==null)return;
    final metadata=Map<String,dynamic>.from(r.metadata);final room=Map<String,dynamic>.from((metadata['collaboration_room'] as Map?)??{});final outcomes=List<dynamic>.from((room['outcomes'] as List?)??[]);
    outcomes.add({'at':DateTime.now().toIso8601String(),'initial_consensus':consensus,'chosen_option':selectedOption,'real_result':result,'contributors':members.where((m)=>m['role']!='Guest').map((m)=>m['name']).toList()});room['outcomes']=outcomes;metadata['collaboration_room']=room;
    final updated=HumanResidenceRecord(residenceId:r.residenceId,ownerId:r.ownerId,displayName:r.displayName,email:r.email,residenceType:r.residenceType,createdAt:r.createdAt,members:r.members,metadata:metadata);residence=updated;resultCtl.clear();await store.save(updated);try{await http.post(Uri.base.resolve('/api/human-residence'),headers:{'content-type':'application/json'},body:jsonEncode(updated.toJson()));}catch(_){ }if(mounted)setState(()=>status='Team outcome recorded with contributor attribution.');
  }

  @override Widget build(BuildContext context){final t=CriterivoxTheme.of(context);return SingleChildScrollView(padding:const EdgeInsets.all(26),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    _header(t),const SizedBox(height:14),_permissions(t),const SizedBox(height:14),_consensus(t),const SizedBox(height:14),_context(t),const SizedBox(height:14),_dispatch(t),const SizedBox(height:14),_outcomes(t)
  ]));}

  Widget _header(CriterivoxTheme t)=>Container(padding:const EdgeInsets.all(24),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(24),border:Border.all(color:t.success.withValues(alpha:.35))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('GATE 2 • COLLABORATION ROOM',style:TextStyle(color:t.success,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.5)),const SizedBox(height:7),Text(residence?.displayName??'Team War Room',style:TextStyle(color:t.text,fontSize:28,fontWeight:FontWeight.w800)),const SizedBox(height:6),Text('Multi-human + multi-agent decision space. Shared work stays scoped, auditable and attributable.',style:TextStyle(color:t.mutedText,fontSize:12,height:1.5)),const SizedBox(height:10),Text(status,style:TextStyle(color:t.success,fontSize:10,fontWeight:FontWeight.w700))]));

  Widget _permissions(CriterivoxTheme t)=>_panel(t,'1 • RBAC CONTEXT ISOLATION + DIFFERENTIAL DATA SHIELD',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Wrap(spacing:8,runSpacing:8,children:['owner','resident','guest'].map((r)=>ChoiceChip(label:Text(r=='owner'?'House Owner':r[0].toUpperCase()+r.substring(1)),selected:role==r,onSelected:(_)=>setState(()=>role=r)).toList()).toList()),const SizedBox(height:12),Text('Visibility: $visibility',style:TextStyle(color:t.text,fontWeight:FontWeight.w700,fontSize:11)),Wrap(spacing:8,children:['PUBLIC_TO_ROOM','RESIDENT_ONLY','OWNER_CONFIDENTIAL'].map((v)=>ChoiceChip(label:Text(v),selected:visibility==v,onSelected:(_)=>setState(()=>visibility=v))).toList()),const SizedBox(height:10),for(final m in members)Padding(padding:const EdgeInsets.only(bottom:6),child:Row(children:[Icon(Icons.person_outline_rounded,color:t.primary,size:16),const SizedBox(width:8),Expanded(child:Text('${m['name']} • ${m['role']}',style:TextStyle(color:t.text,fontSize:10))),Text(m['access'],style:TextStyle(color:t.mutedText,fontSize:8))])),if(role=='owner')Row(children:[Expanded(child:TextField(controller:memberCtl,decoration:const InputDecoration(labelText:'Add resident'))),const SizedBox(width:8),FilledButton(onPressed:_addMember,child:const Text('Add'))]) ]));

  Widget _consensus(CriterivoxTheme t)=>_panel(t,'2 • ASYNCHRONOUS CONSENSUS + DECISION POLLING MATRIX',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Consensus Radar • $consensus% alignment on $selectedOption',style:TextStyle(color:t.text,fontWeight:FontWeight.w800)),const SizedBox(height:10),for(final o in votes.keys)Padding(padding:const EdgeInsets.only(bottom:8),child:Row(children:[SizedBox(width:82,child:Text(o,style:TextStyle(color:t.mutedText,fontSize:10))),Expanded(child:LinearProgressIndicator(value:totalVotes==0?0:votes[o]!/totalVotes,minHeight:8)),const SizedBox(width:8),Text('${votes[o]} vote(s)',style:TextStyle(color:t.text,fontSize:9))])),Wrap(spacing:8,children:[for(final o in votes.keys)OutlinedButton(onPressed:()=>_vote(o),child:Text('Vote $o'))]),if(consensus>0&&consensus<70)Padding(padding:const EdgeInsets.only(top:10),child:Text('MANIS • TEAM FRICTION ALIGNMENT: consensus is below 70%; inspect the disagreement source before dispatch.',style:TextStyle(color:t.warning,fontSize:10,fontWeight:FontWeight.w700))),if(totalVotes>0)Padding(padding:const EdgeInsets.only(top:10),child:Text('Targeted challenges should accompany votes. The 70% line is a workflow trigger, not an empirical performance claim.',style:TextStyle(color:t.mutedText,fontSize:9))) ]));

  Widget _context(CriterivoxTheme t)=>_panel(t,'3 • NOISE-FILTERED TEAM CONTEXT WEAVER',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Syvax parses discussion; Dharen receives only classified goal/data/constraint updates.',style:TextStyle(color:t.text,fontSize:10)),const SizedBox(height:10),TextField(controller:messageCtl,maxLines:2,decoration:const InputDecoration(labelText:'Team message / candidate update')),const SizedBox(height:8),Wrap(spacing:8,children:[FilledButton.icon(onPressed:_addContext,icon:const Icon(Icons.filter_alt_rounded),label:const Text('Classify into context stream')),OutlinedButton.icon(onPressed:_challenge,icon:const Icon(Icons.gavel_rounded),label:const Text('Ask Manis to challenge'))]),const SizedBox(height:10),if(contextStream.isEmpty)Text('No structured context committed yet.',style:TextStyle(color:t.mutedText,fontSize:9)) else ...contextStream.map((x)=>Padding(padding:const EdgeInsets.only(bottom:6),child:Text('• $x',style:TextStyle(color:t.mutedText,fontSize:9)))),if(challenges.isNotEmpty)...[const Divider(),Text('MANIS CHALLENGES',style:TextStyle(color:t.primary,fontSize:9,fontWeight:FontWeight.w800)),...challenges.map((x)=>Text('• $x',style:TextStyle(color:t.mutedText,fontSize:9)))] ]));

  Widget _dispatch(CriterivoxTheme t)=>_panel(t,'4 • MULTI-KEY DISPATCH GATE',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SwitchListTile(contentPadding:EdgeInsets.zero,value:requireTwoKeys,onChanged:(v)=>setState(()=>requireTwoKeys=v),title:Text('Require Owner + Resident approval',style:TextStyle(color:t.text,fontSize:11,fontWeight:FontWeight.w700))),Text('SIGNATURES ${signatures.length}/2',style:TextStyle(color:t.primary,fontWeight:FontWeight.w900,fontSize:10)),Wrap(spacing:8,children:[FilterChip(label:const Text('House Owner'),selected:signatures.contains('House Owner'),onSelected:role=='owner'?(_){setState(()=>signatures.contains('House Owner')?signatures.remove('House Owner'):signatures.add('House Owner'));}:null),FilterChip(label:const Text('Resident'),selected:signatures.contains('Resident'),onSelected:role!='guest'?(_){setState(()=>signatures.contains('Resident')?signatures.remove('Resident'):signatures.add('Resident'));}:null)]),const SizedBox(height:8),Text(dispatchUnlocked?'DISPATCH UNLOCKED • Bodhex boundary may receive an approved action.':'DISPATCH LOCKED • required human signatures are missing.',style:TextStyle(color:dispatchUnlocked?t.success:t.warning,fontWeight:FontWeight.w800,fontSize:10)),const SizedBox(height:8),FilledButton.icon(onPressed:dispatchUnlocked?(){setState(()=>status='Action approved by required human signatories; execution remains behind the Bodhex control boundary.');}:null,icon:const Icon(Icons.lock_open_rounded),label:const Text('Approve action dispatch'))]));

  Widget _outcomes(CriterivoxTheme t)=>_panel(t,'5 • SHARED TEAM RESULTS JOURNAL + ATTRIBUTION LEDGER',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Record what actually happened. Contributors remain attached to the decision trajectory.',style:TextStyle(color:t.text,fontSize:10)),const SizedBox(height:8),TextField(controller:resultCtl,maxLines:3,decoration:const InputDecoration(labelText:'Real-world result')),const SizedBox(height:8),FilledButton.icon(onPressed:_recordOutcome,icon:const Icon(Icons.history_rounded),label:const Text('Log team outcome')),const SizedBox(height:10),Text('Current consensus: $consensus% • Chosen: $selectedOption',style:TextStyle(color:t.mutedText,fontSize:9)),Text('Medrus / Viveda learning hook: outcome is stored with contributor attribution for later calibration.',style:TextStyle(color:t.mutedText,fontSize:9))]));

  Widget _panel(CriterivoxTheme t,String title,Widget child)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:t.primary,fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1.1)),const SizedBox(height:10),child]));
}
