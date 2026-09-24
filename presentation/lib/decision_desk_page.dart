import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'human_residence_store.dart';
import 'presentation/criterivox_theme.dart';

class DecisionDeskPage extends StatefulWidget {
  final VoidCallback? onResults;
  const DecisionDeskPage({super.key,this.onResults});
  @override State<DecisionDeskPage> createState()=>_DecisionDeskPageState();
}
class _DecisionDeskPageState extends State<DecisionDeskPage>{
  final store=HumanResidenceStore();
  final goal=TextEditingController(), data=TextEditingController(), contextCtl=TextEditingController();
  HumanResidenceRecord? residence;
  bool running=false, external=false;
  String status='READY';
  List<String> options=[], challenges=[];
  List<Map<String,dynamic>> trace=[];
  @override void initState(){super.initState();_restore();}
  @override void dispose(){goal.dispose();data.dispose();contextCtl.dispose();super.dispose();}
  Future<void> _restore() async{final r=await store.load();if(!mounted)return;setState((){residence=r;if(r!=null){goal.text=r.metadata['goal']?.toString()??'';data.text=r.metadata['data']?.toString()??'';contextCtl.text=r.metadata['context']?.toString()??'';}});}
  Future<void> _run() async{
    if(residence==null){setState(()=>status='CREATE_OR_RESTORE_RESIDENCE_FIRST');return;}
    final token=residence!.metadata['session_token']?.toString();
    if(token==null||token.isEmpty){setState(()=>status='AUTHENTICATED_SESSION_REQUIRED');return;}
    if(goal.text.trim().isEmpty){setState(()=>status='GOAL_REQUIRED');return;}
    setState((){running=true;status=external?'RESEARCH_AUTHORIZED':'ANALYSIS_FROM_SUPPLIED_CONTEXT';options=[];challenges=[];trace=[];});
    try{
      final response=await http.post(Uri.base.resolve('/api/human-residence/decision'),headers:const {'content-type':'application/json'},body:jsonEncode({'session_token':token,'residence_id':residence!.residenceId,'goal':goal.text.trim(),'data':data.text.trim(),'context':contextCtl.text.trim(),'allow_external_research':external})).timeout(const Duration(seconds:30));
      final body=jsonDecode(response.body);
      if(response.statusCode<200||response.statusCode>=300||body is! Map)throw Exception(body is Map?(body['error']??'decision pipeline rejected'):'decision pipeline rejected');
      final m=Map<String,dynamic>.from(body);
      final strategy=m['strategy'] is Map?Map<String,dynamic>.from(m['strategy'] as Map):<String,dynamic>{};
      final ro=strategy['options'], rc=strategy['challenges'];
      if(!mounted)return;
      setState((){options=ro is List?ro.whereType<Map>().map((x)=>(x['label']??'').toString()+' : '+(x['approach']??'').toString()+' • Risk: '+(x['risk']??'review').toString()).toList():[];challenges=rc is List?rc.map((x)=>x.toString()).toList():[];trace=m['trace'] is List?m['trace'].whereType<Map>().map((x)=>Map<String,dynamic>.from(x)).toList():[];running=false;status='DECISION_READY • HUMAN_REVIEW_REQUIRED';});
    }catch(e){if(mounted)setState((){running=false;status='DECISION_PIPELINE_FAILED • '+e.toString();});}
  }
  @override Widget build(BuildContext context){
    final t=CriterivoxTheme.of(context);
    return SingleChildScrollView(key:const ValueKey('decision-desk'),padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text('DECISION DESK',style:TextStyle(color:t.primary,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.8)),
      const SizedBox(height:6),Text('Turn a situation into a decision you can inspect.',style:TextStyle(color:t.text,fontSize:28,fontWeight:FontWeight.w800)),
      const SizedBox(height:6),Text('Criterivox organizes context, options, evidence and uncertainty. You inspect, challenge and decide.',style:TextStyle(color:t.mutedText,fontSize:12,height:1.45)),
      const SizedBox(height:18),_panel(t,'YOUR SITUATION',Column(children:[
        _field(goal,'Goal / question'),const SizedBox(height:10),_field(data,'Facts, files or supplied data'),const SizedBox(height:10),_field(contextCtl,'Context, constraints and assumptions'),
        SwitchListTile.adaptive(value:external,onChanged:running?null:(v)=>setState(()=>external=v),contentPadding:EdgeInsets.zero,title:const Text('Allow external research'),subtitle:const Text('Attach external evidence to this decision trace.')),
        Align(alignment:Alignment.centerLeft,child:FilledButton.icon(onPressed:running?null:_run,icon:const Icon(Icons.play_arrow_rounded),label:Text(running?'Working…':'Analyze situation')))
      ])),
      const SizedBox(height:14),_panel(t,'WHAT MATTERS',Wrap(spacing:8,runSpacing:8,children:[_chip(goal.text.trim().isEmpty?'Goal missing':'Goal supplied'),_chip(contextCtl.text.trim().isEmpty?'Context missing':'Context supplied'),_chip(options.isEmpty?'Options pending':'Options available'),_chip(challenges.isEmpty?'Challenges pending':'Challenges available')])),
      const SizedBox(height:14),_panel(t,'OPTIONS',options.isEmpty?Text('Run the analysis to populate actual decision options.',style:TextStyle(color:t.mutedText,fontSize:11)):Column(children:[for(final o in options)_item(t,o)])),
      const SizedBox(height:14),_panel(t,'UNCERTAINTIES & CHALLENGES',challenges.isEmpty?Text('No challenge findings returned yet.',style:TextStyle(color:t.mutedText,fontSize:11)):Column(children:[for(final c in challenges)_item(t,c)])),
      if(trace.isNotEmpty)...[const SizedBox(height:14),_panel(t,'EVIDENCE / TRACE',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[for(final e in trace)Padding(padding:const EdgeInsets.only(top:7),child:Text((e['actor']??'').toString()+' • '+(e['responsibility']??'').toString()+' • '+(e['detail']??'').toString(),style:TextStyle(color:t.mutedText,fontSize:10,height:1.4)))]))],
      const SizedBox(height:14),_panel(t,'HUMAN AUTHORITY',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Criterivox proposes and explains. You can inspect, challenge, reject, modify or decide.',style:TextStyle(color:t.text,fontSize:12,height:1.45)),const SizedBox(height:10),Text(status,style:TextStyle(color:t.mutedText,fontSize:10,fontWeight:FontWeight.w800)),if(onResults!=null)Padding(padding:const EdgeInsets.only(top:10),child:OutlinedButton.icon(onPressed:onResults,icon:const Icon(Icons.menu_book_outlined),label:const Text('Open Results Journal'))]))
    ]));
  }
  Widget _field(TextEditingController c,String label)=>TextField(controller:c,maxLines:3,onChanged:(_)=>setState((){}),decoration:InputDecoration(labelText:label));
  Widget _panel(CriterivoxTheme t,String title,Widget child)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:t.primary,fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1.2)),const SizedBox(height:10),child]));
  Widget _item(CriterivoxTheme t,String value)=>Container(width:double.infinity,margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:t.surfaceStrong,borderRadius:BorderRadius.circular(14),border:Border.all(color:t.border)),child:Text(value,style:TextStyle(color:t.text,fontSize:10,height:1.4)));
  Widget _chip(String s)=>Chip(label:Text(s,style:const TextStyle(fontSize:9,fontWeight:FontWeight.w700)));
}
