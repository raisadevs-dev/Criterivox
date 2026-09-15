import 'dart:math' as math;
import 'package:flutter/material.dart';

enum S7CharacterState { idle, receive, work, communicate, handoff, complete }

class S7CharacterCinematics extends StatefulWidget {
  final String character;
  final S7CharacterState state;
  const S7CharacterCinematics({super.key, required this.character, required this.state});
  @override State<S7CharacterCinematics> createState()=>_S7CharacterCinematicsState();
}
class _S7CharacterCinematicsState extends State<S7CharacterCinematics> with SingleTickerProviderStateMixin {
  late final AnimationController _controller=AnimationController(vsync:this,duration:const Duration(seconds:4))..repeat();
  @override void dispose(){_controller.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:_controller,builder:(context,_)=>CustomPaint(painter:_CharacterPainter(widget.character,widget.state,_controller.value),size:const Size(220,260)));
}
class _CharacterPainter extends CustomPainter {
  final String character; final S7CharacterState state; final double t;
  _CharacterPainter(this.character,this.state,this.t);
  @override void paint(Canvas c,Size s){
    final vivren=character.toLowerCase()=='vivren'; final accent=vivren?const Color(0xffb9a4ff):const Color(0xffffbd72); final pulse=1+0.025*math.sin(t*math.pi*2);
    final center=Offset(s.width/2,s.height*.46); final aura=Paint()..color=accent.withValues(alpha:.10)..maskFilter=const MaskFilter.blur(BlurStyle.normal,24); c.drawCircle(center,72*pulse,aura);
    final body=Paint()..color=accent.withValues(alpha:.18)..style=PaintingStyle.fill; c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:center.translate(0,38),width:74,height:110),const Radius.circular(28)),body);
    final line=Paint()..color=accent..style=PaintingStyle.stroke..strokeWidth=3; c.drawCircle(center.translate(0,-18),29,line);
    c.drawArc(Rect.fromCenter(center:center.translate(0,20),width:92,height:125),math.pi*.15,math.pi*.7,false,line);
    final motion=state==S7CharacterState.work||state==S7CharacterState.receive?math.sin(t*math.pi*4)*8:0; c.drawLine(center.translate(-46,motion),center.translate(-70,22+motion),line); c.drawLine(center.translate(46,motion),center.translate(70,22-motion),line);
    final eye=Paint()..color=accent; c.drawCircle(center.translate(-10,-18),3,eye); c.drawCircle(center.translate(10,-18),3,eye);
    final label=TextPainter(text:TextSpan(text:vivren?'VIVREN':'TARKIS',style:TextStyle(color:accent,fontSize:12,fontWeight:FontWeight.w700,letterSpacing:2)),textDirection:TextDirection.ltr)..layout(); label.paint(c,Offset((s.width-label.width)/2,s.height-24));
  }
  @override bool shouldRepaint(covariant _CharacterPainter old)=>old.t!=t||old.state!=state||old.character!=character;
}
