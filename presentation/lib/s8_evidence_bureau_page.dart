import 'package:flutter/material.dart';
import 's8_character_presentation.dart';
import 's8_intervention_arena.dart';
import 's8_presentation_state.dart';

class S8EvidenceBureauPage extends StatefulWidget {
  const S8EvidenceBureauPage({super.key});
  @override State<S8EvidenceBureauPage> createState() => _S8EvidenceBureauPageState();
}

class _S8EvidenceBureauPageState extends State<S8EvidenceBureauPage> {
  S8Room room = S8Room.home;
  String? selectedArtifact;
  bool dense = false;
  final snapshot = S8PresentationSnapshot.demo();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF06111E),
    appBar: AppBar(title: const Text('CRITERIVOX  ·  S8  ·  Evidence Research Bureau'), actions: [
      Chip(label: Text(snapshot.synthetic ? 'STANDALONE / SYNTHETIC' : 'LIVE')),
      IconButton(tooltip: dense ? 'Expand information' : 'Reduce information density', onPressed: () => setState(() => dense = !dense), icon: Icon(dense ? Icons.unfold_more : Icons.unfold_less)),
    ]),
    body: Row(children: [
      NavigationRail(selectedIndex: S8Room.values.indexOf(room), onDestinationSelected: (i) => setState(() => room = S8Room.values[i]), labelType: NavigationRailLabelType.all, destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('S8 Home')),
        NavigationRailDestination(icon: Icon(Icons.history_edu_outlined), selectedIcon: Icon(Icons.history_edu), label: Text('Medrus')),
        NavigationRailDestination(icon: Icon(Icons.account_tree_outlined), selectedIcon: Icon(Icons.account_tree), label: Text('Epistre')),
        NavigationRailDestination(icon: Icon(Icons.verified_outlined), selectedIcon: Icon(Icons.verified), label: Text('Veridat')),
        NavigationRailDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: Text('Presentation')),
      ]),
      const VerticalDivider(width: 1), Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [_Header()]..followedBy(_content()))),
    ]),
  );

  List<Widget> _content() {
    if (room == S8Room.home) return [_home()];
    if (room == S8Room.presentation) return [_presentation()];
    return [_specialist()];
  }

  Widget _headerWidget() => Container();

  Widget _home() => Column(children: [
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: S8CharacterPresentation(character: snapshot.medrus)), const SizedBox(width: 10),
      Expanded(child: S8CharacterPresentation(character: snapshot.epistre)), const SizedBox(width: 10),
      Expanded(child: S8CharacterPresentation(character: snapshot.veridat)),
    ]), const SizedBox(height: 12),
    _section('Information flow', Icons.route, _flow()), const SizedBox(height: 12),
    _section('Recent activity', Icons.history, Column(children: snapshot.recentEvents.map((e) => ListTile(leading: const Icon(Icons.circle, size: 8), title: Text(e))).toList())),
    const SizedBox(height: 12),
    _section('Key epistemic state', Icons.insights, Column(children: snapshot.unknowns.map((e) => ListTile(leading: const Icon(Icons.help_outline), title: const Text('Unknown / unresolved'), subtitle: Text(e))).toList())),
    const SizedBox(height: 12),
    Wrap(spacing: 8, runSpacing: 8, children: [
      FilledButton.icon(onPressed: () => setState(() => room = S8Room.presentation), icon: const Icon(Icons.groups), label: const Text('Open Challenge Arena')),
      OutlinedButton.icon(onPressed: () => setState(() => room = S8Room.medrus), icon: const Icon(Icons.history), label: const Text('Inspect memory')),
      OutlinedButton.icon(onPressed: () => setState(() => room = S8Room.veridat), icon: const Icon(Icons.fact_check), label: const Text('Inspect verification')),
    ]),
  ]);

  Widget _specialist() {
    final c = switch (room) { S8Room.medrus => snapshot.medrus, S8Room.epistre => snapshot.epistre, _ => snapshot.veridat };
    return Column(children: [S8CharacterPresentation(character: c), const SizedBox(height: 12), _section('Authoritative artifacts', Icons.inventory_2_outlined, _artifactList()), const SizedBox(height: 12),
      if (room == S8Room.medrus) _section('Temporal memory', Icons.timeline, const ListTile(title: Text('Bi-temporal history'), subtitle: Text('Valid time and recorded time remain separate; invalidation is represented as state.'))),
      if (room == S8Room.epistre) _section('Provenance & explanation lineage', Icons.account_tree, const ListTile(title: Text('Source → transformation → artifact → explanation'), subtitle: Text('Lineage remains inspectable over shared artifact identities.'))),
      if (room == S8Room.veridat) _section('Verification / contradiction / uncertainty', Icons.fact_check, Column(children: [const ListTile(title: Text('insufficient_evidence'), subtitle: Text('The system does not assert support the supplied material cannot establish.')), ...snapshot.unknowns.map((x) => ListTile(leading: const Icon(Icons.help_outline), title: const Text('Unknown / unresolved'), subtitle: Text(x)))])),
    ]);
  }

  Widget _presentation() => Column(children: [
    S8CharacterPresentation(character: snapshot.epistre), const SizedBox(height: 12),
    _section('Human interaction loop', Icons.pan_tool_outlined, const ListTile(title: Text('Inspect → trace → question → challenge → provide evidence/context → propose correction → authorize → re-evaluate → inspect revised state'), subtitle: Text('Consequential changes require explicit authorization and authoritative S8 recording.'))),
    const SizedBox(height: 12),
    S8InterventionArena(targetArtifactId: selectedArtifact), const SizedBox(height: 12),
    _section('Original / revised lineage', Icons.compare_arrows, const ListTile(title: Text('Original state is preserved'), subtitle: Text('Revisions must retain intervention provenance and affected artifact relationships.'))),
  ]);

  Widget _artifactList() => Column(children: [for (final a in snapshot.artifacts) ListTile(selected: selectedArtifact == a.id, leading: const Icon(Icons.description_outlined), title: Text(a.title), subtitle: Text('${a.kind} · ${a.status} · ${a.id}'), trailing: const Icon(Icons.chevron_right), onTap: () => setState(() => selectedArtifact = a.id)), if (selectedArtifact != null) _inspector()]);
  Widget _inspector() { final a = snapshot.artifacts.firstWhere((x) => x.id == selectedArtifact); return ExpansionTile(initiallyExpanded: true, title: const Text('Artifact inspector'), subtitle: Text(a.id), children: [_kv('Status', a.status), _kv('Source', a.source ?? 'none'), _kv('Parents', a.parents.isEmpty ? 'none' : a.parents.join(', ')), _kv('Integrity', a.integrity), _kv('Temporal validity', a.temporal), if (a.uncertainty.isNotEmpty) _kv('Uncertainty', a.uncertainty.join('; ')), Wrap(spacing: 8, children: [OutlinedButton.icon(onPressed: () => setState(() => room = S8Room.epistre), icon: const Icon(Icons.route), label: const Text('Trace')), OutlinedButton.icon(onPressed: () => setState(() => room = S8Room.veridat), icon: const Icon(Icons.fact_check), label: const Text('Verify')), FilledButton.icon(onPressed: () => setState(() => room = S8Room.presentation), icon: const Icon(Icons.pan_tool), label: const Text('Challenge'))])]); }
  Widget _flow() => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [_flowNode('Material', Icons.input), _arrow(), _flowNode('Evidence', Icons.inventory_2), _arrow(), _flowNode('Verification', Icons.fact_check), _arrow(), _flowNode('Explanation', Icons.menu_book), _arrow(), _flowNode('Human action', Icons.pan_tool)]));
  Widget _flowNode(String t, IconData i) => Container(width: 145, padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(i), const SizedBox(height: 5), Text(t)]));
  Widget _arrow() => const Padding(padding: EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.arrow_forward));
  Widget _section(String title, IconData icon, Widget child) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleLarge)]), const Divider(), child])));
  Widget _kv(String k, String v) => ListTile(dense: dense, title: Text(k), subtitle: Text(v));
}

class _Header extends StatelessWidget {
  const _Header();
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Color(0xFF0B2940), Color(0xFF10152E)]), border: Border.all(color: Colors.white24)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('S8 INTELLIGENCE ENVIRONMENT', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text('Four rooms · shared artifacts · explicit uncertainty · human authority')])));
}
