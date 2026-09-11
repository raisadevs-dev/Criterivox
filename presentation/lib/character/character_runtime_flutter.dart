import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Functional placeholder character renderer. It intentionally stays pure
/// Flutter while providing distinct hair, clothing, accessories, hands,
/// facial motion and state-driven gestures for the current character set.
class CharacterRuntimeView extends StatefulWidget {
  final String characterId;
  final String state;
  final bool reducedMotion;
  final double width;
  final double height;
  const CharacterRuntimeView({super.key, required this.characterId, required this.state, this.reducedMotion = false, this.width = 180, this.height = 240});
  @override State<CharacterRuntimeView> createState() => _CharacterRuntimeViewState();
}

class _CharacterRuntimeViewState extends State<CharacterRuntimeView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3)); if (!widget.reducedMotion) _controller.repeat(); }
  @override void didUpdateWidget(covariant CharacterRuntimeView oldWidget) { super.didUpdateWidget(oldWidget); if (widget.reducedMotion) { _controller.stop(); } else if (oldWidget.reducedMotion) { _controller.repeat(); } }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final identity = CharacterIdentities.resolve(widget.characterId);
    return SizedBox(width: widget.width, height: widget.height, child: Semantics(container: true, label: '${identity.displayName} character', value: widget.state.toUpperCase(), child: AnimatedBuilder(animation: _controller, builder: (_, __) => CustomPaint(painter: _CharacterPainter(characterId: widget.characterId, state: widget.state.toUpperCase(), progress: widget.reducedMotion ? .35 : _controller.value)))));
  }
}

class _CharacterPainter extends CustomPainter {
  final String characterId, state; final double progress;
  const _CharacterPainter({required this.characterId, required this.state, required this.progress});
  @override void paint(Canvas canvas, Size size) {
    final c = _CharacterStyle.forId(characterId); final t = progress * math.pi * 2;
    final breathe = (state == 'IDLE' || state == 'WORK' || state == 'COMMUNICATE') ? math.sin(t) * 2.2 : 0;
    final weight = (state == 'WORK' || state == 'IDLE') ? math.sin(t * .5) * 3 : 0;
    final attention = (state == 'RECEIVE' || state == 'HANDOFF') ? math.sin(t) * 1.5 : 0;
    final gesture = state == 'COMMUNICATE' ? math.sin(t * 2.2) : 0;
    final pulse = math.sin(t * 2) * .5 + .5;
    canvas.save(); canvas.translate(size.width / 2 + weight, size.height * .53); canvas.scale(math.min(size.width / 238, size.height / 286));
    _ground(canvas, c, pulse); _legs(canvas, c, weight); _torso(canvas, c, breathe); _arms(canvas, c, state, gesture, attention); _head(canvas, c, breathe, attention, gesture); _hair(canvas, c, t, breathe, attention); _clothingDetails(canvas, c, state, breathe); _accessory(canvas, c, state, t, pulse); _face(canvas, c, state, gesture, attention); canvas.restore();
  }
  void _ground(Canvas x, _CharacterStyle c, double p) { x.drawOval(const Rect.fromCenter(center: Offset(0,116), width:126, height:20), Paint()..color=c.accent.withValues(alpha:.07+p*.04)); }
  void _legs(Canvas x, _CharacterStyle c, double w) {
    final p=Paint()..color=c.trousers; final l=Path()..moveTo(-25,48)..lineTo(-8,48)..lineTo(-12+w*.25,102)..lineTo(-31,102)..close(); final r=Path()..moveTo(8,48)..lineTo(25,48)..lineTo(31-w*.25,102)..lineTo(12,102)..close(); x.drawPath(l,p); x.drawPath(r,p);
    final shoe=Paint()..color=c.dark; x.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-36-w*.25,97,28,13),const Radius.circular(6)),shoe); x.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(8+w*.25,97,28,13),const Radius.circular(6)),shoe);
  }
  void _torso(Canvas x,_CharacterStyle c,double b) {
    final p=Paint()..color=c.body; final body=Path()..moveTo(-42,-36+b*.2)..quadraticBezierTo(0,-48-b*.15,42,-36+b*.2)..lineTo(31,50)..quadraticBezierTo(0,61,-31,50)..close(); x.drawPath(body,p);
    final trim=Paint()..color=c.accent..strokeWidth=4..style=PaintingStyle.stroke; x.drawLine(const Offset(0,-36),const Offset(0,42),trim);
  }
  void _arms(Canvas x,_CharacterStyle c,String s,double g,double a) {
    final left=s=='COMMUNICATE' ? -.28+g*.16 : (s=='HANDOFF' ? -.32 : -.08); final right=s=='WORK' ? .35+g*.12 : (s=='COMMUNICATE' ? .25+g*.12 : .08+a*.02); _arm(x,c,-1,left,s,g); _arm(x,c,1,right,s,g);
  }
  void _arm(Canvas x,_CharacterStyle c,int side,double angle,String s,double g) {
    x.save(); x.translate(side*39,-25); x.rotate(side*angle); final sleeve=Paint()..color=c.body; final skin=Paint()..color=c.skin;
    x.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-8,-4,16,43),const Radius.circular(8)),sleeve);
    x.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-7,36,14,27),const Radius.circular(7)),skin);
    final handY=63.0+(s=='COMMUNICATE'?g*3:0); x.drawOval(Rect.fromCenter(center:Offset(0,handY),width:13,height:10),skin);
    if(s=='COMMUNICATE'){ final finger=Paint()..color=c.skin..strokeWidth=3..strokeCap=StrokeCap.round; x.drawLine(const Offset(0,64),Offset(side*3,74+g*2),finger); }
    x.restore();
  }
  void _head(Canvas x,_CharacterStyle c,double b,double a,double g) {
    final skin=Paint()..color=c.skin; x.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-12,-61+b*.1,24,22),const Radius.circular(8)),skin);
    x.save(); x.translate(a*.5,-79+b*.2); x.rotate(a*.006+g*.006); x.drawOval(const Rect.fromCenter(center:Offset(0,0),width:78,height:86),skin); x.drawOval(const Rect.fromCenter(center:Offset(0,3),width:68,height:77),Paint()..color=c.face); x.restore();
  }
  void _hair(Canvas x,_CharacterStyle c,double t,double b,double a) {
    final p=Paint()..color=c.hair; final sway=math.sin(t)*1.8+a*.4;
    switch(c.hairStyle){
      case 'bun': x.drawCircle(Offset(-27+sway,-112),14,p); x.drawCircle(Offset(27+sway,-112),14,p); x.drawOval(const Rect.fromCenter(center:Offset(0,-105),width:75,height:48),p); break;
      case 'visor': x.drawOval(const Rect.fromCenter(center:Offset(0,-106),width:82,height:35),p); x.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-31,-103,62,13),const Radius.circular(7)),Paint()..color=c.accent.withValues(alpha:.65)); break;
      case 'long': x.drawOval(const Rect.fromCenter(center:Offset(0,-104),width:83,height:43),p); x.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-39+sway,-104,16,72),const Radius.circular(8)),p); x.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(23+sway,-104,16,72),const Radius.circular(8)),p); break;
      case 'messy': final path=Path()..moveTo(-42,-92); for(var i=0;i<9;i++){final xx=-42+i*10.5; path.lineTo(xx,-112-math.sin(i+t*.18)*7-a.abs());} path.lineTo(42,-86)..lineTo(-42,-86)..close(); x.drawPath(path,p); break;
      default: x.drawOval(const Rect.fromCenter(center:Offset(0,-104),width:82,height:42),p);
    }
  }
  void _clothingDetails(Canvas x,_CharacterStyle c,String s,double b) {
    final line=Paint()..color=c.accent.withValues(alpha:.8)..strokeWidth=2.5..style=PaintingStyle.stroke;
    if(c.clothing=='jacket'){ x.drawLine(const Offset(-31,-30),const Offset(-24,42),line); x.drawLine(const Offset(31,-30),const Offset(24,42),line); }
    if(c.clothing=='collar'){ final p=Paint()..color=c.accent; final l=Path()..moveTo(-18,-38)..lineTo(-3,-25)..lineTo(-13,-18)..close(); final r=Path()..moveTo(18,-38)..lineTo(3,-25)..lineTo(13,-18)..close(); x.drawPath(l,p); x.drawPath(r,p); }
    if(c.clothing=='scarf'){ x.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-8,-40,16,72),const Radius.circular(6)),Paint()..color=c.accent); }
    if(c.clothing=='hoodie'){ x.drawArc(const Rect.fromLTWH(-32,-51,64,42),math.pi,math.pi,false,line); }
  }
  void _accessory(Canvas x,_CharacterStyle c,String s,double t,double p) {
    final bob=math.sin(t*1.5)*2; switch(c.accessory){
      case 'notebook': final q=Paint()..color=c.accent; x.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(42, -7+bob,22,29),const Radius.circular(3)),q); x.drawLine(47,-2+bob,59,-2+bob,Paint()..color=c.dark..strokeWidth=1.5); break;
      case 'headphones': final q=Paint()..color=c.accent..style=PaintingStyle.stroke..strokeWidth=4; x.drawArc(const Rect.fromLTWH(-49,-125,98,64),math.pi,math.pi,false,q); x.drawCircle(const Offset(-47,-91),7,q); x.drawCircle(const Offset(47,-91),7,q); break;
      case 'orb': final q=Paint()..color=c.accent.withValues(alpha:.42+p*.3); x.drawCircle(Offset(58, -54+bob),10+p*2,q); break;
      case 'star': final q=Paint()..color=c.accent; final path=Path(); for(var i=0;i<10;i++){final r=i.isEven?11.0:4.5; final a=-math.pi/2+i*math.pi/5; final pt=Offset(53+math.cos(a)*r,-48+math.sin(a)*r+bob); i==0?path.moveTo(pt.dx,pt.dy):path.lineTo(pt.dx,pt.dy);} path.close(); x.drawPath(path,q); break;
      case 'badge': x.drawCircle(Offset(27,2+bob),8,Paint()..color=c.accent); break;
      case 'glasses': final q=Paint()..color=c.accent..style=PaintingStyle.stroke..strokeWidth=2; x.drawOval(const Rect.fromLTWH(-27,-88,22,14),q); x.drawOval(const Rect.fromLTWH(5,-88,22,14),q); x.drawLine(const Offset(-5,-81),const Offset(5,-81),q); break;
    }
  }
  void _face(Canvas x,_CharacterStyle c,String s,double g,double a) {
    final eye=Paint()..color=c.dark; final y=-78+a*.2; final blink=(math.sin(progress*math.pi*2*2).abs()>.985); if(!blink){x.drawOval(Rect.fromCenter(center:Offset(-15,y),width:5,height:s=='WARNING'?7:5),eye);x.drawOval(Rect.fromCenter(center:Offset(15,y),width:5,height:s=='WARNING'?7:5),eye);}
    if(s=='WARNING'){final q=Paint()..color=c.dark..strokeWidth=3..strokeCap=StrokeCap.round;x.drawLine(const Offset(-22,-89),const Offset(-9,-92),q);x.drawLine(const Offset(9,-92),const Offset(22,-89),q);}
    if(s=='COMPLETE'){final q=Paint()..color=c.dark..style=PaintingStyle.stroke..strokeWidth=3;x.drawArc(const Rect.fromLTWH(-12,-77,24,18),.2,math.pi-.4,false,q);}
    if(s=='RECEIVE'||s=='HANDOFF'){x.drawCircle(const Offset(0,-78),34+a.abs(),Paint()..color=c.accent.withValues(alpha:.28)..style=PaintingStyle.stroke..strokeWidth=2);}
    if(s=='COMMUNICATE'){x.drawOval(Rect.fromCenter(center:Offset(0,-70),width:9+g.abs()*4,height:3+g.abs()),Paint()..color=c.dark.withValues(alpha:.7));}
  }
  @override bool shouldRepaint(covariant _CharacterPainter old) => old.characterId!=characterId||old.state!=state||old.progress!=progress;
}

class _CharacterStyle {
  final Color skin,face,body,trousers,hair,accent,dark; final String hairStyle,accessory,clothing;
  const _CharacterStyle({required this.skin,required this.face,required this.body,required this.trousers,required this.hair,required this.accent,required this.dark,required this.hairStyle,required this.accessory,required this.clothing});
  static _CharacterStyle forId(String id){switch(id.trim().toLowerCase()){
    case 'dharen': return const _CharacterStyle(skin:Color(0xffc98964),face:Color(0xffffd7bc),body:Color(0xff8b5e3c),trousers:Color(0xff403d46),hair:Color(0xff34251f),accent:Color(0xffd98b43),dark:Color(0xff201b1a),hairStyle:'messy',accessory:'notebook',clothing:'jacket');
    case 'syvax': return const _CharacterStyle(skin:Color(0xffb87c63),face:Color(0xffffd4bd),body:Color(0xff344d63),trousers:Color(0xff252d36),hair:Color(0xff17232e),accent:Color(0xff62d8f5),dark:Color(0xff14202a),hairStyle:'visor',accessory:'headphones',clothing:'hoodie');
    case 'sandre': return const _CharacterStyle(skin:Color(0xffa96f58),face:Color(0xffffcbb5),body:Color(0xff496d6d),trousers:Color(0xff343f43),hair:Color(0xff2d2522),accent:Color(0xff63b9a8),dark:Color(0xff1d2527),hairStyle:'long',accessory:'badge',clothing:'collar');
    case 'kaelen': return const _CharacterStyle(skin:Color(0xffbd805e),face:Color(0xffffd1b8),body:Color(0xff50575f),trousers:Color(0xff20252a),hair:Color(0xff1d1b1b),accent:Color(0xfff19a3e),dark:Color(0xff17191c),hairStyle:'messy',accessory:'headphones',clothing:'jacket');
    case 'anuka': return const _CharacterStyle(skin:Color(0xffd69a79),face:Color(0xffffdfcf),body:Color(0xfff0b9c8),trousers:Color(0xff343044),hair:Color(0xff2a2025),accent:Color(0xffbd7fe4),dark:Color(0xff221b27),hairStyle:'bun',accessory:'orb',clothing:'hoodie');
    case 'vivren': return const _CharacterStyle(skin:Color(0xffc7957e),face:Color(0xffffd8c7),body:Color(0xffd5d0dc),trousers:Color(0xff36333e),hair:Color(0xffc8bdd9),accent:Color(0xffa68ad7),dark:Color(0xff26222d),hairStyle:'long',accessory:'glasses',clothing:'scarf');
    case 'tarkis': return const _CharacterStyle(skin:Color(0xffa96f56),face:Color(0xffffcdb6),body:Color(0xff34383f),trousers:Color(0xff171a1e),hair:Color(0xff171719),accent:Color(0xffee8b31),dark:Color(0xff111214),hairStyle:'messy',accessory:'star',clothing:'hoodie');
    default: return const _CharacterStyle(skin:Color(0xffb98068),face:Color(0xffffd5c0),body:Color(0xff59636d),trousers:Color(0xff30343a),hair:Color(0xff24272b),accent:Color(0xff7aa9d8),dark:Color(0xff17191c),hairStyle:'messy',accessory:'notebook',clothing:'jacket');
  }}
}

class CharacterIdentity { final String id,displayName,role; const CharacterIdentity({required this.id,required this.displayName,required this.role}); }
class CharacterIdentities { CharacterIdentities._(); static const Map<String,CharacterIdentity> all={
  'dharen':CharacterIdentity(id:'dharen',displayName:'Dharen',role:'Context Architecture'),'vivren':CharacterIdentity(id:'vivren',displayName:'Vivren',role:'Discernment'),'tarkis':CharacterIdentity(id:'tarkis',displayName:'Tarkis',role:'Hypothesis + Evidence'),'sandre':CharacterIdentity(id:'sandre',displayName:'Sandre',role:'Data Stewardship'),'pramon':CharacterIdentity(id:'pramon',displayName:'Pramon',role:'Proof'),'syvax':CharacterIdentity(id:'syvax',displayName:'Syvax',role:'Dialogue + Orchestration'),'bodhex':CharacterIdentity(id:'bodhex',displayName:'Bodhex',role:'Insight'),'medrus':CharacterIdentity(id:'medrus',displayName:'Medrus',role:'Knowledge'),'epistre':CharacterIdentity(id:'epistre',displayName:'Epistre',role:'Transfer'),'manis':CharacterIdentity(id:'manis',displayName:'Manis',role:'Deliberation'),'anuka':CharacterIdentity(id:'anuka',displayName:'Anuka',role:'Adaptive Context'),'veridat':CharacterIdentity(id:'veridat',displayName:'Veridat',role:'Verification'),'viveda':CharacterIdentity(id:'viveda',displayName:'Viveda',role:'Knowledge Delivery'),'kaelen':CharacterIdentity(id:'kaelen',displayName:'Kaelen',role:'Build + Experimentation'),'anukor':CharacterIdentity(id:'anukor',displayName:'Anukor',role:'Context Transfer')};
  static CharacterIdentity resolve(String id)=>all[id.trim().toLowerCase()]??CharacterIdentity(id:id,displayName:id,role:'Criterivox Agent');
}
