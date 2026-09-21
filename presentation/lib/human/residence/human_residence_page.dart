import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../foundation/scene.dart';
import '../../foundation/spatial_panel.dart';
import 'residence_work_client.dart';

class HumanResidencePage extends StatefulWidget {
  final String roomId;
  const HumanResidencePage({super.key,this.roomId='private'});
  @override State<HumanResidencePage> createState()=>_HumanResidencePageState();
}
class _HumanResidencePageState extends State<HumanResidencePage> {
  final _client=ResidenceWorkClient(); List<Map<String,dynamic>> _work=[]; Timer? _timer;
  @override void initState(){super.initState();_load();_timer=Timer.periodic(const Duration(seconds:2),(_)=>_load());}
  @override void dispose(){_timer?.cancel();super.dispose();}
  Future<void> _load() async {try{final v=await _client.list(roomId:widget.roomId);if(mounted)setState(()=>_work=v);}catch(_){}}
  @override Widget build(BuildContext c)=>Scene(eyebrow:'HUMAN TERRITORY',title:'Human Residence',subtitle:'Persistent human-owned work. Criterivox prepares; the human reviews, challenges and decides.',children:[
    SpatialPanel(title:'READY FOR YOU',child:_work.isEmpty?const Text('No work yet.'):Column(children:_work.where((w)=>w['status']=='READY_FOR_HUMAN').map((w)=>ListTile(title:Text('${w['goal']}'),subtitle:Text('READY · ${((w['ready_items'] as List?)?.length ?? 0)} item(s)'),trailing:FilledButton(onPressed:()=>_review(w),child:const Text('TAKE')))).toList())),
    SpatialPanel(title:'ACTIVE WORK',child:Column(children:_work.where((w)=>w['status']!='READY_FOR_HUMAN'&&w['status']!='COMPLETED').map((w)=>ListTile(title:Text('${w['goal']}'),subtitle:Text('${w['status']} · ${w['task_id']}'),onTap:()=>_review(w))).toList())),
    FilledButton.icon(onPressed:()=>_newWork(),icon:const Icon(Icons.add),label:const Text('NEW WORK')),
  ]);
  Future<void> _newWork() async {await Navigator.push(cContext(),MaterialPageRoute(builder:(_)=>_Intake(client:_client,roomId:widget.roomId)));_load();}
  BuildContext cContext()=>context;
  Future<void> _review(Map<String,dynamic> w) async {var x=w;if(x['status']=='READY_FOR_HUMAN')x=await _client.take(w['work_id']);if(!mounted)return;await Navigator.push(context,MaterialPageRoute(builder:(_)=>_Review(client:_client,work:x)));_load();}
}

class _Intake extends StatefulWidget {final ResidenceWorkClient client;final String roomId;const _Intake({required this.client,required this.roomId});@override State<_Intake> createState()=>_IntakeState();}
class _IntakeState extends State<_Intake>{
 final goal=TextEditingController(),req=TextEditingController(),con=TextEditingController(),out=TextEditingController(text:'strategies and options');String lang='en';List<PlatformFile> files=[];Map<String,dynamic>? work;bool busy=false;
 @override void dispose(){goal.dispose();req.dispose();con.dispose();out.dispose();super.dispose();}
 Future<void> create() async {if(goal.text.trim().isEmpty)return;setState(()=>busy=true);try{var w=await widget.client.create(goal.text.trim(),lang,req.text.split('\n').where((x)=>x.trim().isNotEmpty).toList(),con.text.split('\n').where((x)=>x.trim().isNotEmpty).toList(),out.text.trim(),roomId:widget.roomId);for(final f in files) {
   w=await widget.client.addMaterial(w['work_id'],f);
 }w=await widget.client.interpret(w['work_id']);if(mounted)setState(()=>work=w);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}finally{if(mounted)setState(()=>busy=false);}}
 Future<void> pick() async {final r=await FilePicker.platform.pickFiles(allowMultiple:true,withData:true);if(r!=null)setState(()=>files=r.files);}
 @override Widget build(BuildContext c)=>Scene(eyebrow:'HUMAN RESIDENCE · NEW WORK',title:'Create Work',subtitle:'Your thought becomes a reviewable interpretation. Nothing proceeds until you confirm it.',children:[
  SpatialPanel(title:'THOUGHT / GOAL',child:TextField(controller:goal,maxLines:6,decoration:const InputDecoration(border:OutlineInputBorder(),hintText:'Write naturally, in English, हिन्दी or मराठी.'))),
  SpatialPanel(title:'MATERIALS',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[FilledButton.icon(onPressed:pick,icon:const Icon(Icons.attach_file),label:const Text('ADD FILES / IMAGES')),Text(files.isEmpty?'No materials attached.':files.map((x)=>x.name).join(' · '))])),
  SpatialPanel(title:'REQUIREMENTS',child:TextField(controller:req,maxLines:3,decoration:const InputDecoration(border:OutlineInputBorder()))),
  SpatialPanel(title:'CONSTRAINTS',child:TextField(controller:con,maxLines:3,decoration:const InputDecoration(border:OutlineInputBorder()))),
  SpatialPanel(title:'EXPECTED OUTPUT',child:TextField(controller:out,decoration:const InputDecoration(border:OutlineInputBorder()))),
  SpatialPanel(title:'LANGUAGE',child:DropdownButton(value:lang,onChanged:(v)=>setState(()=>lang=v!),items:const[DropdownMenuItem(value:'en',child:Text('English')),DropdownMenuItem(value:'hi',child:Text('हिन्दी')),DropdownMenuItem(value:'mr',child:Text('मराठी'))])),
  FilledButton(onPressed:busy?null:create,child:Text(busy?'INTERPRETING…':'INTERPRET REQUEST')),
  if(work!=null)_Confirmation(client:widget.client,work:work!)
 ]);}

class _Confirmation extends StatefulWidget{final ResidenceWorkClient client;final Map<String,dynamic> work;const _Confirmation({required this.client,required this.work});@override State<_Confirmation> createState()=>_ConfirmationState();}
class _ConfirmationState extends State<_Confirmation>{final correction=TextEditingController();bool busy=false;@override void dispose(){correction.dispose();super.dispose();}
 Future<void> act(bool yes)async{setState(()=>busy=true);try{final w=await widget.client.confirm(widget.work['work_id'],yes,correction:yes?null:correction.text);if(!mounted)return;if(yes) {
   Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>_Review(client:widget.client,work:w)));
 } else {
   setState(()=>busy=false);
 }}catch(e){if(mounted){setState(()=>busy=false);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}}}
 @override Widget build(BuildContext c){final i=Map<String,dynamic>.from(widget.work['interpretation']);return SpatialPanel(title:'IS THIS WHAT YOU MEANT?',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('GOAL · ${i['goal']}'),Text('OUTPUT · ${i['expected_output']}'),Text('LANGUAGE · ${i['language']} · INTENT · ${i['intent']}'),Text('REQUIREMENTS · ${(i['requirements'] as List).join(' · ')}'),Text('CONSTRAINTS · ${(i['constraints'] as List).join(' · ')}'),const SizedBox(height:12),TextField(controller:correction,maxLines:3,decoration:const InputDecoration(border:OutlineInputBorder(),hintText:'Correction, if the interpretation is wrong.')),Wrap(spacing:8,children:[FilledButton(onPressed:busy?null:()=>act(true),child:const Text('YES, PROCEED')),OutlinedButton(onPressed:busy?null:()=>act(false),child:const Text('THAT IS NOT WHAT I MEANT'))])]));}}
class _Review extends StatefulWidget{final ResidenceWorkClient client;final Map<String,dynamic> work;const _Review({required this.client,required this.work});@override State<_Review> createState()=>_ReviewState();}
class _ReviewState extends State<_Review>{late Map<String,dynamic>w;final challenge=TextEditingController();final modification=TextEditingController();bool busy=false;@override void initState(){super.initState();w=widget.work;}@override void dispose(){challenge.dispose();modification.dispose();super.dispose();}
 Future<void> refresh(Future<Map<String,dynamic>> f)async{setState(()=>busy=true);try{final next=await f;if(mounted)setState(()=>w=next);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}finally{if(mounted)setState(()=>busy=false);}}
 @override Widget build(BuildContext c){final arts=List<Map<String,dynamic>>.from(w['artifacts']??[]);final opts=arts.isEmpty?<Map<String,dynamic>>[]:List<Map<String,dynamic>>.from(arts.last['options']??[]);return Scene(eyebrow:'HUMAN RESIDENCE · REVIEW',title:'Review Work',subtitle:'TAKE means you review the prepared work. It never means the system made your decision.',children:[
  SpatialPanel(title:'STATUS',child:Text("${w['status']} · Journey ${w['journey_id'] ?? 'not created'}")),
  for (final a in arts)
    SpatialPanel(
      title: 'PREPARED STRATEGIES',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: opts
            .map(
              (o) => ListTile(
                title: Text('${o['title']}'),
                subtitle: Text('${o['description']}'),
                trailing: FilledButton(
                  onPressed: busy
                      ? null
                      : () => refresh(
                          widget.client.decide(
                            w['work_id'],
                            o['option_id'],
                            modification.text,
                          ),
                        ),
                  child: const Text('SELECT'),
                ),
              ),
            )
            .toList(),
      ),
    ),
  SpatialPanel(
    title: 'HUMAN CHALLENGE',
    child: Column(
      children: [
        TextField(
          controller: challenge,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Challenge premise, evidence or assumptions.',
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () => refresh(widget.client.challenge(
                    w['work_id'], 'PREMISE', challenge.text)),
              child: const Text('CHALLENGE PREMISE'),
            ),
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () => refresh(widget.client.challenge(
                    w['work_id'], 'EVIDENCE', challenge.text)),
              child: const Text('REQUEST EVIDENCE'),
            ),
          ],
        ),
      ],
    ),
  ),
  _ResearchPanel(
    client: widget.client,
    work: w,
    onUpdate: (x) => setState(() => w = x),
  ),
  if (w['status'] == 'DECISION_READY')
    SpatialPanel(
      title: 'ACTION SAFETY GATE',
      child: FilledButton(
        onPressed: busy
            ? null
            : () => refresh(widget.client.authorize(w['work_id'])),
        child: const Text('AUTHORIZE ACTION'),
      ),
    ),
  
 ]);}}

class _ResearchPanel extends StatefulWidget {
  final ResidenceWorkClient client; final Map<String,dynamic> work; final ValueChanged<Map<String,dynamic>> onUpdate;
  const _ResearchPanel({required this.client,required this.work,required this.onUpdate});
  @override State<_ResearchPanel> createState()=>_ResearchPanelState();
}
class _ResearchPanelState extends State<_ResearchPanel>{
  bool busy=false;
  Future<void> _run() async {
    setState(()=>busy=true);
    try { final w=await widget.client.authorizeResearch(widget.work['work_id']); if(mounted)widget.onUpdate(w); }
    catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}
    finally{if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context){
    final info=Map<String,dynamic>.from(widget.work['information_need']??{});
    final research=Map<String,dynamic>.from(widget.work['research']??{});
    final sources=List<dynamic>.from(research['sources']??[]); final state=info['state']??'NOT_ANALYZED';
    return SpatialPanel(title:'INFORMATION & RESEARCH',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('EVIDENCE STATE · $state'), Text("${info['reason'] ?? ''}"),
      if((info['missing'] as List?)?.isNotEmpty??false) Text("MISSING · ${(info['missing'] as List).join(' · ')}"),
      Text("RESEARCH SCOPE · ${research['scope'] ?? 'public_web'}"),
      if(sources.isNotEmpty) Text('SOURCES ACQUIRED · ${sources.length} (verification still required)'),
      const SizedBox(height:8),
      if(state=='NEEDS_INFORMATION'||state=='INSUFFICIENT_EVIDENCE') FilledButton.icon(onPressed:busy?null:_run,icon:const Icon(Icons.travel_explore),label:Text(busy?'RESEARCHING…':'AUTHORIZE PUBLIC WEB RESEARCH')),
      if(sources.isNotEmpty) ...sources.take(5).map((s)=>ListTile(title:Text("${s['title'] ?? 'Untitled source'}"),subtitle:Text("${s['source_url'] ?? ''}\n${s['snippet'] ?? ''}"))),
      const Text('PUBLIC WEB ONLY · No private systems, purchases, credentials, or external actions.'),
    ]));
  }
}
