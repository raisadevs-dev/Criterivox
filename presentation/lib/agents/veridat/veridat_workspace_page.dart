import 'package:flutter/material.dart';
import 'veridat_presentation.dart';
class VeridatWorkspacePage extends StatelessWidget {
  const VeridatWorkspacePage({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('VERIDAT · VERIFICATION & GROUNDING')),
    body:ListView(padding:const EdgeInsets.all(20),children:[
      for(final c in VeridatPresentation.capabilities)
        Card(child:ListTile(leading:Icon(c.icon),title:Text(c.label),subtitle:Text(c.description))),
      const SizedBox(height:12),
      const Card(child:Padding(padding:EdgeInsets.all(16),child:Text(
        'Grounded evidence is not automatically verified truth. Contradictions, temporal limits, integrity state and missing evidence remain visible.'
      ))),
    ]),
  );
}
