import 'package:flutter/material.dart';
import '../../workspaces/decision/action_quarter_page.dart';
import 'pramon_presentation.dart';
class PramonWorkspacePage extends StatelessWidget {
  final VoidCallback? onOpenDecisionChamber;
  const PramonWorkspacePage({super.key,this.onOpenDecisionChamber});
  @override Widget build(BuildContext context)=>Column(children:[
    Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(20,14,20,10),child:Row(children:[
      const Icon(Icons.account_tree_outlined),const SizedBox(width:10),
      const Expanded(child:Text('PRAMON · PLANNING & DECISION STRUCTURE',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,letterSpacing:1.2))),
      Text(PramonPresentation.capabilities.length.toString() + ' planning surfaces',style:TextStyle(fontSize:9,color:Colors.white54)),
    ])),
    Expanded(child:DecisionActionQuarterPage(key:const ValueKey('pramon-decision-chamber'),onBack:()=>Navigator.maybePop(context),onOpenHumanDecisionWorkspace:onOpenDecisionChamber)),
  ]);
}
