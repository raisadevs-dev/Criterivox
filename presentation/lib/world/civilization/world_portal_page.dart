import 'package:flutter/material.dart';
import 'bloom_page.dart';
import 'presentation/presentation_state.dart';
import 'presentation/criterivox_theme.dart';

class CivilizationWorldPortalPage extends StatelessWidget {
  final PresentationState? state;
  final VoidCallback onOpenCivilization;
  final ValueChanged<dynamic>? onOpenCapability;
  final VoidCallback onStewardship;
  final VoidCallback onHandoff;
  final VoidCallback onOpenAnalysis;
  final bool busy;
  const CivilizationWorldPortalPage({super.key, required this.state, required this.onOpenCivilization, required this.onStewardship, required this.onHandoff, required this.onOpenAnalysis, required this.busy, this.onOpenCapability});
  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: t.surface.withValues(alpha: .72), borderRadius: BorderRadius.circular(20), border: Border.all(color: t.border)),
        child: Row(children: [Icon(Icons.public_rounded, color: t.primary, size: 26), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CRITERIVOX WORKERS / BLOOM', style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
          const SizedBox(height: 4), Text('World Portal', style: TextStyle(color: t.text, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4), Text('Orient here, then enter the observable Criterivox Civilization.', style: TextStyle(color: t.mutedText, fontSize: 11)),
        ])), FilledButton.icon(onPressed: onOpenCivilization, icon: const Icon(Icons.location_city_rounded), label: const Text('Enter Civilization'))])),
      const SizedBox(height: 14),
      BloomPage(state: state, onCapability: (_) {}, onOpenCapability: onOpenCapability, onStewardship: onStewardship, onHandoff: onHandoff, onOpenAnalysis: onOpenAnalysis, busy: busy),
    ]));
  }
}