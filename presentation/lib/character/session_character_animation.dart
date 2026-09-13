import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'character_runtime_flutter.dart';
import 'character_visual_profile.dart';
import 'character_detail_layer.dart';
import 'character_animation_state.dart';
import 'generated_vector_animation.dart';

/// Session animation director. Identity comes from CharacterVisualProfile;
/// motion is regenerated per app session; runtime state drives semantic motion.
class SessionCharacterAnimation {
  static final int sessionSeed = DateTime.now().microsecondsSinceEpoch ^ math.Random().nextInt(0x7fffffff);
  static final activeCharacters = CharacterVisualProfile.registry.keys.toSet();
  static bool supports(String id) => CharacterVisualProfile.forId(id) != null && activeCharacters.contains(id.trim().toLowerCase());
  static SessionCharacterMotion profileFor(String id) {
    var hash = sessionSeed;
    for (final unit in id.trim().toLowerCase().codeUnits) hash = ((hash * 31) ^ unit) & 0x7fffffff;
    final r = math.Random(hash);
    return SessionCharacterMotion(duration:2.55+r.nextDouble()*1.15, phase:r.nextDouble()*math.pi*2, sway:.45+r.nextDouble()*.85, lift:.7+r.nextDouble()*1.4, emphasis:.75+r.nextDouble()*.5, direction:r.nextBool()?1:-1);
  }
}
class SessionCharacterMotion { final double duration, phase, sway, lift, emphasis; final int direction; const SessionCharacterMotion({required this.duration,required this.phase,required this.sway,required this.lift,required this.emphasis,required this.direction}); }
class SessionCharacterAnimationView extends StatefulWidget {
  final String characterId, state; final bool reducedMotion; final double width, height;
  const SessionCharacterAnimationView({super.key,required this.characterId,required this.state,this.reducedMotion=false,this.width=238,this.height=286});
  @override State<SessionCharacterAnimationView> createState()=>_SessionCharacterAnimationViewState();
}
class _SessionCharacterAnimationViewState extends State<SessionCharacterAnimationView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller; late SessionCharacterMotion _motion;
  @override void initState(){super.initState();_motion=SessionCharacterAnimation.profileFor(widget.characterId);_controller=AnimationController(vsync:this,duration:Duration(milliseconds:(_motion.duration*1000).round()));if(!widget.reducedMotion)_controller.repeat();}
  @override void didUpdateWidget(covariant SessionCharacterAnimationView oldWidget){super.didUpdateWidget(oldWidget);if(oldWidget.characterId!=widget.characterId){_motion=SessionCharacterAnimation.profileFor(widget.characterId);_controller.duration=Duration(milliseconds:(_motion.duration*1000).round());}_updateTicker(oldWidget.reducedMotion);}
  void _updateTicker(bool oldReduced){if(widget.reducedMotion)_controller.stop();else if(oldReduced)_controller.repeat();}
  @override void dispose(){_controller.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final profile=CharacterVisualProfile.forId(widget.characterId);
    if(!SessionCharacterAnimation.supports(widget.characterId)||profile==null){return CharacterRuntimeView(characterId:widget.characterId,state:widget.state,reducedMotion:widget.reducedMotion,width:widget.width,height:widget.height);}
    final visualState=CharacterAnimationStateMapper.bloomSignal(CharacterAnimationStateMapper.fromRuntime(characterState:widget.state));
    return AnimatedBuilder(animation:_controller,builder:(context,_){
      final phase=_motion.phase+_controller.value*math.pi*2; final wave=math.sin(phase); final breathe=math.sin(phase*1.17+.4); final active=visualState!='IDLE';
      final lift=wave*_motion.lift*(active?1:.65); final sway=math.sin(phase*.73)*_motion.sway*_motion.direction; final scale=1+breathe*.004*_motion.emphasis; final angle=math.sin(phase*.61)*.004*_motion.direction;
      return SizedBox(width:widget.width,height:widget.height,child:Transform.translate(offset:Offset(sway,lift),child:Transform.rotate(angle:angle,child:Transform.scale(scale:scale,child:Stack(alignment:Alignment.center,children:[
        CharacterRuntimeView(characterId:widget.characterId,state:visualState,reducedMotion:widget.reducedMotion,width:widget.width,height:widget.height),
        Transform.translate(offset:Offset(-sway,-lift),child:Transform.rotate(angle:-angle,child:Transform.scale(scale:1/scale,child:CharacterDetailLayer(profile:profile,state:visualState,progress:widget.reducedMotion ? .35 : _controller.value)))),
      ])))));
    });
  }
  String generatedSvgFrame({required int frame, int frameCount=8}){
    final profile=CharacterVisualProfile.forId(widget.characterId); if(profile==null)return '';
    final visualState=CharacterAnimationStateMapper.bloomSignal(CharacterAnimationStateMapper.fromRuntime(characterState:widget.state));
    return GeneratedVectorAnimation(profile:profile,sessionSeed:SessionCharacterAnimation.sessionSeed).svgFrame(state:visualState,frame:frame,frameCount:frameCount);
  }
}
