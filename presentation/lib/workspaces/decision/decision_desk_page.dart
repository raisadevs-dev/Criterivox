import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../human/residence/store.dart';
import '../../presentation/shared/criterivox_theme.dart';
import '../../presentation/shared/api_client.dart';

class DecisionDeskPage extends StatefulWidget {
  final VoidCallback? onResults;
  const DecisionDeskPage({super.key, this.onResults});
  @override State<DecisionDeskPage> createState() => _DecisionDeskPageState();
}
class _DecisionDeskPageState extends State<DecisionDeskPage> {
  final store = HumanResidenceStore();
  final situation = TextEditingController();
  final data = TextEditingController();
  final contextCtl = TextEditingController();
  HumanResidenceRecord? residence;
  bool running = false, external = false;
  String status = 'READY';
  int imageCount = 0;
  String imageRole = 'other';
  List<String> imageNames = [], questions = [];
  List<Map<String, dynamic>> agentTrace = [];
  Map<String, dynamic>? support, understanding;
  String humanReadable = '';
  String? decisionId;
  Map<String, dynamic>? strategy;
  @override void initState(){super.initState();_restore();}
  @override void dispose(){situation.dispose();data.dispose();contextCtl.dispose();super.dispose();}
  Future<void> _restore() async { final r=await store.load(); if(!mounted)return; setState((){residence=r;if(r!=null){situation.text=r.metadata['goal']?.toString()??'';data.text=r.metadata['data']?.toString()??'';contextCtl.text=r.metadata['context']?.toString()??'';final rawTrace=r.metadata['decision_support_trace'];agentTrace=rawTrace is List?rawTrace.whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList():[];}}); }
  Future<void> _attachImages() async { final result=await FilePicker.platform.pickFiles(withData:false,allowMultiple:true,type:FileType.image); if(result==null||result.files.isEmpty)return; setState((){imageCount+=result.files.length;imageNames.addAll(result.files.map((f)=>f.name));status='IMAGES_ATTACHED • appearance is not treated as behavioral evidence';}); }
  Future<void> _run([String? safetyAnswer]) async {
    var description=situation.text.trim();
    if(safetyAnswer!=null&&safetyAnswer.isNotEmpty){description='$description\nUser safety answer: $safetyAnswer';situation.text=description;}
    if(description.isEmpty){setState(()=>status='SITUATION_REQUIRED');return;}
    final token=residence?.metadata['session_token']?.toString()??'';
    setState((){running=true;status='UNDERSTANDING_SITUATION';questions=[];support=null;humanReadable='';decisionId=null;strategy=null;agentTrace=[];});
    try {
      final response=await http.post(CriterivoxApi.uri('/api/human-situation/understand'),headers:const {'content-type':'application/json'},body:jsonEncode({'session_token':token,'residence_id':residence?.residenceId??'','description':description,'data':data.text.trim(),'context':contextCtl.text.trim(),'image_count':imageCount,'image_roles':List<String>.filled(imageCount,imageRole),'allow_external_research':external})).timeout(const Duration(seconds:30));
      final decoded=jsonDecode(response.body);
      if(response.statusCode<200||response.statusCode>=300||decoded is! Map)throw Exception(decoded is Map?decoded['error']??'situation pipeline rejected':'situation pipeline rejected');
      final body=Map<String,dynamic>.from(decoded); if(!mounted)return;
      setState((){understanding=body['understanding'] is Map?Map<String,dynamic>.from(body['understanding']):null;questions=body['questions'] is List?body['questions'].map((x)=>x.toString()).toList():[];support=body['support'] is Map?Map<String,dynamic>.from(body['support']):null;strategy=body['strategy'] is Map?Map<String,dynamic>.from(body['strategy']):null;decisionId=body['decision_id']?.toString();agentTrace=body['trace'] is List?body['trace'].whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList():[];humanReadable=body['human_readable']?.toString()??'';running=false;status=body['status']?.toString().toUpperCase()??'READY';});
      if(body['status']=='ready'&&residence!=null)await _persistSituation();
    } catch(e) { if(mounted)setState((){running=false;status='SITUATION_PIPELINE_FAILED • $e';}); }
  }
  Future<void> _persistSituation() async { final r=residence;if(r==null)return;final metadata=Map<String,dynamic>.from(r.metadata)..['goal']=situation.text.trim()..['context']=contextCtl.text.trim()..['data']=data.text.trim()..['decision_support_last_status']=status..['decision_support_images']=imageNames..['decision_support_trace']=agentTrace..['decision_support_strategy']=strategy..['decision_support_decision_id']=decisionId;await store.save(HumanResidenceRecord(residenceId:r.residenceId,ownerId:r.ownerId,displayName:r.displayName,email:r.email,residenceType:r.residenceType,createdAt:r.createdAt,members:r.members,metadata:metadata)); }
  @override Widget build(BuildContext context){
    final t=CriterivoxTheme.of(context);
    final safety=understanding?['situation'] is Map?(understanding!['situation'] as Map)['safety']?.toString():null;
    final sensitive=safety=='sensitive'||safety=='immediate';
    final next=support?['suggested_next_steps'], matters=support?['what_matters'], uncertain=support?['uncertainties'];
    final answerText = [strategy?['direct_answer'], strategy?['answer'], strategy?['summary'], strategy?['recommendation'], humanReadable].map((v)=>v?.toString().trim()??'').firstWhere((v)=>v.isNotEmpty,orElse:()=> '');
    final evidence = strategy?['evidence'] ?? support?['evidence'];
    final assumptions = strategy?['assumptions'] ?? support?['assumptions'];
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(key:const ValueKey('decision-desk'),padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text('DECISION DESK',style:TextStyle(color:t.primary,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.8)),
      const SizedBox(height:6),Text('Bring the messy situation. Keep the architecture hidden.',style:TextStyle(color:t.text,fontSize:28,fontWeight:FontWeight.w800)),
      const SizedBox(height:6),Text('Describe what is happening in ordinary language. Criterivox separates what you reported, what matters, what is uncertain, and what you can do next.',style:TextStyle(color:t.mutedText,fontSize:12,height:1.45)),
      const SizedBox(height:18),_panel(t,'WHAT IS HAPPENING?',Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        TextField(controller:situation,maxLines:5,decoration:const InputDecoration(labelText:'Describe the situation or question',hintText:'For example: My classmates keep excluding me. What should I do?')),
        const SizedBox(height:10),TextField(controller:contextCtl,maxLines:3,decoration:const InputDecoration(labelText:'Optional context, constraints or time pressure')),
        const SizedBox(height:10),TextField(controller:data,maxLines:3,decoration:const InputDecoration(labelText:'Optional facts, messages or supplied information')),
        const SizedBox(height:10),DropdownButtonFormField<String>(initialValue:imageRole,decoration:const InputDecoration(labelText:'What kind of images are these?'),items:const [DropdownMenuItem(value:'photograph_of_people',child:Text('Photographs of people')),DropdownMenuItem(value:'document_photo',child:Text('Document / photo of a document')),DropdownMenuItem(value:'screenshot',child:Text('Screenshot')),DropdownMenuItem(value:'diagram',child:Text('Diagram')),DropdownMenuItem(value:'other',child:Text('Other'))],onChanged:(v)=>setState(()=>imageRole=v??'other')),
        const SizedBox(height:10),Row(children:[OutlinedButton.icon(onPressed:running?null:_attachImages,icon:const Icon(Icons.photo_library_outlined),label:Text('Attach images ($imageCount)')),const SizedBox(width:10),if(imageNames.isNotEmpty)Expanded(child:Text(imageNames.join(', '),overflow:TextOverflow.ellipsis,style:TextStyle(color:t.mutedText,fontSize:9)))]),
        if(imageCount>0)Padding(padding:const EdgeInsets.only(top:8),child:Text('Photos of people are contextual input only. They are not evidence of identity, personality, intent, or behavior.',style:TextStyle(color:t.mutedText,fontSize:10))),
        Material(color:Colors.transparent,child:SwitchListTile.adaptive(value:external,onChanged:running?null:(v)=>setState(()=>external=v),contentPadding:EdgeInsets.zero,title:const Text('Allow external research'),subtitle:const Text('Only relevant when evidence from outside sources is appropriate.'))),
        Align(alignment:Alignment.centerLeft,child:FilledButton.icon(onPressed:running?null:()=>_run(),icon:const Icon(Icons.psychology_alt_outlined),label:Text(running?'Understanding…':'Help me think this through'))),
      ])),
      const SizedBox(height:14),
      if(sensitive)_panel(t,'SAFETY FIRST',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('The situation may involve interpersonal harm or an immediate safety concern. Safety takes priority over ordinary analysis.',style:TextStyle(color:t.text,fontSize:12,height:1.45)),const SizedBox(height:10),for(final q in questions.where((q)=>q.toLowerCase().contains('safe right now'))) ...[Text(q,style:TextStyle(color:t.text,fontWeight:FontWeight.w800,fontSize:12)),const SizedBox(height:8),Wrap(spacing:8,children:[OutlinedButton(onPressed:running?null:()=>_run('Yes'),child:const Text('Yes')),OutlinedButton(onPressed:running?null:()=>_run('No'),child:const Text('No')),OutlinedButton(onPressed:running?null:()=>_run("I'm not sure"),child:const Text("I'm not sure"))])]])),
      if(questions.isNotEmpty)_panel(t,'A LITTLE MORE CONTEXT',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[for(final q in questions.where((q)=>!q.toLowerCase().contains('safe right now')))Padding(padding:const EdgeInsets.only(bottom:7),child:Text('• $q',style:TextStyle(color:t.mutedText,fontSize:11))),Text('Add the answer in the situation box, then run it again.',style:TextStyle(color:t.mutedText,fontSize:10))])),
      if(humanReadable.isNotEmpty||strategy!=null)_panel(t,'ANSWER • WHAT YOU CAN TAKE AWAY',Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Text(answerText.isNotEmpty?answerText:'The situation was processed, but the system did not return a direct answer in its structured response. Review the findings and try refining the question.',style:TextStyle(color:t.text,fontSize:14,height:1.55,fontWeight:FontWeight.w600)),
        if(status!='READY'&&status!='COMPLETE'&&status!='COMPLETED')Padding(padding:const EdgeInsets.only(top:8),child:Text('This is a partial or non-final result. Status: $status',style:TextStyle(color:t.mutedText,fontSize:10))),
        if(evidence is List&&evidence.isNotEmpty)...[const SizedBox(height:10),Text('Evidence returned',style:TextStyle(color:t.primary,fontWeight:FontWeight.w800,fontSize:11)),for(final e in evidence)Padding(padding:const EdgeInsets.only(top:4),child:Text('• ${e is Map?(e['summary']??e['title']??e['detail']??jsonEncode(e)):e}',style:TextStyle(color:t.mutedText,fontSize:10,height:1.4)))],
        if(assumptions is List&&assumptions.isNotEmpty)...[const SizedBox(height:10),Text('Assumptions to verify',style:TextStyle(color:t.primary,fontWeight:FontWeight.w800,fontSize:11)),for(final a in assumptions)Padding(padding:const EdgeInsets.only(top:4),child:Text('• $a',style:TextStyle(color:t.mutedText,fontSize:10,height:1.4)))],
        const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:[
          if(widget.onResults!=null)OutlinedButton.icon(onPressed:widget.onResults,icon:const Icon(Icons.bookmark_border_rounded),label:const Text('Save / view in Results Journal')),
          OutlinedButton.icon(onPressed:()=>setState(()=>status='READY_FOR_HUMAN_REVIEW'),icon:const Icon(Icons.edit_note_rounded),label:const Text('Revise question')),
        ]),
      ])),
      if(humanReadable.isNotEmpty)_panel(t,'WHAT I UNDERSTAND',Text(humanReadable,style:TextStyle(color:t.text,fontSize:12,height:1.5))),
      if(humanReadable.isNotEmpty||strategy!=null)_panel(t,'FINAL RESULT • YOUR DECISION SUPPORT',Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Text(status=='READY'?'Decision-support result is ready for your review.':'Decision-support status: $status',style:TextStyle(color:t.text,fontWeight:FontWeight.w800,fontSize:13)),
        if(humanReadable.isEmpty&&strategy==null)Text('No strategy options were returned for this pass. Review the understanding and uncertainties below before continuing.',style:TextStyle(color:t.mutedText,fontSize:11,height:1.45)),
        const SizedBox(height:8),
        if(humanReadable.isNotEmpty)Text(humanReadable,style:TextStyle(color:t.mutedText,fontSize:11,height:1.5)),
        if(strategy?['challenges'] is List&&(strategy!['challenges'] as List).isNotEmpty)...[(const SizedBox(height:10)),Text('Challenges to consider',style:TextStyle(color:t.primary,fontWeight:FontWeight.w800,fontSize:11)),for(final challenge in (strategy!['challenges'] as List))Padding(padding:const EdgeInsets.only(top:5),child:Text('• $challenge',style:TextStyle(color:t.mutedText,fontSize:10,height:1.4)))],
        if(decisionId!=null)...[const SizedBox(height:10),Text('Saved decision: $decisionId',style:TextStyle(color:t.mutedText,fontSize:9))],
        const SizedBox(height:12),
        Wrap(spacing:8,runSpacing:8,children:[
          if(widget.onResults!=null)OutlinedButton.icon(onPressed:widget.onResults,icon:const Icon(Icons.menu_book_outlined),label:const Text('Open Results Journal')),
          OutlinedButton.icon(onPressed:()=>setState((){status='READY_FOR_HUMAN_REVIEW';}),icon:const Icon(Icons.edit_note_rounded),label:const Text('Correct the situation')),
        ]),
      ])),
      if(running)_panel(t,'EXECUTION STATUS',Row(children:[const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)),const SizedBox(width:12),Expanded(child:Text('Criterivox is processing this request. Detailed agent events appear only when the backend returns them.',style:TextStyle(color:t.mutedText,fontSize:11,height:1.4)))])),
      if(agentTrace.isNotEmpty)_panel(t,'RECORDED EXECUTION TRACE',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[for(final event in agentTrace)Padding(padding:const EdgeInsets.only(bottom:9),child:Container(width:double.infinity,padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:t.surfaceStrong,borderRadius:BorderRadius.circular(12),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${event['actor']??event['agent']??event['agent_id']??'Execution step'}',style:TextStyle(color:t.text,fontSize:11,fontWeight:FontWeight.w800)),if((event['responsibility']??'').toString().isNotEmpty)Padding(padding:const EdgeInsets.only(top:3),child:Text('${event['responsibility']}',style:TextStyle(color:t.primary,fontSize:10,fontWeight:FontWeight.w700))),if((event['detail']??event['summary']??event['message']??'').toString().isNotEmpty)Padding(padding:const EdgeInsets.only(top:3),child:Text('${event['detail']??event['summary']??event['message']}',style:TextStyle(color:t.mutedText,fontSize:10,height:1.4))),if((event['status']??'').toString().isNotEmpty)Padding(padding:const EdgeInsets.only(top:3),child:Text('Status: ${event['status']}',style:TextStyle(color:t.mutedText,fontSize:9)))])))])),
      if(matters is List&&matters.isNotEmpty)_panel(t,'WHAT MATTERS',Column(children:[for(final x in matters)_item(t,x.toString())])),
      if(next is List&&next.isNotEmpty)_panel(t,'WHAT YOU CAN DO NEXT',Column(children:[for(var i=0;i<next.length;i++)_item(t,'${i+1}. ${next[i]}')])),
      if(uncertain is List&&uncertain.isNotEmpty)_panel(t,"WHAT I'M NOT SURE ABOUT",Column(children:[for(final x in uncertain)_item(t,x.toString())])),
      if(strategy?['options'] is List&&(strategy!['options'] as List).isNotEmpty)_panel(t,'STRATEGY OPTIONS',Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        for(final x in (strategy!['options'] as List).whereType<Map>())Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:t.surfaceStrong,borderRadius:BorderRadius.circular(14),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(x['label']?.toString()??'Option',style:TextStyle(color:t.text,fontWeight:FontWeight.w800,fontSize:12)),
          const SizedBox(height:4),Text(x['approach']?.toString()??'',style:TextStyle(color:t.mutedText,fontSize:10,height:1.4)),
          const SizedBox(height:6),Text('Risk: ${x['risk']??'Not specified'}',style:TextStyle(color:t.mutedText,fontSize:9)),
        ])),
      ])),
      _panel(t,'HUMAN AUTHORITY',Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Criterivox supports the decision. You remain able to correct the situation description, reject a suggestion, inspect evidence, explore another option, or decide what happens next.',style:TextStyle(color:t.text,fontSize:12,height:1.45)),const SizedBox(height:8),Text(status,style:TextStyle(color:t.mutedText,fontSize:10,fontWeight:FontWeight.w800)),if(widget.onResults!=null)Padding(padding:const EdgeInsets.only(top:10),child:OutlinedButton.icon(onPressed:widget.onResults,icon:const Icon(Icons.menu_book_outlined),label:const Text('Open Results Journal')))])),
    ])));
  }
  Widget _panel(CriterivoxTheme t,String title,Widget child)=>Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:t.primary,fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1.2)),const SizedBox(height:10),child]));
  Widget _item(CriterivoxTheme t,String value)=>Container(width:double.infinity,margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:t.surfaceStrong,borderRadius:BorderRadius.circular(14),border:Border.all(color:t.border)),child:Text(value,style:TextStyle(color:t.text,fontSize:10,height:1.4)));
}