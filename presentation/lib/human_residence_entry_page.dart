import 'package:flutter/material.dart';
import 'presentation/criterivox_theme.dart';

class HumanResidenceEntryPage extends StatelessWidget {
  final VoidCallback onCreateHouse;
  final VoidCallback onCreateClub;
  final VoidCallback onGuest;
  const HumanResidenceEntryPage({super.key, required this.onCreateHouse, required this.onCreateClub, required this.onGuest});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('GATE 2', style: TextStyle(color: t.success, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
      const SizedBox(height: 8),
      Text('Build your place in Criterivox', style: TextStyle(color: t.text, fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 7),
      Text('Your human residence is separate from every AI character home. Choose a private house for your own decisions, or a club for shared work.', style: TextStyle(color: t.mutedText, fontSize: 12, height: 1.5)),
      const SizedBox(height: 24),
      Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: _option(t, Icons.home_rounded, 'PRIVATE HOUSE', 'One person owns the residence. Start with a private room, personal decision history and results journal.', 'Create my house', onCreateHouse)),
        const SizedBox(width: 14),
        Expanded(child: _option(t, Icons.groups_rounded, 'CLUB / BUILDING', 'Create a shared residence with a House Owner, Residents and limited Guests.', 'Create a club', onCreateClub)),
      ]),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.border)), child: Row(children: [Icon(Icons.confirmation_number_rounded, color: t.primary), const SizedBox(width: 12), Expanded(child: Text('Not ready to create a residence? Use Guest Pass to test the decision-support experience without a permanent home.', style: TextStyle(color: t.mutedText, fontSize: 10.5, height: 1.45))), TextButton(onPressed: onGuest, child: const Text('Guest Pass'))])),
    ]))));
  }

  Widget _option(CriterivoxTheme t, IconData icon, String label, String body, String action, VoidCallback onTap) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: t.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: t.primary, size: 30), const SizedBox(height: 14), Text(label, style: TextStyle(color: t.primary, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.4)), const SizedBox(height: 8), Text(body, style: TextStyle(color: t.mutedText, fontSize: 11, height: 1.5)), const SizedBox(height: 18), FilledButton.icon(onPressed: onTap, icon: const Icon(Icons.add_rounded, size: 16), label: Text(action))]));
}
