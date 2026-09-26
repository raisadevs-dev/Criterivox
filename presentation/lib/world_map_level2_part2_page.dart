import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'presentation/criterivox_theme.dart';

class WorldMapLevel2Part2Page extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<String>? onOpenHome;
  const WorldMapLevel2Part2Page({super.key, this.onBack, this.onOpenHome});
  @override State<WorldMapLevel2Part2Page> createState()=>_WorldMapLevel2Part2PageState();
}

class _WorldMapLevel2Part2PageState extends State<WorldMapLevel2Part2Page> {
  Map<String,dynamic>? data;
  String status='Loading canonical Part-II state…';
  final Map<String,int> energy={};
  @override void initState(){super.initState(); _load();}
  Future<void> _load() async {
    try {
      final r=await http.get(Uri.parse('/api/world/level2/part2/state'));
      if(r.statusCode>=200&&r.statusCode<300){
        final decoded=jsonDecode(r.body) as Map<String,dynamic>;
        if(mounted)setState(()=>data=decoded);
      } else if(mounted)setState(()=>status='Part-II runtime returned HTTP ${r.statusCode}.');
    } catch(e){if(mounted)setState(()=>status='Part-II runtime unavailable: $e');}
  }
  Future<void> _post(String path, Map<String,dynamic> body) async {
    try {
      final r=await http.post(Uri.parse('/api/world/level2/part2/$path'),headers:{'content-type':'application/json'},body:jsonEncode(body));
      if(r.statusCode>=200&&r.statusCode<300) { await _load(); }
      else if(mounted) setState(()=>status='Action failed: HTTP ${r.statusCode}');
    } catch(e){if(mounted)setState(()=>status='Action unavailable: $e');}
  }
  @override Widget build(BuildContext context){
    final t=CriterivoxTheme.of(context);
    final homes=(data?['homes'] as List?)?.cast<Map<String,dynamic>>()??const [];
    final ticker=(data?['status_ticker'] as Map?)?.cast<String,dynamic>();
    final budget=(data?['context_budget'] as Map?)?.cast<String,dynamic>()??const {};
    return Scaffold(backgroundColor:t.page,body:SafeArea(child:Column(children:[
      Padding(padding:const EdgeInsets.all(16),child:Row(children:[
        if(widget.onBack!=null)IconButton(onPressed:widget.onBack,icon:Icon(Icons.arrow_back,color:t.text)),
        Expanded(child:Text('WORLD MAP • LEVEL 2 • PART II',style:TextStyle(color:t.text,fontSize:18,fontWeight:FontWeight.w800))),
        IconButton(onPressed:_load,icon:Icon(Icons.refresh,color:t.mutedText)),
      ])),
      Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Align(alignment:Alignment.centerLeft,child:Text(ticker?['human_text']?.toString()??status,style:TextStyle(color:t.mutedText,fontSize:12)))),
      const SizedBox(height:12),
      Expanded(child:ListView(padding:const EdgeInsets.all(16),children:[
        _home(t,'gateway','Gateway Quarter','Syvax',homes,Icons.router_rounded),
        _home(t,'bloom','Bloom Central Nexus','Bloom',homes,Icons.hub_rounded),
        _home(t,'data','Data Stewardship Quarter','Sandre + Kaelen',homes,Icons.storage_rounded),
        _home(t,'context','Context Quarter','Dharen + Anuka',homes,Icons.account_tree_rounded),
        const SizedBox(height:12),
        _panel(t,'Priority Context Budget',Column(children:budget.entries.map((e)=>Row(children:[Expanded(child:Text(e.key,style:TextStyle(color:t.text))),Text('${e.value}%',style:TextStyle(color:t.primary,fontWeight:FontWeight.w700))])).toList())),
        const SizedBox(height:12),
        _panel(t,'Truth model',Text('LIVE • SIMULATED • HISTORICAL • PLANNED',style:TextStyle(color:t.mutedText))),
      ])),
    ])));
  }
  Widget _home(dynamic t,String id,String name,String owner,List<Map<String,dynamic>> homes,IconData icon){
    final found=homes.where((h)=>h['id']==id).cast<Map<String,dynamic>>().toList();
    final caps=found.isEmpty?const <dynamic>[]:(found.first['capabilities'] as List? )??const [];
    return Card(color:t.surface,child:ExpansionTile(leading:Icon(icon,color:t.primary),title:Text(name,style:TextStyle(color:t.text,fontWeight:FontWeight.w700)),subtitle:Text(owner,style:TextStyle(color:t.mutedText)),children:[
      ...caps.map((c)=>ListTile(title:Text(c['name']?.toString()??'',style:TextStyle(color:t.text,fontSize:12)),subtitle:Text('${c['state']} • ${c['source']}',style:TextStyle(color:t.mutedText,fontSize:10)),trailing:Text(c['action']?.toString()??'',style:TextStyle(color:t.primary,fontSize:10)))),
      Padding(padding:const EdgeInsets.all(12),child:Wrap(spacing:8,children:[
        if(id=='gateway')OutlinedButton(onPressed:()=>_post('ui-intents',{'status':'READY'}),child:const Text('Refresh UI actions')),
        if(id=='gateway')OutlinedButton(onPressed:()=>_post('steering',{'action':'pause'}),child:const Text('Pause')),
        if(id=='gateway')OutlinedButton(onPressed:()=>_post('steering',{'action':'resume'}),child:const Text('Resume')),
        if(id=='bloom')OutlinedButton(onPressed:()=>_post('energy',{'home':'bloom','budget':100}),child:const Text('Apply budget')),
        if(id=='context')OutlinedButton(onPressed:()=>_post('context-budget',{'allocation':{'critical':40,'high':30,'medium':20,'low':10}}),child:const Text('Apply context budget')),
      ])),
    ]));
  }
  Widget _panel(dynamic t,String title,Widget child)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(14),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:t.text,fontWeight:FontWeight.w700)),const SizedBox(height:10),child]));
}
