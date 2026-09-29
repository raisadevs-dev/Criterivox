import 'package:flutter/material.dart';
import 'viveda_presentation.dart';
class VivedaWorkspacePage extends StatelessWidget {
  const VivedaWorkspacePage({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('VIVEDA · KNOWLEDGE CONSOLIDATION')),
    body:ListView(padding:const EdgeInsets.all(20),children:[
      for(final c in VivedaPresentation.capabilities)
        Card(child:ListTile(leading:Icon(c.icon),title:Text(c.label),subtitle:Text(c.description))),
      const SizedBox(height:12),
      const Card(child:Padding(padding:EdgeInsets.all(16),child:Text(
        'Knowledge maturity remains evidence- and verification-bound. Candidate knowledge is not presented as established truth.'
      ))),
    ]),
  );
}
