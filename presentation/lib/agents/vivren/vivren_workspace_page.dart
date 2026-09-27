import 'package:flutter/material.dart';
import '../s7/s7_environment_page.dart';
class VivrenWorkspacePage extends StatelessWidget {
  final String? sessionId;
  const VivrenWorkspacePage({super.key,this.sessionId});
  @override Widget build(BuildContext context) => Column(children:[
    Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(20,14,20,10),child:const Row(children:[
      Icon(Icons.psychology_alt_outlined),SizedBox(width:10),Expanded(child:Text('VIVREN · CRITICAL REASONING',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,letterSpacing:1.2))),
      Text('6 inspection surfaces',style:TextStyle(fontSize:9,color:Colors.white54)),
    ])),
    Expanded(child:S7EnvironmentPage(key:const ValueKey('vivren-s7-environment'),sessionId:sessionId,initialRoom:'vivren')),
  ]);
}
