import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const CriterivoxApp());

class CriterivoxApp extends StatelessWidget {
  const CriterivoxApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Criterivox',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF071018),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF79D8C4), brightness: Brightness.dark),
    ),
    home: const Shell(),
  );
}

enum Area { introduction, workers, humans }

class Worker {
  final String name, role, house, district, duty;
  const Worker(this.name,this.role,this.house,this.district,this.duty);
}

const workers = <Worker>[
  Worker('Dharen','Structural Context','Context House','Context & Data District','Organizes the problem and establishes surrounding context.'),
  Worker('Anuka','Adaptive Context','Context House','Context & Data District','Adjusts interpretation as contextual conditions change.'),
  Worker('Sandre','Contextual Weaving','Data Stewardship House','Context & Data District','Connects information across contexts and platforms.'),
  Worker('Kaelen','Temporal & Environmental Context','Data Stewardship House','Context & Data District','Accounts for time and environmental conditions affecting interpretation.'),
  Worker('Syvax','Human-Machine Dialogue','Gateway House','Interaction District','Facilitates communication between the user and the system.'),
  Worker('Vivren','Critical Reasoning','Reasoning House','Intelligence District','Examines assumptions and evaluates reasoning strength.'),
  Worker('Tarkis','Hypothesis & Evidence','Reasoning House','Intelligence District','Forms and evaluates hypotheses using available evidence.'),
  Worker('Pramon','Empirical Proof','Decision House','Decision & Insight District','Examines whether conclusions are supported by empirical evidence.'),
  Worker('Bodhex','Perception & Insight','Decision House','Decision & Insight District','Transforms analyzed information into meaningful insights.'),
  Worker('Manis','Deliberative Reasoning','Decision House','Decision & Insight District','Considers alternatives, implications, and decisions.'),
  Worker('Medrus','Knowledge Retention','Evidence House','Evidence & Verification District','Maintains historical knowledge, previous findings, and patterns.'),
  Worker('Epistre','Knowledge & Explanation Transfer','Evidence House','Evidence & Verification District','Communicates how knowledge and findings were obtained.'),
  Worker('Veridat','Verification','Evidence House','Evidence & Verification District','Checks reliability and verification of findings.'),
  Worker('Viveda','Knowledge Base & Knowledge Support','Knowledge House','Knowledge District','Connects findings with established knowledge and resources.'),
  Worker('Anukor','Adaptive Transfer','Network Territory','Network Territory','Represents system-level adaptation and transfer between contexts.'),
];

const houseResidents = <String, List<String>>{
  'Context House':['Dharen','Anuka'],
  'Data Stewardship House':['Sandre','Kaelen'],
  'Gateway House':['Syvax'],
  'Reasoning House':['Vivren','Tarkis'],
  'Decision House':['Pramon','Bodhex','Manis'],
  'Evidence House':['Medrus','Epistre','Veridat'],
  'Knowledge House':['Viveda'],
};

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override State<Shell> createState()=>_ShellState();
}
class _ShellState extends State<Shell> {
  Area area=Area.introduction;
  String? house, worker;
  int depth=2;

  @override Widget build(BuildContext context)=>Scaffold(
    body:Row(children:[
      NavigationRail(
        extended:true,
        backgroundColor:const Color(0xFF0C1822),
        selectedIndex:area.index,
        onDestinationSelected:(i)=>setState(()=>area=Area.values[i]),
        destinations:const[
          NavigationRailDestination(icon:Icon(Icons.menu_book_outlined),label:Text('Introduction')),
          NavigationRailDestination(icon:Icon(Icons.spa_outlined),label:Text('Criterivox Workers / Bloom')),
          NavigationRailDestination(icon:Icon(Icons.home_work_outlined),label:Text('Human Civilians / Profile')),
        ],
        trailing:Padding(
          padding:const EdgeInsets.all(12),
          child:DropdownButton<int>(
            value:depth,
            items:const[
              DropdownMenuItem(value:1,child:Text('Explorer · 5–8')),
              DropdownMenuItem(value:2,child:Text('Learner · 9–12')),
              DropdownMenuItem(value:3,child:Text('Investigator · 13–17')),
              DropdownMenuItem(value:4,child:Text('Researcher · 18–24')),
              DropdownMenuItem(value:5,child:Text('Professional · 25–30+')),
            ],
            onChanged:(v)=>setState(()=>depth=v??2),
          ),
        ),
      ),
      Expanded(child:switch(area){
        Area.introduction=>Intro(onWorkers:()=>setState(()=>area=Area.workers),onHumans:()=>setState(()=>area=Area.humans)),
        Area.workers=>WorkersPage(depth:depth,house:house,worker:worker,onHouse:(v)=>setState(() { house=v; worker=null; }),onWorker:(v)=>setState(() { worker=v; house=workers.firstWhere((x)=>x.name==v).house; })),
        Area.humans=>const HumansPage(),
      }),
    ]),
  );
}

class Intro extends StatelessWidget {
  final VoidCallback onWorkers,onHumans;
  const Intro({super.key,required this.onWorkers,required this.onHumans});
  @override Widget build(BuildContext context)=>PageFrame(title:'Criterivox World',eyebrow:'WORLD ENTRY',subtitle:'One shared world with two territories: Criterivox responsibilities and human decision ownership.',children:[
    ActionCard(title:'Criterivox Workers / Bloom',body:'Gate 1: districts, Houses, residents, routes, responsibilities and inspectable system concepts.',icon:Icons.spa_outlined,onTap:onWorkers),
    ActionCard(title:'Human Civilians / Profile',body:'Gate 2: Residence, collaboration, Decision Desk and Results Journal. Human decision ownership stays explicit.',icon:Icons.home_work_outlined,onTap:onHumans),
    Panel(title:'SPATIAL HIERARCHY',body:'World → Gate → District → House → Room → Desk / Object'),
    Panel(title:'TRUTH BOUNDARY',body:'A visual state is not evidence of computation. Live activity, provenance and traces must come from authoritative read models.'),
  ]);
}

class WorkersPage extends StatelessWidget {
  final int depth; final String? house,worker; final ValueChanged<String> onHouse,onWorker;
  const WorkersPage({super.key,required this.depth,required this.house,required this.worker,required this.onHouse,required this.onWorker});
  @override Widget build(BuildContext context)=>PageFrame(title:'Criterivox Workers / Bloom',eyebrow:'GATE 1 · CRITERIVOX CIVILIZATION',subtitle:'The Bloom is a spatial representation, not an orchestration engine.',children:[
    Bloom(onHouse:onHouse,onWorker:onWorker),
    Panel(title:'CIVILIZATION REGISTRY',body:houseResidents.keys.map((h)=>h+' · '+houseResidents[h]!.join(', ')).join('\n')),
    Panel(title:'RESIDENT REGISTRY',body:workers.map((w)=>w.name+' · '+w.role+' · '+w.house).join('\n')),
    if(house!=null) HouseView(name:house!,depth:depth,onWorker:onWorker),
    if(worker!=null) WorkerView(worker:workers.firstWhere((w)=>w.name==worker),depth:depth),
    Panel(title:'NETWORK TERRITORY · ANUKOR',body:'Anukor has no conventional permanent House. Signal Towers, Junctions, Streets, Bridges and Anukor Paths represent meaningful transfer only when runtime state exists.'),
  ]);
}

class Bloom extends StatelessWidget {
  final ValueChanged<String> onHouse,onWorker;
  const Bloom({required this.onHouse,required this.onWorker});
  @override Widget build(BuildContext context)=>Card(
    child:SizedBox(
      height:430,
      child:Stack(children:[
        CustomPaint(size:Size.infinite,painter:BloomPainter()),
        const Center(child:CircleAvatar(radius:75,backgroundColor:Color(0x3379D8C4),child:Text('BLOOM',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:2)))),
        Positioned(left:20,top:18,child:const BadgeText('CIVIC CENTRE')),
        Positioned(right:20,top:18,child:const BadgeText('OUTER WORLD')),
        Positioned(left:20,bottom:18,child:const BadgeText('HUMAN CONNECTION')),
        Positioned(right:20,bottom:18,child:const BadgeText('NETWORK TERRITORY')),
        ...houseResidents.keys.toList().asMap().entries.map((e){
          final p=[const Offset(40,90),const Offset(420,90),const Offset(65,290),const Offset(405,285),const Offset(235,40),const Offset(210,325),const Offset(245,190)][e.key];
          return Positioned(left:p.dx,top:p.dy,child:InkWell(
            onTap:()=>onHouse(e.value),
            child:Container(width:150,padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:const Color(0xEE0C1822),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFF213544))),
              child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(e.value,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800)),
                const SizedBox(height:4),
                Wrap(spacing:3,children:houseResidents[e.value]!.map((n)=>GestureDetector(onTap:()=>onWorker(n),child:CircleAvatar(radius:10,child:Text(n.substring(0,1),style:const TextStyle(fontSize:8))))).toList()),
              ]),
            ),
          ));
        }),
      ]),
    ),
  );
}

class BloomPainter extends CustomPainter {
  @override void paint(Canvas c,Size s){
    final p=Paint()..color=const Color(0xFF213544)..style=PaintingStyle.stroke;
    final center=Offset(s.width/2,s.height/2);
    for(var i=0;i<8;i++){final a=i*3.14159/4;c.drawLine(center,Offset(center.dx+170*math.cos(a),center.dy+145*math.sin(a)),p);}
    final g=Paint()..color=const Color(0x33213544);
    for(var x=0.0;x<s.width;x+=55)c.drawLine(Offset(x,0),Offset(x,s.height),g);
    for(var y=0.0;y<s.height;y+=45)c.drawLine(Offset(0,y),Offset(s.width,y),g);
  }
  @override bool shouldRepaint(covariant BloomPainter oldDelegate)=>false;
}

class HouseView extends StatelessWidget {
  final String name; final int depth; final ValueChanged<String> onWorker;
  const HouseView({required this.name,required this.depth,required this.onWorker});
  @override Widget build(BuildContext context){
    final rs=houseResidents[name]!;
    return PanelWidget(title:name.toUpperCase(),subtitle:'Responsibility domain · shared House',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Wrap(spacing:6,children:const[
        Chip(label:Text('Overview')),Chip(label:Text('Residents')),Chip(label:Text('Activity')),Chip(label:Text('Artifacts')),Chip(label:Text('Relationships')),Chip(label:Text('Trace')),
      ]),
      const SizedBox(height:10),
      ...rs.map((n)=>ListTile(dense:true,leading:CircleAvatar(child:Text(n.substring(0,1))),title:Text(n),subtitle:Text(workers.firstWhere((w)=>w.name==n).duty),onTap:()=>onWorker(n))),
      const Text('Rooms are semantic inspection spaces, not backend services.',style:TextStyle(color:Color(0xFF91A0B2),fontSize:10)),
      if(depth>=3)const Panel(title:'EVIDENCE LINEAGE',body:'Source → Extracted Material → Evidence → Claim → Decision'),
    ]));
  }
}

class WorkerView extends StatelessWidget {
  final Worker worker; final int depth;
  const WorkerView({required this.worker,required this.depth});
  @override Widget build(BuildContext context)=>PanelWidget(title:worker.name.toUpperCase(),subtitle:worker.role+' · '+worker.house,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(worker.duty),const SizedBox(height:10),
    Wrap(spacing:6,children:const[
      OutlinedButton(onPressed:null,child:Text('Inspect Work')),
      OutlinedButton(onPressed:null,child:Text('View Context')),
      OutlinedButton(onPressed:null,child:Text('View Connections')),
      OutlinedButton(onPressed:null,child:Text('Open Dialogue')),
    ]),
    if(depth>=3)const Panel(title:'INSPECTABILITY TRACE',body:'Input → Context → Mechanism → Artifact → Evaluation'),
  ]));
}

class HumansPage extends StatelessWidget {
  const HumansPage({super.key});
  @override Widget build(BuildContext context)=>PageFrame(title:'Human Civilians / Profile',eyebrow:'GATE 2 · HUMAN TERRITORY',subtitle:'Human-owned workspace separated from AI responsibilities.',children:[
    PanelWidget(title:'HUMAN RESIDENCE',subtitle:'Private ownership · collaboration · decision · outcome learning',child:Wrap(spacing:10,runSpacing:10,children:[
      ActionCard(title:'Private Room',body:'Goal · Data · Context · Options · Challenge · Action · Results Journal',icon:Icons.person_outline,onTap:()=>open(context,const PrivateRoom())),
      ActionCard(title:'Collaboration Room',body:'Owner · Residents · Guests · Shared Context · Decision Area',icon:Icons.groups_outlined,onTap:()=>open(context,const CollaborationRoom())),
      ActionCard(title:'Decision Desk',body:'Evidence, alternatives, uncertainty and attributed human action.',icon:Icons.gavel_outlined,onTap:()=>open(context,const DecisionDesk())),
      ActionCard(title:'Results Journal',body:'Expected outcome · actual outcome · difference · learning.',icon:Icons.auto_stories_outlined,onTap:()=>open(context,const Journal())),
      ActionCard(title:'Guest Camp',body:'Temporary participation without silent permanent residence.',icon:Icons.campground_outlined,onTap:()=>open(context,const GuestCamp())),
    ])),
    Panel(title:'HUMAN DECISION LIFECYCLE',body:'Goal → Data/Context → Analysis/Options → Human Challenge → Human Decision/Action → Real-World Outcome → Results Journal'),
    ActionCard(title:'Syvax Gateway',body:'Dialogue · Intent · Routing · Output Lens · Steering · Conversation Branches',icon:Icons.forum_outlined,onTap:()=>open(context,const Syvax())),
  ]);
}

void open(BuildContext c,Widget p)=>Navigator.of(c).push(MaterialPageRoute(builder:(_)=>p));

class PrivateRoom extends StatelessWidget {
  const PrivateRoom({super.key});
  @override Widget build(BuildContext context)=>SubPage(title:'Private Room',children:const[
    Panel(title:'GOAL',body:'Human-owned decision goal.'),
    Panel(title:'DATA + CONTEXT',body:'Attach and inspect supporting material. Missing information remains explicit.'),
    Panel(title:'OPTIONS',body:'Alternatives await authoritative analysis artifacts.'),
    Panel(title:'CHALLENGE',body:'Challenge, correction and constraints become meaningful events when connected to the backend.'),
    Panel(title:'ACTION',body:'Human action is distinct from system analysis.'),
    Panel(title:'RESULTS JOURNAL',body:'Decision → expected outcome → actual outcome → difference → learning.'),
  ]);
}
class CollaborationRoom extends StatelessWidget {
  const CollaborationRoom({super.key});
  @override Widget build(BuildContext context)=>SubPage(title:'Collaboration Room',children:const[
    Panel(title:'PARTICIPANTS',body:'Owner · Residents · Guests, governed by actual authorization.'),
    Panel(title:'SHARED CONTEXT',body:'Common working context for human collaborators.'),
    Panel(title:'PROJECT SPACE',body:'Focused collaborative work.'),
    Panel(title:'DECISION AREA',body:'Prepare, review, challenge, and attribute the human decision.'),
  ]);
}
class DecisionDesk extends StatelessWidget {
  const DecisionDesk({super.key});
  @override Widget build(BuildContext context)=>SubPage(title:'Decision Desk',children:const[
    Panel(title:'DECISION RECEIPT',body:'System support: inspectable\nHuman actor: required\nDecision authority: human\nOutcome verification: pending real-world result'),
    Panel(title:'EVIDENCE LINEAGE',body:'Source → Extracted Material → Evidence → Claim → Decision'),
    Panel(title:'REASONING STRUCTURE',body:'Question → Assumptions / Hypotheses / Alternatives → Evidence → Evaluation'),
    Panel(title:'UNCERTAINTY',body:'UNKNOWN · Unsupported thresholds and facts are not manufactured.'),
  ]);
}
class Journal extends StatelessWidget {
  const Journal({super.key});
  @override Widget build(BuildContext context)=>SubPage(title:'Results Journal',children:const[
    Panel(title:'OUTCOME LOOP',body:'Expected outcome: NOT RECORDED\nActual outcome: NOT RECORDED\nDifference: UNKNOWN\nRelevant context: NOT RECORDED\nEvidence: NOT RECORDED'),
    Panel(title:'TIMELINE',body:'Recorded goal → recorded context → recorded analysis artifact → recorded human challenge → human decision → future real-world outcome'),
  ]);
}
class GuestCamp extends StatelessWidget {
  const GuestCamp({super.key});
  @override Widget build(BuildContext context)=>SubPage(title:'Guest Camp',children:const[
    Panel(title:'WELCOME PAVILION',body:'Temporary session boundary.'),
    Panel(title:'GOAL DESK',body:'Temporary goal.'),
    Panel(title:'CONTEXT TABLE',body:'Temporary context.'),
    Panel(title:'TEMPORARY DECISION SPACE',body:'Inspect result before ending the session.'),
  ]);
}
class Syvax extends StatefulWidget {
  const Syvax({super.key});
  @override State<Syvax> createState()=>_SyvaxState();
}
class _SyvaxState extends State<Syvax>{
  final c=TextEditingController(); String result='No presentation input recorded.';
  @override void dispose(){c.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>SubPage(title:'Syvax Gateway',children:[
    PanelWidget(title:'DIALOGUE',subtitle:'Interaction boundary · no claim of backend execution',child:Column(children:[
      TextField(controller:c,maxLines:4,decoration:const InputDecoration(hintText:'Write an instruction, question, challenge, or context…')),
      const SizedBox(height:8),
      FilledButton.icon(onPressed:()=>setState(()=>result=c.text.isEmpty?'No input supplied.':'Presentation input recorded.'),icon:const Icon(Icons.send),label:const Text('Record Input')),
      const SizedBox(height:8),Text(result),
    ])),
    const Panel(title:'INTENT',body:'NOT_CONNECTED · authoritative intent read model required'),
    const Panel(title:'ROUTING',body:'NOT_CONNECTED · Syvax presents routing but does not own orchestration'),
    const Panel(title:'OUTPUT LENS',body:'Executive Summary · Detailed Explanation · Structured Data · Visual Comparison · Raw Structured Payload'),
    const Panel(title:'STEERING',body:'Challenge · Add Constraint · Pause · Resume'),
  ]);
}

class PageFrame extends StatelessWidget {
  final String title,eyebrow,subtitle; final List<Widget> children;
  const PageFrame({required this.title,required this.eyebrow,required this.subtitle,required this.children});
  @override Widget build(BuildContext context)=>SingleChildScrollView(padding:const EdgeInsets.all(28),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1250),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(eyebrow,style:const TextStyle(color:Color(0xFF79D8C4),fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1.5)),
    const SizedBox(height:6),Text(title,style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900)),
    const SizedBox(height:5),Text(subtitle,style:const TextStyle(color:Color(0xFF91A0B2),fontSize:11)),
    const SizedBox(height:22),...children.map((x)=>Padding(padding:const EdgeInsets.only(bottom:14),child:x)),
  ])));
}
class SubPage extends StatelessWidget {
  final String title; final List<Widget> children;
  const SubPage({required this.title,required this.children});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(title)),body:SingleChildScrollView(padding:const EdgeInsets.all(22),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1100),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:children.map((x)=>Padding(padding:const EdgeInsets.only(bottom:12),child:x)).toList()))));
}
class Panel extends StatelessWidget {
  final String title,body; const Panel({required this.title,required this.body});
  @override Widget build(BuildContext context)=>PanelWidget(title:title,subtitle:body,child:const SizedBox.shrink());
}
class PanelWidget extends StatelessWidget {
  final String title,subtitle; final Widget child;
  const PanelWidget({required this.title,required this.subtitle,required this.child});
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(title,style:const TextStyle(fontWeight:FontWeight.w900,letterSpacing:1,fontSize:11)),
    const SizedBox(height:5),Text(subtitle,style:const TextStyle(color:Color(0xFF91A0B2),fontSize:10)),
    const SizedBox(height:10),child,
  ])));
}
class ActionCard extends StatelessWidget {
  final String title,body; final IconData icon; final VoidCallback onTap;
  const ActionCard({required this.title,required this.body,required this.icon,required this.onTap});
  @override Widget build(BuildContext context)=>SizedBox(width:320,child:Card(child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(18),child:Padding(padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Icon(icon,color:const Color(0xFF79D8C4)),const SizedBox(height:8),Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:5),Text(body,style:const TextStyle(fontSize:10,color:Color(0xFF91A0B2))),
  ])))));
}
class BadgeText extends StatelessWidget {
  final String text; const BadgeText(this.text);
  @override Widget build(BuildContext context)=>DecoratedBox(decoration:BoxDecoration(color:const Color(0xEE0C1822),border:Border.all(color:const Color(0xFF213544)),borderRadius:BorderRadius.circular(9)),child:Padding(padding:const EdgeInsets.symmetric(horizontal:8,vertical:5),child:Text(text,style:const TextStyle(fontSize:8,color:Color(0xFF91A0B2),fontWeight:FontWeight.w800))));
}
