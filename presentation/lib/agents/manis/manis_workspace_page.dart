import 'package:flutter/material.dart';
import '../../private_room_page.dart';
import 'manis_presentation.dart';
class ManisWorkspacePage extends StatelessWidget {
  final VoidCallback onWorkspace;
  final VoidCallback? onCollaborationRoom;
  const ManisWorkspacePage({super.key,required this.onWorkspace,this.onCollaborationRoom});
  @override Widget build(BuildContext context)=>Column(children:[
    Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(20,14,20,10),child:Row(children:[
      const Icon(Icons.gavel_outlined),const SizedBox(width:10),
      const Expanded(child:Text('MANIS · HUMAN CHALLENGE & OVERSIGHT',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,letterSpacing:1.2))),
      Text(ManisPresentation.capabilities.length.toString()+' challenge surfaces',style:TextStyle(fontSize:9,color:Colors.white54)),
    ])),
    Expanded(child:PrivateRoomPage(key:const ValueKey('manis-private-room'),onWorkspace:onWorkspace,onCollaborationRoom:onCollaborationRoom)),
  ]);
}
