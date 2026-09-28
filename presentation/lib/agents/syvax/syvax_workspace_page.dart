import 'package:flutter/material.dart';
import '../../interaction/syvax.dart';
import '../../presentation/shared/criterivox_theme.dart';
import 'syvax_presentation.dart';

class SyvaxWorkspacePage extends StatelessWidget {
  final ValueChanged<String> onSubmit;
  final bool busy;
  const SyvaxWorkspacePage({super.key, required this.onSubmit, this.busy = false});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Syvax Interaction & Gateway', style: TextStyle(color: t.text, fontSize: 25, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Receive · preflight · route · control · output', style: TextStyle(color: t.mutedText, fontSize: 11)),
        const SizedBox(height: 14),
        Syvax(onSubmit: onSubmit, busy: busy),
        const SizedBox(height: 14),
        ...SyvaxPresentation.capabilities.map((cap) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(10), border: Border.all(color: t.border)),
          child: Row(children: [
            Icon(cap.icon, color: t.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cap.label, style: TextStyle(color: t.text, fontWeight: FontWeight.w800, fontSize: 12)),
              const SizedBox(height: 3),
              Text(cap.description, style: TextStyle(color: t.mutedText, fontSize: 10)),
            ])),
          ]),
        )),
      ]),
    );
  }
}
