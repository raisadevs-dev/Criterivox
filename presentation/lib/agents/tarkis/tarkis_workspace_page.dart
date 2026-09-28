import 'package:flutter/material.dart';
import '../../workspaces/reasoning/environment_page.dart';
class TarkisWorkspacePage extends StatelessWidget {
  final String? sessionId;
  const TarkisWorkspacePage({super.key,this.sessionId});
  @override Widget build(BuildContext context)=>Column(children:[
    Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(20,14,20,10),child:const Row(children:[
      Icon(Icons.account_tree_outlined),SizedBox(width:10),Expanded(child:Text('TARKIS · HYPOTHESIS EXPLORATION',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,letterSpacing:1.2))),
      Text('5 exploration surfaces',style:TextStyle(fontSize:9,color:Colors.white54)),
    ])),
    Expanded(child:S7EnvironmentPage(key:const ValueKey('tarkis-s7-environment'),sessionId:sessionId,initialRoom:'tarkis')),
  ]);
}
