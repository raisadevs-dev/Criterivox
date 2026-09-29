import 'package:flutter/material.dart';
import 'anukor_presentation.dart';
class AnukorWorkspacePage extends StatelessWidget {
  const AnukorWorkspacePage({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('ANUKOR · ADAPTIVE CROSS-HOME TRANSFER')),
    body:ListView(padding:const EdgeInsets.all(20),children:[
      for(final c in AnukorPresentation.capabilities)
        Card(child:ListTile(leading:Icon(c.icon),title:Text(c.label),subtitle:Text(c.description))),
      const SizedBox(height:12),
      const Card(child:Padding(padding:EdgeInsets.all(16),child:Text(
        'Transfer delivery is not claimed by presentation alone. Compatibility, adaptation requirements, record state and provenance remain authoritative.'
      ))),
    ]),
  );
}
