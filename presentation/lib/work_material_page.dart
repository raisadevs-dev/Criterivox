import 'dart:convert';
import 'package:flutter/material.dart';
import 'presentation/api_client.dart';
import 'human_residence_store.dart';
import 'package:http/http.dart' as http;

class WorkMaterialPage extends StatefulWidget {
  final VoidCallback? onBack;
  const WorkMaterialPage({super.key, this.onBack});
  @override State<WorkMaterialPage> createState() => _WorkMaterialPageState();
}
class _WorkMaterialPageState extends State<WorkMaterialPage> {
  List<Map<String,dynamic>> materials=[];
  Map<String,dynamic>? selected;
  bool loading=true;
  String status='';
  final store=HumanResidenceStore();
  String token='';
  final challenge=TextEditingController();
  @override void initState(){super.initState();_load();}
  @override void dispose(){challenge.dispose();super.dispose();}
  Future<void> _load() async {
    setState(()=>loading=true);
    final residence=await store.load(); token=residence?.metadata['session_token']?.toString()??'';
    if(token.isEmpty){setState(()=>status='Open an authenticated Human Residence session before inspecting work materials.');setState(()=>loading=false);return;}
    try { final r=await http.get(CriterivoxApi.uri('/api/work-materials?session_token='+Uri.encodeQueryComponent(token))).timeout(const Duration(seconds:8)); final body=jsonDecode(r.body); if(r.statusCode<200||r.statusCode>=300||body is! Map) throw Exception('Could not load work materials'); final raw=body['materials']; setState(()=>materials=raw is List?raw.whereType<Map>().map((x)=>Map<String,dynamic>.from(x)).toList():[]); if(materials.isNotEmpty)selected=materials.first; } catch(e){setState(()=>status=e.toString().replaceFirst('Exception: ',''));} finally {if(mounted)setState(()=>loading=false);}
  }
  Future<void> _challenge() async {final m=selected;if(m==null||challenge.text.trim().isEmpty)return;try{final r=await http.post(CriterivoxApi.uri('/api/work-materials/'+m['material_id'].toString()+'/challenge'),headers:const {'content-type':'application/json'},body:jsonEncode({'session_token':token,'text':challenge.text.trim()}));if(r.statusCode<200||r.statusCode>=300)throw Exception('Challenge was not saved');setState(()=>status='Challenge recorded and persisted for this material.');challenge.clear();}catch(e){setState(()=>status=e.toString().replaceFirst('Exception: ',''));}}
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title:const Text('Work Materials'),leading:widget.onBack==null?null:IconButton(onPressed:widget.onBack,icon:const Icon(Icons.arrow_back))),
      body: loading?const Center(child:CircularProgressIndicator()):Row(children:[
        SizedBox(width:310,child:ListView(padding:const EdgeInsets.all(16),children:[
          Text('HUMAN WORK',style:TextStyle(color:cs.primary,fontWeight:FontWeight.w900,letterSpacing:1.5)),
          const SizedBox(height:8),const Text('Real service results become inspectable materials here. Machine identifiers stay behind progressive disclosure.'),
          const SizedBox(height:12),if(status.isNotEmpty)Text(status),for(final m in materials)ListTile(
            selected:selected?['material_id']==m['material_id'],
            title:Text(m['title']?.toString()??'Work Material'),
            subtitle:Text((m['material_type']??'work').toString().replaceAll('_',' ')+' · '+(m['status']??'unknown').toString()+' · v'+(m['version']??1).toString()),
            onTap:()=>setState(()=>selected=m))
        ])),
        const VerticalDivider(width:1),
        Expanded(child:selected==null?const Center(child:Text('No work material is available in this authenticated session yet.')):_MaterialDetail(material:selected!,onChallenge:_challenge,challenge:challenge))
      ])
    );
  }
}
class _MaterialDetail extends StatelessWidget {
  final Map<String,dynamic> material;
  final VoidCallback onChallenge;
  final TextEditingController challenge;
  const _MaterialDetail({required this.material,required this.onChallenge,required this.challenge});
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    final content=material['content'] is Map?Map<String,dynamic>.from(material['content']):{};
    final structured=material['structured_data'] is Map?Map<String,dynamic>.from(material['structured_data']):{};
    return SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text(material['title']?.toString()??'Work Material',style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800)),
      const SizedBox(height:6),Text(material['purpose']?.toString()??'',style:TextStyle(color:cs.onSurfaceVariant)),
      const SizedBox(height:16),Wrap(spacing:8,children:[
        Chip(label:Text('State: '+(material['status']??'unknown').toString())),
        Chip(label:Text('Version '+(material['version']??1).toString()))
      ]),
      const SizedBox(height:16),
      _section('What this work says',content.isEmpty?material['status']:content),
      if(structured.isNotEmpty)_section('Structured view',structured),
      _section('What is uncertain',material['uncertainty']),
      _section('Limitations',material['limitations']),
      _section('Assumptions',material['assumptions']),
      _section('Evidence supporting this work',material['evidence_refs']),
      _section('Provenance available for inspection',material['provenance_refs']),
      const SizedBox(height:18),Text('CHALLENGE THIS MATERIAL',style:TextStyle(color:cs.primary,fontWeight:FontWeight.w900,letterSpacing:1.2)),
      const SizedBox(height:6),TextField(controller:challenge,maxLines:3,decoration:const InputDecoration(hintText:'For example: This assumption is incorrect because…')),
      const SizedBox(height:8),OutlinedButton.icon(onPressed:onChallenge,icon:const Icon(Icons.flag_outlined),label:const Text('Record challenge'))
    ]));
  }
  Widget _section(String title,dynamic value)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:8),SelectableText(_pretty(value))])));
  String _pretty(dynamic value){if(value is Map||value is List)return const JsonEncoder.withIndent('  ').convert(value);return value?.toString()??'';}
}
