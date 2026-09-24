import 'package:flutter/material.dart';
import 'character/character_identity.dart';
import 'presentation/criterivox_theme.dart';

class AppIntroductionPage extends StatelessWidget{
  final VoidCallback onOpenWorkspace;
  final VoidCallback onOpenCivilization;
  final ValueChanged<String>? onOpenCharacter;
  const AppIntroductionPage({super.key,required this.onOpenWorkspace,required this.onOpenCivilization,this.onOpenCharacter});
  @override Widget build(BuildContext context){
    final t=CriterivoxTheme.of(context);
    return SingleChildScrollView(padding:const EdgeInsets.fromLTRB(24,24,24,40),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      _hero(t),const SizedBox(height:16),
      _section(t,'WHAT IS CRITERIVOX','Criterivox is a human decision-support system. It helps you organize a situation, work with context and evidence, examine alternatives, inspect explanations and keep the human in control of the final decision.'),
      const SizedBox(height:12),
      _section(t,'WHAT CAN I DO HERE','Understand a problem • provide context • investigate supplied or authorized external information • compare possibilities • examine evidence • inspect reasoning • challenge assumptions • make decisions • record outcomes • collaborate.'),
      const SizedBox(height:12),_section(t,'HOW TO USE IT','Tell Criterivox what you are trying to accomplish → provide context and relevant material → let the implemented capabilities work on the problem → inspect the understandable result → challenge or question it → decide → record what happened.'),
      const SizedBox(height:12),_section(t,'WHY DOES THE WORLD EXIST?','World → District → Home → Room → Responsibility. This hierarchy gives human-readable places to understand where system activity belongs. Level 1 explains the world; Level 2 explains useful operational meaning; deeper inspection exposes evidence, reasoning and technical detail when needed.'),
      const SizedBox(height:12),_characters(t),const SizedBox(height:12),
      _section(t,'WHAT IS BLOOM?','Bloom is the living interaction surface that connects a human request to the capabilities Criterivox can actually activate. It is a gateway into the system, not a replacement for the underlying computational work.'),
      const SizedBox(height:12),_section(t,'HUMAN TERRITORY','Human Territory is where your work lives: your private context, decisions, results and collaboration. Criterivox Civilization is the observable system world; Human Territory is the human-owned workspace.'),
      const SizedBox(height:16),Wrap(spacing:10,runSpacing:10,children:[FilledButton.icon(onPressed:onOpenWorkspace,icon:const Icon(Icons.fact_check_outlined),label:const Text('Enter Decision Desk')),OutlinedButton.icon(onPressed:onOpenCivilization,icon:const Icon(Icons.location_city_outlined),label:const Text('Explore Civilization'))])
    ]));
  }
  Widget _hero(CriterivoxTheme t)=>Container(padding:const EdgeInsets.all(24),decoration:BoxDecoration(borderRadius:BorderRadius.circular(26),gradient:LinearGradient(colors:[t.surfaceStrong,t.surface]),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('INTRODUCTION',style:TextStyle(color:t.primary,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:2)),const SizedBox(height:8),Text('Criterivox',style:TextStyle(color:t.text,fontSize:40,fontWeight:FontWeight.w900)),const SizedBox(height:8),Text('Understand the system. Work with it. Keep the decision human.',style:TextStyle(color:t.mutedText,fontSize:15,height:1.4))]));
  Widget _section(CriterivoxTheme t,String title,String body)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:t.primary,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.2)),const SizedBox(height:8),Text(body,style:TextStyle(color:t.text,fontSize:12,height:1.55))]));
  Widget _characters(CriterivoxTheme t)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('WHO ARE THESE CHARACTERS?',style:TextStyle(color:t.primary,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.2)),const SizedBox(height:8),Text('Characters are human-facing representations of actual system responsibilities and activity. They are not the computational engine itself.',style:TextStyle(color:t.mutedText,fontSize:11,height:1.45)),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:[for(final p in CharacterIdentities.all.values)ActionChip(label:Text(p.displayName+' · '+p.role),onPressed:onOpenCharacter == null ? onOpenCivilization : () => onOpenCharacter!(p.id))])]));
}