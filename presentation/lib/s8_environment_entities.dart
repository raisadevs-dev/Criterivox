import 'dart:math' as math;
import 'package:flutter/material.dart';
import 's8_presentation_state.dart';

/// Vector-painted environmental vocabulary used by the S8 interior.
/// Decorative only: these objects never represent epistemic truth.
enum S8EnvironmentEntityKind {
  cloud, cactus, tree, palm, plant, vine, grass, flower,
  flask, cup, bottle, glass, mountain, skyline, bridge, nightSky,
  computer, keyboard, monitor, printer, controller, mouse, antenna,
  plug, battery, scale, crystal, teddy, chart, receipt, document,
  parchment, note, calendar, folder, cabinet, newspaper, ballot,
  book, clip, link, calculator, pin, search, bookmark,
}

class S8EnvironmentEntity extends StatelessWidget {
  final S8EnvironmentEntityKind kind;
  final double size;
  final Color? accent;
  const S8EnvironmentEntity({super.key, required this.kind, this.size = 42, this.accent});
  @override
  Widget build(BuildContext context) => Tooltip(
        message: _label(kind),
        child: CustomPaint(size: Size.square(size), painter: _EntityPainter(kind, accent ?? Theme.of(context).colorScheme.primary)),
      );
}

class S8EnvironmentEntityCluster extends StatelessWidget {
  final S8Room room;
  const S8EnvironmentEntityCluster({super.key, required this.room});
  @override
  Widget build(BuildContext context) {
    final a = _roomAccent(room);
    final items = switch (room) {
      S8Room.medrus => [
        (S8EnvironmentEntityKind.flask,36.0),(S8EnvironmentEntityKind.calculator,34.0),(S8EnvironmentEntityKind.computer,48.0),(S8EnvironmentEntityKind.keyboard,42.0),(S8EnvironmentEntityKind.receipt,30.0),(S8EnvironmentEntityKind.document,30.0),(S8EnvironmentEntityKind.clip,28.0),(S8EnvironmentEntityKind.battery,30.0),(S8EnvironmentEntityKind.plug,28.0),(S8EnvironmentEntityKind.cactus,55.0),(S8EnvironmentEntityKind.cup,31.0),
      ],
      S8Room.epistre => [
        (S8EnvironmentEntityKind.book,40.0),(S8EnvironmentEntityKind.parchment,34.0),(S8EnvironmentEntityKind.folder,34.0),(S8EnvironmentEntityKind.cabinet,38.0),(S8EnvironmentEntityKind.newspaper,34.0),(S8EnvironmentEntityKind.bookmark,28.0),(S8EnvironmentEntityKind.link,28.0),(S8EnvironmentEntityKind.cup,31.0),(S8EnvironmentEntityKind.tree,60.0),(S8EnvironmentEntityKind.flower,45.0),(S8EnvironmentEntityKind.note,30.0),
      ],
      S8Room.veridat => [
        (S8EnvironmentEntityKind.monitor,46.0),(S8EnvironmentEntityKind.chart,36.0),(S8EnvironmentEntityKind.scale,38.0),(S8EnvironmentEntityKind.search,32.0),(S8EnvironmentEntityKind.antenna,36.0),(S8EnvironmentEntityKind.battery,30.0),(S8EnvironmentEntityKind.receipt,30.0),(S8EnvironmentEntityKind.pin,28.0),(S8EnvironmentEntityKind.grass,55.0),(S8EnvironmentEntityKind.plant,52.0),(S8EnvironmentEntityKind.plug,28.0),
      ],
      S8Room.presentation => [
        (S8EnvironmentEntityKind.monitor,46.0),(S8EnvironmentEntityKind.mouse,30.0),(S8EnvironmentEntityKind.controller,34.0),(S8EnvironmentEntityKind.chart,36.0),(S8EnvironmentEntityKind.calendar,32.0),(S8EnvironmentEntityKind.link,28.0),(S8EnvironmentEntityKind.note,30.0),(S8EnvironmentEntityKind.document,30.0),(S8EnvironmentEntityKind.teddy,43.0),(S8EnvironmentEntityKind.palm,62.0),(S8EnvironmentEntityKind.flower,45.0),(S8EnvironmentEntityKind.ballot,36.0),
      ],
      S8Room.home => [
        (S8EnvironmentEntityKind.computer,46.0),(S8EnvironmentEntityKind.crystal,48.0),(S8EnvironmentEntityKind.chart,35.0),(S8EnvironmentEntityKind.book,40.0),(S8EnvironmentEntityKind.teddy,42.0),(S8EnvironmentEntityKind.controller,34.0),(S8EnvironmentEntityKind.cup,31.0),(S8EnvironmentEntityKind.bottle,31.0),(S8EnvironmentEntityKind.palm,62.0),(S8EnvironmentEntityKind.tree,58.0),(S8EnvironmentEntityKind.newspaper,33.0),(S8EnvironmentEntityKind.folder,33.0),
      ],
    };
    return IgnorePointer(child: Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.fromLTRB(10,235,10,112), child: Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.end, spacing:12, runSpacing:8, children:[for(final item in items) S8EnvironmentEntity(kind:item.$1,size:item.$2,accent:a)]))));
  }
}

Color _roomAccent(S8Room room)=>switch(room){S8Room.medrus=>const Color(0xFF2CCCF5),S8Room.epistre=>const Color(0xFFB98BFF),S8Room.veridat=>const Color(0xFF38E0A8),S8Room.presentation=>const Color(0xFFFFC857),S8Room.home=>const Color(0xFF4CB8FF)};
String _label(S8EnvironmentEntityKind k)=>switch(k){S8EnvironmentEntityKind.cloud=>'Cloud',S8EnvironmentEntityKind.cactus=>'Cactus',S8EnvironmentEntityKind.tree=>'Tree',S8EnvironmentEntityKind.palm=>'Palm',S8EnvironmentEntityKind.plant=>'Plant',S8EnvironmentEntityKind.vine=>'Vine',S8EnvironmentEntityKind.grass=>'Grass',S8EnvironmentEntityKind.flower=>'Flower',S8EnvironmentEntityKind.flask=>'Experiment flask',S8EnvironmentEntityKind.cup=>'Research cup',S8EnvironmentEntityKind.bottle=>'Bottle',S8EnvironmentEntityKind.glass=>'Glass',S8EnvironmentEntityKind.mountain=>'Mountain',S8EnvironmentEntityKind.skyline=>'City skyline',S8EnvironmentEntityKind.bridge=>'Bridge',S8EnvironmentEntityKind.nightSky=>'Night sky',S8EnvironmentEntityKind.computer=>'Computer',S8EnvironmentEntityKind.keyboard=>'Keyboard',S8EnvironmentEntityKind.monitor=>'Monitor',S8EnvironmentEntityKind.printer=>'Printer',S8EnvironmentEntityKind.controller=>'Controller',S8EnvironmentEntityKind.mouse=>'Mouse',S8EnvironmentEntityKind.antenna=>'Signal antenna',S8EnvironmentEntityKind.plug=>'Power connector',S8EnvironmentEntityKind.battery=>'Battery',S8EnvironmentEntityKind.scale=>'Verification scale',S8EnvironmentEntityKind.crystal=>'Knowledge crystal',S8EnvironmentEntityKind.teddy=>'Comfort object',S8EnvironmentEntityKind.chart=>'Research chart',S8EnvironmentEntityKind.receipt=>'Execution receipt',S8EnvironmentEntityKind.document=>'Document',S8EnvironmentEntityKind.parchment=>'Archive parchment',S8EnvironmentEntityKind.note=>'Research note',S8EnvironmentEntityKind.calendar=>'Temporal calendar',S8EnvironmentEntityKind.folder=>'Folder',S8EnvironmentEntityKind.cabinet=>'Archive cabinet',S8EnvironmentEntityKind.newspaper=>'Research newspaper',S8EnvironmentEntityKind.ballot=>'Decision card',S8EnvironmentEntityKind.book=>'Research book',S8EnvironmentEntityKind.clip=>'Paper clip',S8EnvironmentEntityKind.link=>'Provenance link',S8EnvironmentEntityKind.calculator=>'Calculator',S8EnvironmentEntityKind.pin=>'Research pin',S8EnvironmentEntityKind.search=>'Search tool',S8EnvironmentEntityKind.bookmark=>'Bookmark'};

class _EntityPainter extends CustomPainter {
  final S8EnvironmentEntityKind kind; final Color a;
  _EntityPainter(this.kind,this.a);
  Paint f(Color c)=>Paint()..color=c; Paint p(Color c,[double w=1.7])=>Paint()..color=c..style=PaintingStyle.stroke..strokeWidth=w..strokeCap=StrokeCap.round;
  @override void paint(Canvas c,Size s){final x=s.width/2,y=s.height/2;final line=p(const Color(0xFFB8C9D3));final fill=f(const Color(0xFF203442));final hi=f(a.withValues(alpha:.72));
    switch(kind){
      case S8EnvironmentEntityKind.cloud:c.drawCircle(Offset(x-9,y+3),9,fill);c.drawCircle(Offset(x+2,y-3),12,fill);c.drawCircle(Offset(x+12,y+3),8,fill);c.drawRect(Rect.fromLTWH(x-18,y+3,36,10),fill);break;
      case S8EnvironmentEntityKind.cactus:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-7,y-18,14,35),const Radius.circular(8)),hi);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-18,y-3,11,8),const Radius.circular(5)),hi);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x+7,y-8,11,8),const Radius.circular(5)),hi);break;
      case S8EnvironmentEntityKind.tree:for(var i=0;i<5;i++) {
        c.drawCircle(Offset(x+(i-2)*8,y-6-(i%2)*6),11,fill);
      }c.drawRect(Rect.fromLTWH(x-3,y+3,6,22),f(const Color(0xFF6B4B35)));break;
      case S8EnvironmentEntityKind.palm:c.drawRect(Rect.fromLTWH(x-2,y-2,4,25),f(const Color(0xFF5A855E)));for(var i=0;i<8;i++){c.save();c.translate(x,y-4);c.rotate(-1.25+i*.35);c.drawOval(const Rect.fromLTWH(0,-3,22,6),hi);c.restore();}break;
      case S8EnvironmentEntityKind.plant:case S8EnvironmentEntityKind.vine:case S8EnvironmentEntityKind.grass:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-13,y+10,26,12),const Radius.circular(4)),f(const Color(0xFF705039)));for(var i=0;i<11;i++){c.save();c.translate(x,y+10);c.rotate(-.9+(i%6)*.36);c.drawOval(const Rect.fromLTWH(0,-2,18,5),hi);c.restore();}break;
      case S8EnvironmentEntityKind.flower:for(var i=0;i<6;i++) {
        c.drawCircle(Offset(x+math.cos(i*math.pi/3)*8,y-4+math.sin(i*math.pi/3)*8),6,hi);
      }c.drawCircle(Offset(x,y-4),3,f(const Color(0xFFD8B66A)));c.drawLine(Offset(x,y+3),Offset(x,y+19),p(const Color(0xFF4B8A63),2));break;
      case S8EnvironmentEntityKind.flask:c.drawPath(Path()..moveTo(x-5,y-17)..lineTo(x+5,y-17)..lineTo(x+5,y-7)..lineTo(x+13,y+10)..quadraticBezierTo(x,y+19,x-13,y+10)..lineTo(x-5,y-7)..close(),line);c.drawCircle(Offset(x,y+8),3,hi);break;
      case S8EnvironmentEntityKind.cup:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-10,y-7,19,19),const Radius.circular(4)),f(const Color(0xFFB8A486)));c.drawArc(Rect.fromLTWH(x+7,y-4,10,12),-math.pi/2,math.pi,false,line);c.drawOval(Rect.fromLTWH(x-9,y-10,17,5),f(const Color(0xFF473528)));break;
      case S8EnvironmentEntityKind.bottle:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-8,y-12,16,27),const Radius.circular(5)),fill);c.drawRect(Rect.fromLTWH(x-4,y-19,8,8),f(const Color(0xFF78909C)));c.drawLine(Offset(x-4,y-3),Offset(x+4,y-3),p(a));break;
      case S8EnvironmentEntityKind.glass:c.drawPath(Path()..moveTo(x-10,y-14)..lineTo(x+10,y-14)..lineTo(x+5,y+8)..quadraticBezierTo(x,y+13,x-5,y+8)..close(),line);c.drawLine(Offset(x,y+8),Offset(x,y+20),line);c.drawLine(Offset(x-7,y+20),Offset(x+7,y+20),line);break;
      case S8EnvironmentEntityKind.mountain:c.drawPath(Path()..moveTo(1,s.height-5)..lineTo(x-18,y+5)..lineTo(x-5,y+13)..lineTo(x+6,y-8)..lineTo(x+20,y+12)..lineTo(s.width-1,s.height-5)..close(),f(const Color(0xFF27485D)));break;
      case S8EnvironmentEntityKind.skyline:for(var i=0;i<6;i++){final h=12+(i%3)*7;c.drawRect(Rect.fromLTWH(3+i*8,s.height-5-h,7,h),fill);}break;
      case S8EnvironmentEntityKind.bridge:c.drawLine(Offset(3,y+9),Offset(s.width-3,y+9),line);for(var i=0;i<5;i++) {
        c.drawArc(Rect.fromLTWH(3+i*8,y,12,18),0,math.pi,line);
      }break;
      case S8EnvironmentEntityKind.nightSky:c.drawCircle(Offset(x,y),15,f(const Color(0xFF172D48)));for(var i=0;i<5;i++) {
        c.drawCircle(Offset(8+i*7,8+(i%2)*9),1.3,hi);
      }break;
      case S8EnvironmentEntityKind.computer:case S8EnvironmentEntityKind.monitor:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-19,y-14,38,25),const Radius.circular(4)),fill);c.drawRect(Rect.fromLTWH(x-15,y-10,30,17),f(a.withValues(alpha:.08)));c.drawLine(Offset(x,y+11),Offset(x,y+18),line);c.drawLine(Offset(x-8,y+19),Offset(x+8,y+19),line);c.drawLine(Offset(x-12,y-2),Offset(x-4,y-8),p(a));c.drawLine(Offset(x-4,y-8),Offset(x+7,y-1),p(a));break;
      case S8EnvironmentEntityKind.keyboard:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-20,y-8,40,18),const Radius.circular(4)),fill);for(var i=0;i<10;i++) {
        c.drawCircle(Offset(x-14+(i%5)*7,y-2+(i~/5)*6),1.3,hi);
      }break;
      case S8EnvironmentEntityKind.printer:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-17,y-8,34,18),const Radius.circular(4)),fill);c.drawRect(Rect.fromLTWH(x-12,y-16,24,11),f(const Color(0xFFCAD0D3)));c.drawRect(Rect.fromLTWH(x-10,y+2,20,10),f(const Color(0xFFD7D0C4)));break;
      case S8EnvironmentEntityKind.controller:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-19,y-9,38,19),const Radius.circular(9)),fill);c.drawCircle(Offset(x-10,y),2,hi);c.drawCircle(Offset(x+10,y-2),2,hi);c.drawLine(Offset(x-3,y),Offset(x+4,y),line);break;
      case S8EnvironmentEntityKind.mouse:c.drawOval(Rect.fromLTWH(x-7,y-12,14,24),fill);c.drawLine(Offset(x,y-12),Offset(x,y-2),line);c.drawCircle(Offset(x,y-5),1.5,hi);break;
      case S8EnvironmentEntityKind.antenna:c.drawLine(Offset(x,y+19),Offset(x,y-10),line);c.drawArc(Rect.fromLTWH(x-14,y-17,28,20),math.pi+.4,math.pi-.8,line);c.drawCircle(Offset(x,y-12),3,hi);break;
      case S8EnvironmentEntityKind.plug:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-8,y-5,16,14),const Radius.circular(4)),fill);c.drawLine(Offset(x-4,y-5),Offset(x-4,y-14),line);c.drawLine(Offset(x+4,y-5),Offset(x+4,y-14),line);c.drawLine(Offset(x+8,y+3),Offset(x+17,y+3),line);break;
      case S8EnvironmentEntityKind.battery:c.drawRect(Rect.fromLTWH(x-10,y-14,20,28),line);c.drawRect(Rect.fromLTWH(x-5,y-18,10,4),line);c.drawRect(Rect.fromLTWH(x-5,y-8,10,17),hi);break;
      case S8EnvironmentEntityKind.scale:c.drawLine(Offset(x,y-17),Offset(x,y+14),line);c.drawLine(Offset(x-16,y-10),Offset(x+16,y-10),line);c.drawLine(Offset(x-12,y-9),Offset(x-18,y+10),line);c.drawLine(Offset(x+12,y-9),Offset(x+18,y+10),line);c.drawArc(Rect.fromLTWH(x-23,y+5,11,8),0,math.pi,line);c.drawArc(Rect.fromLTWH(x+12,y+5,11,8),0,math.pi,line);break;
      case S8EnvironmentEntityKind.crystal:c.drawPath(Path()..moveTo(x,y-20)..lineTo(x+12,y-6)..lineTo(x+7,y+18)..lineTo(x-8,y+18)..lineTo(x-13,y-6)..close(),f(a.withValues(alpha:.18)));c.drawPath(Path()..moveTo(x,y-20)..lineTo(x+12,y-6)..lineTo(x+7,y+18)..lineTo(x-8,y+18)..lineTo(x-13,y-6)..close(),p(a));break;
      case S8EnvironmentEntityKind.teddy:c.drawCircle(Offset(x-7,y-12),5,fill);c.drawCircle(Offset(x+7,y-12),5,fill);c.drawCircle(Offset(x,y-5),11,fill);c.drawCircle(Offset(x,y+9),13,fill);c.drawCircle(Offset(x-4,y-6),1.5,hi);c.drawCircle(Offset(x+4,y-6),1.5,hi);break;
      case S8EnvironmentEntityKind.chart:c.drawRect(Rect.fromLTWH(x-19,y-16,38,31),fill);for(var i=0;i<4;i++) {
        c.drawLine(Offset(x-14+i*8,y+9),Offset(x-14+i*8,y-10-(i%2)*5),p(a));
      }c.drawLine(Offset(x-14,y+9),Offset(x+14,y+9),line);break;
      case S8EnvironmentEntityKind.receipt:case S8EnvironmentEntityKind.document:case S8EnvironmentEntityKind.parchment:case S8EnvironmentEntityKind.note:c.drawRect(Rect.fromLTWH(x-14,y-18,28,34),f(const Color(0xFFD7D0C4)));for(var i=0;i<4;i++) {
        c.drawLine(Offset(x-9,y-10+i*6),Offset(x+9,y-10+i*6),p(a,.9));
      }break;
      case S8EnvironmentEntityKind.calendar:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-16,y-16,32,32),const Radius.circular(4)),line);c.drawLine(Offset(x-16,y-7),Offset(x+16,y-7),line);for(var i=0;i<6;i++) {
        c.drawCircle(Offset(x-9+(i%3)*9,y+(i~/3)*8),1.4,hi);
      }break;
      case S8EnvironmentEntityKind.folder:c.drawPath(Path()..moveTo(x-18,y-10)..lineTo(x-4,y-10)..lineTo(x+1,y-5)..lineTo(x+18,y-5)..lineTo(x+14,y+14)..lineTo(x-18,y+14)..close(),f(const Color(0xFF8C7654)));break;
      case S8EnvironmentEntityKind.cabinet:c.drawRect(Rect.fromLTWH(x-15,y-18,30,36),fill);for(var i=0;i<3;i++){c.drawRect(Rect.fromLTWH(x-11,y-14+i*11,22,8),f(const Color(0xFF162632)));c.drawCircle(Offset(x,y-10+i*11),1.5,hi);}break;
      case S8EnvironmentEntityKind.newspaper:c.drawRect(Rect.fromLTWH(x-19,y-15,38,30),f(const Color(0xFFD7D0C4)));for(var i=0;i<4;i++) {
        c.drawLine(Offset(x-15,y-7+i*6),Offset(x+15,y-7+i*6),p(const Color(0xFF6B7280),.8));
      }break;
      case S8EnvironmentEntityKind.ballot:c.drawRect(Rect.fromLTWH(x-14,y-12,28,24),fill);c.drawLine(Offset(x-7,y-3),Offset(x-1,y+3),p(a,2));c.drawLine(Offset(x-1,y+3),Offset(x+9,y-8),p(a,2));break;
      case S8EnvironmentEntityKind.book:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-18,y-14,36,28),const Radius.circular(3)),fill);c.drawLine(Offset(x,y-13),Offset(x,y+13),line);c.drawLine(Offset(x-13,y-7),Offset(x-3,y-7),p(a));break;
      case S8EnvironmentEntityKind.clip:c.drawArc(Rect.fromLTWH(x-9,y-16,18,27),math.pi,math.pi*1.55,line);c.drawLine(Offset(x,y-2),Offset(x+6,y+14),line);break;
      case S8EnvironmentEntityKind.link:c.drawOval(Rect.fromLTWH(x-18,y-7,22,13),line);c.drawOval(Rect.fromLTWH(x-4,y-7,22,13),line);break;
      case S8EnvironmentEntityKind.calculator:c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-15,y-19,30,38),const Radius.circular(5)),fill);c.drawRect(Rect.fromLTWH(x-10,y-14,20,8),p(a));for(var i=0;i<6;i++) {
        c.drawCircle(Offset(x-8+(i%3)*8,y+(i~/3)*8),1.7,hi);
      }break;
      case S8EnvironmentEntityKind.pin:c.drawCircle(Offset(x,y-7),8,hi);c.drawLine(Offset(x,y),Offset(x,y+18),p(a,2));break;
      case S8EnvironmentEntityKind.search:c.drawCircle(Offset(x-4,y-4),10,line);c.drawLine(Offset(x+4,y+4),Offset(x+14,y+14),p(a,2.2));break;
      case S8EnvironmentEntityKind.bookmark:c.drawPath(Path()..moveTo(x-9,y-18)..lineTo(x+9,y-18)..lineTo(x+9,y+17)..lineTo(x,y+10)..lineTo(x-9,y+17)..close(),f(a.withValues(alpha:.25)));c.drawPath(Path()..moveTo(x-9,y-18)..lineTo(x+9,y-18)..lineTo(x+9,y+17)..lineTo(x,y+10)..lineTo(x-9,y+17)..close(),p(a));break;
    }
  }
  @override bool shouldRepaint(covariant _EntityPainter old)=>old.kind!=kind||old.a!=a;
}
