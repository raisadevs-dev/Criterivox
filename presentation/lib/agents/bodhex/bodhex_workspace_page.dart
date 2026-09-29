import 'package:flutter/material.dart';
import '../../workspaces/decision/action_quarter_page.dart';
import 'bodhex_presentation.dart';
class BodhexWorkspacePage extends StatelessWidget {
  final VoidCallback? onOpenDecisionChamber;
  const BodhexWorkspacePage({super.key,this.onOpenDecisionChamber});
  @override Widget build(BuildContext context)=>Column(children:[
    Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(20,14,20,10),child:Row(children:[
      const Icon(Icons.construction_outlined),const SizedBox(width:10),
      const Expanded(child:Text('BODHEX · INSIGHT & ACTION PREPARATION',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,letterSpacing:1.2))),
      Text(BodhexPresentation.capabilities.length.toString()+' action surfaces',style:TextStyle(fontSize:9,color:Colors.white54)),
    ])),
    Expanded(child:DecisionActionQuarterPage(key:const ValueKey('bodhex-decision-chamber'),onBack:()=>Navigator.maybePop(context),onOpenHumanDecisionWorkspace:onOpenDecisionChamber)),
  ]);
}
