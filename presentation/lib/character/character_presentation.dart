import 'package:flutter/material.dart';

import '../presentation/presentation_state.dart';
import 'character_identity.dart';
import 'character_visual_state.dart';

class CharacterPresentation extends StatelessWidget {
  final PresentationState state;
  const CharacterPresentation({super.key, required this.state});
  @override Widget build(BuildContext context) {
    final identity = CharacterIdentities.resolve(state.agentId);
    final visualState = CharacterVisualState.fromPresentationState(state);
    return Semantics(container:true,label:'${identity.displayName}, ${identity.role}',value:visualState.characterState,child:_CharacterCard(identity:identity,visualState:visualState));
  }
}
class _CharacterCard extends StatelessWidget {
  final CharacterIdentity identity; final CharacterVisualState visualState;
  const _CharacterCard({required this.identity,required this.visualState});
  @override Widget build(BuildContext context)=>AnimatedOpacity(duration:visualState.reducedMotion?Duration.zero:const Duration(milliseconds:220),opacity:visualState.active?1:.55,child:Column(mainAxisSize:MainAxisSize.min,children:[_CharacterFigure(visualState:visualState),const SizedBox(height:12),Text(identity.displayName,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:3),Text(identity.role,style:Theme.of(context).textTheme.bodyMedium),const SizedBox(height:9),_StateBadge(state:visualState.characterState)]));
}
class _CharacterFigure extends StatelessWidget {
  final CharacterVisualState visualState; const _CharacterFigure({required this.visualState});
  @override Widget build(BuildContext context){final c=_VisualConfiguration.fromState(visualState.characterState);return AnimatedScale(scale:visualState.active?c.scale*(.96+visualState.prominence*.04):.94,duration:visualState.reducedMotion?Duration.zero:const Duration(milliseconds:220),child:SizedBox(width:230,height:270,child:Stack(alignment:Alignment.center,children:[
    Positioned(bottom:4,child:Container(width:170,height:30,decoration:BoxDecoration(color:const Color(0xFF171A3B),borderRadius:BorderRadius.circular(24),boxShadow:const[BoxShadow(color:Color(0x443D47A8),blurRadius:18)]))),
    Positioned(bottom:25,child:AnimatedContainer(duration:visualState.reducedMotion?Duration.zero:const Duration(milliseconds:220),width:c.bodyWidth,height:c.bodyHeight,decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF8471FF),Color(0xFF4439A7)]),borderRadius:BorderRadius.all(Radius.circular(52)),boxShadow:[BoxShadow(color:Color(0x664D43D9),blurRadius:28,spreadRadius:3)]))),
    Positioned(top:22,child:AnimatedContainer(duration:visualState.reducedMotion?Duration.zero:const Duration(milliseconds:220),width:c.headSize,height:c.headSize,decoration:BoxDecoration(gradient:const RadialGradient(center:Alignment(-.25,-.35),radius:.9,colors:[Color(0xFFFBF9FF),Color(0xFFD9D8EE),Color(0xFFA7A8C9)]),shape:BoxShape.circle,border:Border.all(color:const Color(0xFF9A83FF),width:c.borderWidth),boxShadow:const[BoxShadow(color:Color(0x664F46D9),blurRadius:30,spreadRadius:5)]),child:_CharacterFace(state:visualState.characterState,reducedMotion:visualState.reducedMotion))),
    if(c.showActivityIndicator)Positioned(top:4,right:28,child:_ActivityIndicator(state:visualState.characterState,reducedMotion:visualState.reducedMotion)),
  ])));}
}
class _CharacterFace extends StatelessWidget {
  final String state; final bool reducedMotion; const _CharacterFace({required this.state,required this.reducedMotion});
  @override Widget build(BuildContext context){final emphasized={'RECEIVE','COMMUNICATE','HANDOFF','WARNING'}.contains(state);final complete=state=='COMPLETE';final communicating=state=='COMMUNICATE';return Column(mainAxisAlignment:MainAxisAlignment.center,children:[Row(mainAxisAlignment:MainAxisAlignment.center,children:[_Eye(emphasized:emphasized),const SizedBox(width:30),_Eye(emphasized:emphasized)]),const SizedBox(height:16),AnimatedContainer(duration:reducedMotion?Duration.zero:const Duration(milliseconds:180),width:communicating?40:30,height:complete?8:14,decoration:BoxDecoration(color:complete?const Color(0xFF4A407D):Colors.transparent,borderRadius:BorderRadius.circular(20),border:complete?null:Border.all(color:const Color(0xFF5A5278),width:2)))]);}
}
class _Eye extends StatelessWidget { final bool emphasized; const _Eye({required this.emphasized}); @override Widget build(BuildContext context)=>AnimatedContainer(duration:const Duration(milliseconds:180),width:emphasized?14:13,height:emphasized?21:19,decoration:const BoxDecoration(shape:BoxShape.oval,color:Color(0xFF24213D),boxShadow:[BoxShadow(color:Color(0x663B2F75),blurRadius:6)])); }
class _ActivityIndicator extends StatelessWidget { final String state; final bool reducedMotion; const _ActivityIndicator({required this.state,required this.reducedMotion}); @override Widget build(BuildContext context){final symbol=switch(state){'WORK'=>'•','COMMUNICATE'=>'…','HANDOFF'=>'→','WARNING'=>'!',_=>'•'};return AnimatedOpacity(opacity:1,duration:reducedMotion?Duration.zero:const Duration(milliseconds:180),child:Container(width:34,height:34,alignment:Alignment.center,decoration:const BoxDecoration(color:Color(0xFF171A3B),shape:BoxShape.circle,boxShadow:[BoxShadow(color:Color(0x553F45A0),blurRadius:15)]),child:Text(symbol,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800,fontSize:17))));}}
class _VisualConfiguration { final double scale,bodyWidth,bodyHeight,headSize,borderWidth; final bool showActivityIndicator; const _VisualConfiguration({required this.scale,required this.bodyWidth,required this.bodyHeight,required this.headSize,required this.borderWidth,required this.showActivityIndicator}); factory _VisualConfiguration.fromState(String state)=>switch(state){'RECEIVE'=>const _VisualConfiguration(scale:1.04,bodyWidth:124,bodyHeight:134,headSize:138,borderWidth:6,showActivityIndicator:false),'WORK'=>const _VisualConfiguration(scale:1.02,bodyWidth:122,bodyHeight:136,headSize:134,borderWidth:5,showActivityIndicator:true),'COMMUNICATE'=>const _VisualConfiguration(scale:1.03,bodyWidth:124,bodyHeight:132,headSize:136,borderWidth:6,showActivityIndicator:true),'HANDOFF'=>const _VisualConfiguration(scale:1.05,bodyWidth:126,bodyHeight:136,headSize:136,borderWidth:6,showActivityIndicator:true),'COMPLETE'=>const _VisualConfiguration(scale:1.01,bodyWidth:120,bodyHeight:130,headSize:134,borderWidth:5,showActivityIndicator:false),'WARNING'=>const _VisualConfiguration(scale:1.06,bodyWidth:126,bodyHeight:138,headSize:140,borderWidth:7,showActivityIndicator:true),_=>const _VisualConfiguration(scale:1,bodyWidth:118,bodyHeight:128,headSize:132,borderWidth:5,showActivityIndicator:false)}; }
class _StateBadge extends StatelessWidget { final String state; const _StateBadge({required this.state}); @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:7),decoration:BoxDecoration(color:const Color(0xFF171A3B),borderRadius:BorderRadius.circular(20),border:Border.all(color:const Color(0x334C5594))),child:Text(state.toUpperCase(),style:const TextStyle(color:Color(0xFFC8CCDF),fontSize:11,fontWeight:FontWeight.w700,letterSpacing:1))); }
