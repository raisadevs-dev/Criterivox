import 'package:flutter/material.dart';
import 'medrus_presentation.dart';
class MedrusWorkspacePage extends StatelessWidget {
  const MedrusWorkspacePage({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('MEDRUS · EVIDENCE & EXPERIMENT')),
    body:ListView(padding:const EdgeInsets.all(20),children:[
      for(final c in MedrusPresentation.capabilities)
        Card(child:ListTile(leading:Icon(c.icon),title:Text(c.label),subtitle:Text(c.description))),
      const SizedBox(height:12),
      const Card(child:Padding(padding:EdgeInsets.all(16),child:Text(
        'Evidence records preserve observations and provenance. Experiments record procedures and outcomes. Neither is automatically verification.'
      ))),
    ]),
  );
}
