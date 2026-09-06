import 'package:flutter/material.dart';
import '../presentation/presentation_state.dart';

class CharacterChatPage extends StatelessWidget {
  final PresentationState? state;
  final bool busy;
  final ValueChanged<String> onSend;
  final VoidCallback onOpenTask;
  const CharacterChatPage({super.key, required this.state, required this.busy, required this.onSend, required this.onOpenTask});

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF050712),
    child: Row(children: [
      const SizedBox(width: 220, child: _AgentRail()),
      Expanded(child: _Conversation(state: state, busy: busy, onSend: onSend, onOpenTask: onOpenTask)),
      SizedBox(width: 280, child: _Context(state: state)),
    ]),
  );
}

class _AgentRail extends StatelessWidget {
  const _AgentRail();
  @override Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0x241E2441)))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.fromLTRB(18,24,18,16), child: Text('CHARACTER NETWORK', style: TextStyle(color: Color(0xFF858DAA),fontSize:10,fontWeight:FontWeight.w700,letterSpacing:1.2))),
      _Agent('Syvax', 'Dialogue + routing', Icons.hub_rounded, true),
      _Agent('Dharen', 'Structural analysis', Icons.analytics_rounded, false),
      const Spacer(),
      const Padding(padding: EdgeInsets.all(18), child: Text('Future character members appear here as their capabilities become operational.',style:TextStyle(color:Color(0xFF656D8B),fontSize:10,height:1.45))),
    ]),
  );
}
class _Agent extends StatelessWidget { final String name,role; final IconData icon; final bool active; const _Agent(this.name,this.role,this.icon,this.active); @override Widget build(BuildContext context)=>ListTile(leading:CircleAvatar(backgroundColor:const Color(0xFF211A52),child:Icon(icon,color:const Color(0xFFB19CFF),size:18)),title:Text(name,style:const TextStyle(color:Colors.white,fontSize:13,fontWeight:FontWeight.w600)),subtitle:Text(role,style:const TextStyle(color:Color(0xFF777F9E),fontSize:9)),selected:active,selectedTileColor:const Color(0x331E194A)); }

class _Conversation extends StatefulWidget { final PresentationState? state; final bool busy; final ValueChanged<String> onSend; final VoidCallback onOpenTask; const _Conversation({required this.state,required this.busy,required this.onSend,required this.onOpenTask}); @override State<_Conversation> createState()=>_ConversationState(); }
class _ConversationState extends State<_Conversation>{ final input=TextEditingController(); @override void dispose(){input.dispose();super.dispose();} void send(){final text=input.text.trim();if(text.isEmpty||widget.busy)return;input.clear();widget.onSend(text);} @override Widget build(BuildContext context){final s=widget.state;return Column(children:[Container(height:72,padding:const EdgeInsets.symmetric(horizontal:22),decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0x241E2441)))),child:const Row(children:[Icon(Icons.forum_rounded,color:Color(0xFF9A83FF)),SizedBox(width:12),Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Character Chat',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w700)),Text('Conversations, handoffs and notifications',style:TextStyle(color:Color(0xFF777F9E),fontSize:10))]),Spacer(),Icon(Icons.notifications_none_rounded)])),Expanded(child:ListView(padding:const EdgeInsets.all(24),children:[if(s==null)const Padding(padding:EdgeInsets.only(top:80),child:Column(children:[Icon(Icons.hub_rounded,color:Color(0xFF9A83FF),size:54),SizedBox(height:16),Text('Talk with Syvax',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w700)),SizedBox(height:7),Text('Tell Criterivox what you want. Syvax routes work to the appropriate character.',textAlign:TextAlign.center,style:TextStyle(color:Color(0xFF858DAA),fontSize:12))])),if(s?.message!=null)_Bubble(s!.agentId,s.message!),if(s?.taskId!=null)_Task(s!,widget.onOpenTask)])),Padding(padding:const EdgeInsets.fromLTRB(18,0,18,18),child:Row(children:[Expanded(child:TextField(controller:input,minLines:1,maxLines:5,onSubmitted:(_)=>send(),decoration:InputDecoration(hintText:'Message Syvax…',filled:true,fillColor:const Color(0xFF10142A),border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none)))),const SizedBox(width:8),IconButton.filled(onPressed:widget.busy?null:send,icon:const Icon(Icons.arrow_upward_rounded))]))]);}}
class _Bubble extends StatelessWidget{final String who,text;const _Bubble(this.who,this.text);@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFF10142A),borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(who,style:const TextStyle(color:Color(0xFF9E91FF),fontSize:10,fontWeight:FontWeight.w700)),const SizedBox(height:5),Text(text,style:const TextStyle(color:Color(0xFFD2D5E2),fontSize:12.5,height:1.45))]));}
class _Task extends StatelessWidget{final PresentationState state;final VoidCallback open;const _Task(this.state,this.open);@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0x121F1A4C),borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0x453D337F))),child:Row(children:[Expanded(child:Text('${state.taskId} • ${state.taskState??'ACTIVE'}',style:const TextStyle(color:Color(0xFFC8C2E9),fontSize:11))),TextButton(onPressed:open,child:const Text('Open task'))]));}
class _Context extends StatelessWidget{final PresentationState? state;const _Context({required this.state});@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(20),decoration:const BoxDecoration(border:Border(left:BorderSide(color:Color(0x241E2441)))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('AGENT CONTEXT',style:TextStyle(color:Color(0xFF858DAA),fontSize:10,fontWeight:FontWeight.w700,letterSpacing:1.2)),const SizedBox(height:16),const Text('Syvax',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w700)),const Text('Human-system dialogue + routing',style:TextStyle(color:Color(0xFF7D86A4),fontSize:10)),const SizedBox(height:25),Text('Connection     LIVE',style:const TextStyle(color:Color(0xFFC6CAD8),fontSize:10)),Text('Task              ${state?.taskId??'None'}',style:const TextStyle(color:Color(0xFFC6CAD8),fontSize:10)),Text('State             ${state?.taskState??'IDLE'}',style:const TextStyle(color:Color(0xFFC6CAD8),fontSize:10)),const SizedBox(height:25),const Text('NOTIFICATIONS',style:TextStyle(color:Color(0xFF858DAA),fontSize:10,fontWeight:FontWeight.w700)),const SizedBox(height:10),Text(state?.message??'No new runtime notification.',style:const TextStyle(color:Color(0xFF9299B4),fontSize:11,height:1.5))]));}
