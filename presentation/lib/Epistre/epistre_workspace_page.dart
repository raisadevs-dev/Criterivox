import 'package:flutter/material.dart';
import 'epistre_presentation.dart';
class EpistreWorkspacePage extends StatelessWidget {
  const EpistreWorkspacePage({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('EPISTRE · EXPLANATION & PROVENANCE')),
    body:ListView(padding:const EdgeInsets.all(20),children:[
      for(final c in EpistrePresentation.capabilities)
        Card(child:ListTile(leading:Icon(c.icon),title:Text(c.label),subtitle:Text(c.description))),
      const SizedBox(height:12),
      const Card(child:Padding(padding:EdgeInsets.all(16),child:Text(
        'Explanation follows recorded artifact lineage. Missing provenance remains visible and is never silently inferred.'
      ))),
    ]),
  );
}
