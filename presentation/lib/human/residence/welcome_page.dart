import 'dart:async';
import 'package:flutter/material.dart';
import '../../human/residence/store.dart';
import '../../presentation/shared/criterivox_theme.dart';

class HumanWelcomePage extends StatefulWidget {
  final VoidCallback onProfile;
  final VoidCallback onSignIn;
  final VoidCallback onGuest;
  const HumanWelcomePage({super.key, required this.onProfile, required this.onSignIn, required this.onGuest});
  @override
  State<HumanWelcomePage> createState() => _HumanWelcomePageState();
}

class _HumanWelcomePageState extends State<HumanWelcomePage> {
  Timer? _timer;
  HumanResidenceRecord? _record;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _restore();
    _timer = Timer(const Duration(seconds: 3), _continue);
  }

  Future<void> _restore() async {
    final record = await HumanResidenceStore().load();
    if (!mounted) return;
    setState(() { _record = record; _ready = true; });
    if (record != null && record.metadata['authenticated'] == true) _continue();
  }

  void _continue() {
    if (!mounted) return;
    _timer?.cancel();
    if (_record?.metadata['authenticated'] == true) {
      widget.onProfile();
    } else {
      widget.onSignIn();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(
        color: t.surface, borderRadius: BorderRadius.circular(28),
        border: Border.all(color: t.border),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [t.surfaceStrong, t.surface]),
      ), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(width: 64, height: 64, alignment: Alignment.center, decoration: BoxDecoration(color: t.primary.withValues(alpha: .14), shape: BoxShape.circle, boxShadow: [BoxShadow(color: t.primary.withValues(alpha: .18), blurRadius: 28, spreadRadius: 2)]), child: Icon(Icons.auto_awesome_rounded, color: t.primary, size: 32)),
        const SizedBox(height: 18),
        Text('HUMAN TERRITORY', textAlign: TextAlign.center, style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text('Your goals. Your context. Your decisions.', textAlign: TextAlign.center, style: TextStyle(color: t.text, fontSize: 27, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text('A private space to understand situations, explore evidence, compare strategies, and stay in control of your choices.', textAlign: TextAlign.center, style: TextStyle(color: t.mutedText, fontSize: 13, height: 1.6)),
        const SizedBox(height: 22),
        FilledButton.icon(onPressed: _ready && _record?.metadata['authenticated'] == true ? widget.onProfile : widget.onSignIn, icon: const Icon(Icons.person_outline_rounded), label: Text(_record?.metadata['authenticated'] == true ? 'Open Profile' : 'Sign in / Create account')),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: widget.onGuest, icon: const Icon(Icons.explore_outlined), label: const Text('Continue as Guest')),
        const SizedBox(height: 10),
        Text('Continuing automatically…', textAlign: TextAlign.center, style: TextStyle(color: t.mutedText, fontSize: 10)),
      ])),
    )));
  }
}
