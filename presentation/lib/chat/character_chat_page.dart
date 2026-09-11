import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../character/character_runtime.dart';
import '../presentation/criterivox_theme.dart';
import '../presentation/presentation_state.dart';

class CharacterChatPage extends StatefulWidget {
  final PresentationState? state;
  final bool busy;
  final String selectedAgent;
  final ValueChanged<String> onSelectAgent;
  final void Function(String message, String agent, List<Map<String, dynamic>> references) onSend;
  final VoidCallback onOpenTask;

  const CharacterChatPage({super.key,required this.state,required this.busy,required this.selectedAgent,required this.onSelectAgent,required this.onSend,required this.onOpenTask});

  @override
  State<CharacterChatPage> createState()=>_CharacterChatPageState();
}

class _ChatMessage { final String sender; final String text; const _ChatMessage({required this.sender,required this.text}); }
class _CharacterInfo { final String id; final String name; final String role; const _CharacterInfo(this.id,this.name,this.role); }

class _CharacterChatPageState extends State<CharacterChatPage> {
  final input=TextEditingController();
  final Map<String,List<_ChatMessage>> conversations=<String,List<_ChatMessage>>{};
  final Map<String,List<Map<String,dynamic>>> references=<String,List<Map<String,dynamic>>>{};
  String? lastRuntimeSignature;

  static const members=< _CharacterInfo>[
    _CharacterInfo('syvax','Syvax','Dialogue + routing'),
    _CharacterInfo('dharen','Dharen','Context architecture'),
    _CharacterInfo('anuka','Anuka','Adaptive context'),
    _CharacterInfo('sandre','Sandre','Data stewardship'),
    _CharacterInfo('kaelen','Kaelen','Build + experimentation'),
    _CharacterInfo('vivren','Vivren','Discernment'),
    _CharacterInfo('tarkis','Tarkis','Hypothesis + evidence'),
  ];

  static const prompts=<String,List<String>>{
    'syvax':['Clarify this task.','Route this work.','Summarize the current intent.'],
    'dharen':['Build the current context.','Show missing context.','Explain the current structure.'],
    'anuka':['What changed?','Find a context mismatch.','Re-check the current requirement.'],
    'sandre':['Inspect the data foundation.','Show provenance gaps.','Check data readiness.'],
    'kaelen':['Prepare a controlled experiment.','Inspect scratchpad work.','Record the current build state.'],
    'vivren':['Challenge this interpretation.','Find ambiguity.','Separate evidence from assumption.'],
    'tarkis':['Form a hypothesis.','List supporting evidence.','Identify what would falsify it.'],
  };

  @override
  void initState(){
    super.initState();
    for(final member in members){ conversations[member.id]=< _ChatMessage>[]; references[member.id]=<Map<String,dynamic>>[]; }
    _recordRuntimeMessage(widget.state);
  }

  @override
  void didUpdateWidget(covariant CharacterChatPage oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.state!=oldWidget.state)_recordRuntimeMessage(widget.state);
  }

  void _recordRuntimeMessage(PresentationState? state){
    if(state==null||state.event!='CHARACTER_CHAT_RESPONSE')return;
    final message=state.message?.trim();
    if(message==null||message.isEmpty)return;
    final target=state.agentId.toLowerCase();
    if(!conversations.containsKey(target))return;
    final signature='${state.taskId}|$target|$message|${state.taskUpdatedAt}';
    if(lastRuntimeSignature==signature)return;
    lastRuntimeSignature=signature;
    if(!mounted)return;
    setState(()=>conversations[target]!.add(_ChatMessage(sender:target,text:message)));
  }

  @override
  void dispose(){ input.dispose(); super.dispose(); }

  List<_ChatMessage> get activeMessages=>conversations[widget.selectedAgent]??< _ChatMessage>[];
  List<Map<String,dynamic>> get activeReferences=>references[widget.selectedAgent]??<Map<String,dynamic>>[];

  void _send(){
    final text=input.text.trim();
    if(text.isEmpty||widget.busy)return;
    setState((){ activeMessages.add(_ChatMessage(sender:'user',text:text)); input.clear(); });
    widget.onSend(text,widget.selectedAgent,List<Map<String,dynamic>>.from(activeReferences));
  }

  void _sendChoice(String text){
    if(widget.busy)return;
    setState(()=>activeMessages.add(_ChatMessage(sender:'user',text:text)));
    widget.onSend(text,widget.selectedAgent,List<Map<String,dynamic>>.from(activeReferences));
  }

  Future<void> _attach() async{
    final result=await FilePicker.platform.pickFiles(withData:true,allowMultiple:false);
    if(result==null||result.files.isEmpty)return;
    final file=result.files.single; final bytes=file.bytes;
    if(bytes==null){_error('The selected file could not be read in the browser.');return;}
    if(bytes.length>4*1024*1024){_error('Reference files are limited to 4 MB each.');return;}
    setState(()=>activeReferences.add({'name':file.name,'kind':_kind(file.extension),'size_bytes':bytes.length,'content_base64':base64Encode(bytes)}));
  }

  void _error(String text){if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(text)));}

  @override
  Widget build(BuildContext context)=>LayoutBuilder(builder:(context,constraints){
    final narrow=constraints.maxWidth<900;
    return Container(color:CriterivoxTheme.of(context).page,child:Row(children:[
      if(!narrow)SizedBox(width:255,child:_CharacterPicker(selected:widget.selectedAgent,onSelect:widget.onSelectAgent)),
      Expanded(child:_Conversation(state:widget.state,busy:widget.busy,target:widget.selectedAgent,messages:activeMessages,references:activeReferences,input:input,onSend:_send,onChoice:_sendChoice,onAttach:_attach,onOpenTask:widget.onOpenTask,onSelectAgent:widget.onSelectAgent,showPicker:narrow)),
      if(!narrow)SizedBox(width:290,child:_ContextPanel(state:widget.state,target:widget.selectedAgent,onOpenTask:widget.onOpenTask)),
    ]));
  });

  String _kind(String? extension){
    switch(extension?.toLowerCase()){
      case 'csv': return 'dataset';
      case 'png': case 'jpg': case 'jpeg': case 'webp': return 'image';
      case 'pdf': case 'txt': case 'doc': case 'docx': return 'document';
      default: return 'file';
    }
  }
}

class _CharacterPicker extends StatelessWidget{
  final String selected; final ValueChanged<String> onSelect;
  const _CharacterPicker({required this.selected,required this.onSelect});
  @override
  Widget build(BuildContext context){
    final theme=CriterivoxTheme.of(context);
    return Container(decoration:BoxDecoration(border:Border(right:BorderSide(color:theme.border))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Padding(padding:const EdgeInsets.fromLTRB(18,24,18,16),child:Text('CHARACTER NETWORK',style:TextStyle(color:theme.mutedText,fontSize:10,fontWeight:FontWeight.w700,letterSpacing:1.2))),
      Expanded(child:ListView.builder(itemCount:_CharacterChatPageState.members.length,itemBuilder:(context,index){final member=_CharacterChatPageState.members[index];return _AgentTile(member:member,selected:selected==member.id,onTap:()=>onSelect(member.id));})),
      Padding(padding:const EdgeInsets.all(18),child:Text('Each character has an independent conversation history. Task, context, evidence and runtime state remain shared and authoritative.',style:TextStyle(color:theme.mutedText,fontSize:10,height:1.45))),
    ]));
  }
}

class _AgentTile extends StatelessWidget{
  final _CharacterInfo member; final bool selected; final VoidCallback onTap;
  const _AgentTile({required this.member,required this.selected,required this.onTap});
  @override
  Widget build(BuildContext context){
    final theme=CriterivoxTheme.of(context);
    return ListTile(onTap:onTap,selected:selected,selectedTileColor:theme.primary.withValues(alpha:.12),leading:CharacterRuntimeView(characterId:member.id,state:selected?'COMMUNICATE':'IDLE',width:48,height:56),title:Text(member.name,style:TextStyle(color:theme.text,fontSize:13,fontWeight:FontWeight.w600)),subtitle:Text(member.role,style:TextStyle(color:theme.mutedText,fontSize:9)));
  }
}

class _Conversation extends StatelessWidget{
  final PresentationState? state; final bool busy; final String target; final List<_ChatMessage> messages; final List<Map<String,dynamic>> references; final TextEditingController input; final VoidCallback onSend,onAttach,onOpenTask; final ValueChanged<String> onSelectAgent,onChoice; final bool showPicker;
  const _Conversation({required this.state,required this.busy,required this.target,required this.messages,required this.references,required this.input,required this.onSend,required this.onChoice,required this.onAttach,required this.onOpenTask,required this.onSelectAgent,required this.showPicker});
  @override
  Widget build(BuildContext context){
    final theme=CriterivoxTheme.of(context); final member=_CharacterChatPageState.members.firstWhere((item)=>item.id==target); final runtimeState=state?.agentId.toLowerCase()==target?(state?.characterState??'IDLE'):'IDLE'; final promptList=_CharacterChatPageState.prompts[target]??const <String>[];
    return Column(children:[
      Container(height:86,padding:const EdgeInsets.symmetric(horizontal:22),decoration:BoxDecoration(border:Border(bottom:BorderSide(color:theme.border))),child:Row(children:[CharacterRuntimeView(characterId:target,state:runtimeState,width:60,height:68),const SizedBox(width:12),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Chat with ${member.name}',style:TextStyle(color:theme.text,fontSize:18,fontWeight:FontWeight.w700)),Text(member.role,style:TextStyle(color:theme.mutedText,fontSize:10))])),if(showPicker)PopupMenuButton<String>(initialValue:target,onSelected:onSelectAgent,itemBuilder:(_)=>[for(final info in _CharacterChatPageState.members)PopupMenuItem(value:info.id,child:Text('${info.name} · ${info.role}'))]),if(busy)SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:theme.primary))])),
      Expanded(child:ListView(padding:const EdgeInsets.all(24),children:[
        _Welcome(member:member),
        Wrap(spacing:7,runSpacing:7,children:[for(final prompt in promptList)ActionChip(label:Text(prompt),onPressed:busy?null:()=>onChoice(prompt))]),
        const SizedBox(height:14),
        for(final message in messages)_MessageBubble(message:message,displayName:member.name),
        if(state?.agentId.toLowerCase()==target&&state?.event=='HANDOFF_PROPOSED')_HandoffChoices(busy:busy,onHandoff:()=>onChoice('Hand over this task to Dharen.'),onContinue:()=>onChoice('I will continue the task here.')),
        if(state?.agentId.toLowerCase()==target&&state?.taskId!=null)_TaskCard(state:state!,onOpen:onOpenTask),
      ])),
      _Composer(input:input,references:references,busy:busy,name:member.name,onSend:onSend,onAttach:onAttach),
    ]);
  }
}

class _Welcome extends StatelessWidget{final _CharacterInfo member;const _Welcome({required this.member});@override Widget build(BuildContext context){final theme=CriterivoxTheme.of(context);return Container(margin:const EdgeInsets.only(bottom:18),padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:theme.surfaceStrong,borderRadius:BorderRadius.circular(18),border:Border.all(color:theme.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${member.name} workspace',style:TextStyle(color:theme.text,fontSize:19,fontWeight:FontWeight.w700)),const SizedBox(height:7),Text('This conversation belongs only to ${member.name}. Shared task and context state remains outside the conversation buffer.',style:TextStyle(color:theme.mutedText,fontSize:11.5,height:1.5))]));}}
class _MessageBubble extends StatelessWidget{final _ChatMessage message;final String displayName;const _MessageBubble({required this.message,required this.displayName});@override Widget build(BuildContext context){final theme=CriterivoxTheme.of(context);final user=message.sender=='user';return Align(alignment:user?Alignment.centerRight:Alignment.centerLeft,child:Container(constraints:const BoxConstraints(maxWidth:680),margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:user?theme.primary.withValues(alpha:.14):theme.surfaceStrong,borderRadius:BorderRadius.circular(16),border:Border.all(color:user?theme.primary.withValues(alpha:.35):theme.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[if(!user)...[Text(displayName,style:TextStyle(color:theme.primary,fontSize:10,fontWeight:FontWeight.w700)),const SizedBox(height:5)],Text(message.text,style:TextStyle(color:theme.text,fontSize:12.5,height:1.45))])));}}
class _Composer extends StatelessWidget{final TextEditingController input;final List<Map<String,dynamic>> references;final bool busy;final String name;final VoidCallback onSend,onAttach;const _Composer({required this.input,required this.references,required this.busy,required this.name,required this.onSend,required this.onAttach});@override Widget build(BuildContext context){final theme=CriterivoxTheme.of(context);return Container(padding:const EdgeInsets.fromLTRB(18,10,18,18),decoration:BoxDecoration(border:Border(top:BorderSide(color:theme.border))),child:Column(children:[if(references.isNotEmpty)SizedBox(height:42,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:references.length,itemBuilder:(context,index)=>Chip(avatar:const Icon(Icons.attach_file_rounded,size:14),label:Text(references[index]['name'] as String,maxLines:1,overflow:TextOverflow.ellipsis)),separatorBuilder:(_,__)=>const SizedBox(width:6))),Row(children:[IconButton(tooltip:'Attach reference',onPressed:busy?null:onAttach,icon:const Icon(Icons.attach_file_rounded)),Expanded(child:TextField(controller:input,minLines:1,maxLines:5,onSubmitted:(_)=>onSend(),decoration:InputDecoration(hintText:'Message $name…'))),const SizedBox(width:8),IconButton.filled(onPressed:busy?null:onSend,icon:const Icon(Icons.arrow_upward_rounded))])]));}}
class _HandoffChoices extends StatelessWidget{final bool busy;final VoidCallback onHandoff,onContinue;const _HandoffChoices({required this.busy,required this.onHandoff,required this.onContinue});@override Widget build(BuildContext context){final theme=CriterivoxTheme.of(context);return Container(margin:const EdgeInsets.only(bottom:14),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:theme.surfaceStrong,borderRadius:BorderRadius.circular(16),border:Border.all(color:theme.border)),child:Wrap(spacing:8,runSpacing:8,children:[OutlinedButton.icon(onPressed:busy?null:onHandoff,icon:const Icon(Icons.forward_rounded,size:16),label:const Text('Hand over to Dharen')),FilledButton.icon(onPressed:busy?null:onContinue,icon:const Icon(Icons.person_rounded,size:16),label:const Text('Continue here'))]));}}
class _TaskCard extends StatelessWidget{final PresentationState state;final VoidCallback onOpen;const _TaskCard({required this.state,required this.onOpen});@override Widget build(BuildContext context){final theme=CriterivoxTheme.of(context);return Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:theme.surfaceStrong,borderRadius:BorderRadius.circular(14),border:Border.all(color:theme.border)),child:Row(children:[Expanded(child:Text('${state.taskId} • ${state.taskState??'ACTIVE'}',style:TextStyle(color:theme.text,fontSize:11))),TextButton(onPressed:onOpen,child:const Text('Open workspace'))]));}}
class _ContextPanel extends StatelessWidget{final PresentationState? state;final String target;final VoidCallback onOpenTask;const _ContextPanel({required this.state,required this.target,required this.onOpenTask});@override Widget build(BuildContext context){final theme=CriterivoxTheme.of(context);final member=_CharacterChatPageState.members.firstWhere((item)=>item.id==target);return Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(border:Border(left:BorderSide(color:theme.border))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('ACTIVE CONTEXT',style:TextStyle(color:theme.mutedText,fontSize:10,fontWeight:FontWeight.w700,letterSpacing:1.2)),const SizedBox(height:16),CharacterRuntimeView(characterId:target,state:state?.agentId.toLowerCase()==target?(state?.characterState??'IDLE'):'IDLE',width:120,height:140),Text(member.name,style:TextStyle(color:theme.text,fontSize:20,fontWeight:FontWeight.w700)),Text(member.role,style:TextStyle(color:theme.mutedText,fontSize:10)),const SizedBox(height:25),_line('Task',state?.taskId??'None',theme),_line('State',state?.taskState??'IDLE',theme),_line('Context',state?.contextId??'Not built',theme),_line('Evidence','${state?.evidence.length??0} items',theme),const SizedBox(height:25),Text('CONVERSATION BOUNDARY',style:TextStyle(color:theme.mutedText,fontSize:10,fontWeight:FontWeight.w700)),const SizedBox(height:10),Text('This chat history is isolated to ${member.name}. Shared runtime state is authoritative and does not become chat history for another character.',style:TextStyle(color:theme.mutedText,fontSize:11,height:1.5)),const Spacer(),if(state?.taskId!=null)FilledButton.icon(onPressed:onOpenTask,icon:const Icon(Icons.dashboard_customize_rounded,size:16),label:const Text('Open current task'))]));}Widget _line(String label,String value,CriterivoxTheme theme)=>Padding(padding:const EdgeInsets.only(bottom:8),child:Row(children:[SizedBox(width:76,child:Text(label,style:TextStyle(color:theme.mutedText,fontSize:10))),Expanded(child:Text(value,style:TextStyle(color:theme.text,fontSize:10,fontWeight:FontWeight.w600)))]));}
