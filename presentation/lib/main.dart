import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'character/character_presentation.dart';
import 'interaction/bloom.dart';
import 'interaction/syvax.dart';
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';

void main() => runApp(const CriterivoxApp());

class CriterivoxApp extends StatelessWidget {
  const CriterivoxApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Criterivox',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF050618), colorScheme: const ColorScheme.dark(primary: Color(0xFF7665FF), surface: Color(0xFF10132D)), useMaterial3: true),
        home: const CriterivoxPresentationScreen(),
      );
}

class CriterivoxPresentationScreen extends StatefulWidget {
  const CriterivoxPresentationScreen({super.key});
  @override State<CriterivoxPresentationScreen> createState() => _CriterivoxPresentationScreenState();
}

class _CriterivoxPresentationScreenState extends State<CriterivoxPresentationScreen> {
  final CharacterRuntimeClient _runtime = CharacterRuntimeClient();
  PresentationState? _presentationState;
  String? _error;
  String _systemMessage = 'Syvax is ready. Choose a capability or describe what you want to do.';
  BloomCapability? _selectedCapability;
  bool _busy = false;
  static const _data = {'views': 1200, 'likes': 84, 'comments': 17};
  static const _context = {'platform': 'synthetic', 'audience': 'students'};

  @override
  void initState() {
    super.initState();
    _runtime.states.listen((state) { if (!mounted) return; setState(() { _presentationState = state; _busy = state.characterState != 'IDLE'; _error = null; if (state.message != null) _systemMessage = state.message!; }); });
    _runtime.errors.listen((error) { if (!mounted) return; setState(() { _error = error; _busy = false; _systemMessage = 'Syvax could not complete that request.'; }); });
    _runtime.connect();
  }
  void _submitSyvax(String task) => _submitApplication(task: task, source: 'syvax');
  void _selectBloom(BloomCapability capability) {
    setState(() => _selectedCapability = capability);
    if (capability != BloomCapability.analyze) { setState(() => _systemMessage = '${Bloom.labels[capability]} is reserved for a future sprint.'); return; }
    _submitApplication(task: 'Analyze the supplied data in the provided context.', source: 'bloom');
  }
  void _submitApplication({required String task, required String source}) {
    if (_busy) return;
    setState(() { _busy = true; _error = null; _systemMessage = 'Syvax is sending your intent into the application system.'; });
    _runtime.requestApplication(intent: 'analyze', task: task, data: _data, context: _context, source: source);
  }
  @override void dispose() { _runtime.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = _presentationState;
    return Scaffold(body: Stack(children: [
      const Positioned.fill(child: _Atmosphere()),
      SafeArea(child: Column(children: [const _TopBar(), Expanded(child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1080;
        final bloom = Bloom(onSelected: _selectBloom, selected: _selectedCapability);
        final syvax = Syvax(onSubmit: _submitSyvax, busy: _busy);
        if (!wide) return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [bloom, syvax, const SizedBox(height: 14), _Status(message: _systemMessage, error: _error), if (state != null) CharacterPresentation(state: state)]));
        return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(width: 245, child: _LeftRail()),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(8, 18, 8, 25), child: Column(children: [bloom, _Status(message: _systemMessage, error: _error)]))),
          const SizedBox(width: 18),
          SizedBox(width: 370, child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(0, 18, 20, 25), child: Column(children: [syvax, const SizedBox(height: 16), if (state != null) CharacterPresentation(state: state), const SizedBox(height: 16), const _FocusCard()]))),
        ]);
      }))]))
    ]));
  }
}

class _Atmosphere extends StatelessWidget { const _Atmosphere(); @override Widget build(BuildContext context) => CustomPaint(painter: _AtmospherePainter(), child: const SizedBox.expand()); }
class _AtmospherePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..shader = const RadialGradient(center: Alignment(0, -.08), radius: 1.15, colors: [Color(0xFF171849), Color(0xFF0A0C25), Color(0xFF050618)], stops: [0, .55, 1]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, p);
    final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
    canvas.drawCircle(Offset(size.width*.47, size.height*.47), size.width*.15, glow..color = const Color(0x241B48FF));
  }
  @override bool shouldRepaint(covariant _AtmospherePainter oldDelegate) => false;
}

class _TopBar extends StatelessWidget {
  const _TopBar();
  @override Widget build(BuildContext context) => Container(height: 70, padding: const EdgeInsets.symmetric(horizontal: 22), decoration: const BoxDecoration(color: Color(0xAA07091B), border: Border(bottom: BorderSide(color: Color(0x1F6470A8)))), child: Row(children: [const _LogoMark(), const SizedBox(width: 12), const Text('Criterivox', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)), const Spacer(), Container(width: 410, height: 44, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: const Color(0x44141831), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0x223E4770))), child: const Row(children: [Icon(Icons.search_rounded, color: Color(0xFF8C94B6), size: 22), SizedBox(width: 12), Text('Search anything or press /', style: TextStyle(color: Color(0xFF8C94B6), fontSize: 13)), Spacer(), Text('⌘ K', style: TextStyle(color: Color(0xFF9DA4C7), fontSize: 11))])), const SizedBox(width: 24), const Icon(Icons.notifications_none_rounded, color: Color(0xFFD5D8E7)), const SizedBox(width: 20), const CircleAvatar(radius: 18, backgroundColor: Color(0xFF343A67), child: Icon(Icons.person_rounded, color: Colors.white, size: 20)), const SizedBox(width: 9), const Text('Alex Morgan', style: TextStyle(color: Colors.white, fontSize: 13)), const SizedBox(width: 7), const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8C94B6))]);
}
class _LogoMark extends StatelessWidget { const _LogoMark(); @override Widget build(BuildContext context) => SizedBox(width: 34, height: 34, child: CustomPaint(painter: _LogoPainter())); }
class _LogoPainter extends CustomPainter { @override void paint(Canvas canvas, Size size) { for (var i=0;i<8;i++){final a=i*math.pi/4;canvas.drawCircle(Offset(size.width/2+9*math.cos(a),size.height/2+9*math.sin(a)),5,Paint()..color=i.isEven?const Color(0xFF866DFF):const Color(0xFF5B49D8));}canvas.drawCircle(Offset(size.width/2,size.height/2),4,Paint()..color=const Color(0xFF8978FF));} @override bool shouldRepaint(covariant _LogoPainter oldDelegate)=>false; }

class _LeftRail extends StatelessWidget { const _LeftRail(); @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.fromLTRB(20,34,0,20),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0x9910142E),borderRadius:BorderRadius.circular(17),border:Border.all(color:const Color(0x223B4677))),child:const Row(children:[Icon(Icons.auto_awesome,color:Color(0xFF8A76FF),size:18),SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Living Interaction',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w600)),SizedBox(height:6),Text('System active',style:TextStyle(color:Color(0xFF9DA4C7),fontSize:12))])),CircleAvatar(radius:6,backgroundColor:Color(0xFF48E1A1))])),const Spacer(),Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0x9910142E),borderRadius:BorderRadius.circular(17),border:Border.all(color:const Color(0x223B4677))),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('New to Criterivox?',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w600)),SizedBox(height:10),Text('Take a quick tour to learn how Criterivox works.',style:TextStyle(color:Color(0xFF9DA4C7),fontSize:12,height:1.5)),SizedBox(height:15),_RailButton(label:'Start tour  →')]))])); }
class _RailButton extends StatelessWidget { final String label; const _RailButton({required this.label}); @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),decoration:BoxDecoration(color:const Color(0xFF6E55F5),borderRadius:BorderRadius.circular(9)),child:Text(label,style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.w600))); }
class _Status extends StatelessWidget { final String message; final String? error; const _Status({required this.message,this.error}); @override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.symmetric(horizontal:12),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0x9910142E),borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0x223B4677))),child:Row(children:[const Icon(Icons.auto_awesome,color:Color(0xFF8A76FF),size:17),const SizedBox(width:10),Expanded(child:Text(error??message,style:TextStyle(color:error==null?const Color(0xFFBFC5DD):const Color(0xFFFF9D9D),fontSize:12)))])); }
class _FocusCard extends StatelessWidget { const _FocusCard(); @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:const Color(0xAA10132D),borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0x223B4677))),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Your Focus',style:TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.w600)),SizedBox(height:24),Center(child:Icon(Icons.radio_button_checked_rounded,color:Color(0xFF9B70FF),size:72)),SizedBox(height:18),Text('Define success criteria',style:TextStyle(color:Colors.white,fontSize:15,fontWeight:FontWeight.w600)),SizedBox(height:8),Text('Clarify what good looks like for your current project.',style:TextStyle(color:Color(0xFFA9B0C8),fontSize:12,height:1.55)),SizedBox(height:16),_RailButton(label:'Continue  →') ])); }
