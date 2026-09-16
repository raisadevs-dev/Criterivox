import 'package:flutter/material.dart';

import 's8_character_presentation.dart';
import 's8_presentation_state.dart';

class S8EvidenceBureauPage extends StatefulWidget {
  const S8EvidenceBureauPage({super.key});

  @override
  State<S8EvidenceBureauPage> createState() => _S8EvidenceBureauPageState();
}

class _S8EvidenceBureauPageState extends State<S8EvidenceBureauPage> {
  S8Room room = S8Room.home;
  String? selectedArtifact;
  bool dense = false;
  bool interventionOpen = false;
  final snapshot = S8PresentationSnapshot.demo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111E),
      appBar: AppBar(
        title: const Text('CRITERIVOX  ·  S8  ·  Evidence Research Bureau'),
        actions: [
          Chip(label: Text(snapshot.synthetic ? 'STANDALONE / SYNTHETIC' : 'LIVE')),
          const SizedBox(width: 12),
          IconButton(
            tooltip: dense ? 'Expand information' : 'Reduce information density',
            onPressed: () => setState(() => dense = !dense),
            icon: Icon(dense ? Icons.unfold_more : Icons.unfold_less),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: S8Room.values.indexOf(room),
            onDestinationSelected: (index) => setState(() => room = S8Room.values[index]),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('S8 Home')),
              NavigationRailDestination(icon: Icon(Icons.history_edu_outlined), selectedIcon: Icon(Icons.history_edu), label: Text('Medrus')),
              NavigationRailDestination(icon: Icon(Icons.account_tree_outlined), selectedIcon: Icon(Icons.account_tree), label: Text('Epistre')),
              NavigationRailDestination(icon: Icon(Icons.verified_outlined), selectedIcon: Icon(Icons.verified), label: Text('Veridat')),
              NavigationRailDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: Text('Presentation')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildRoom(context)),
        ],
      ),
    );
  }

  Widget _buildRoom(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _hero(context),
        const SizedBox(height: 16),
        if (room == S8Room.home) _home(context) else _specialistRoom(context),
      ],
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
        gradient: const LinearGradient(colors: [Color(0xFF0B2940), Color(0xFF10152E)]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_roomTitle(), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(snapshot.lifecycleLabel),
        const SizedBox(height: 14),
        Wrap(spacing: 10, runSpacing: 8, children: [
          _stateChip('Unknowns', '${snapshot.unknowns.length}', Icons.help_outline),
          _stateChip('Human actions', '${snapshot.humanActions.length}', Icons.pan_tool_outlined),
          _stateChip('Artifacts', '${snapshot.artifacts.length}', Icons.account_tree_outlined),
          _stateChip('Integrity', 'explicit', Icons.security_outlined),
        ]),
      ]),
    );
  }

  Widget _home(BuildContext context) {
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: S8CharacterPresentation(character: snapshot.medrus)),
        const SizedBox(width: 12),
        Expanded(child: S8CharacterPresentation(character: snapshot.epistre)),
        const SizedBox(width: 12),
        Expanded(child: S8CharacterPresentation(character: snapshot.veridat)),
      ]),
      const SizedBox(height: 12),
      _section('Information flow', Icons.route, _flow()),
      const SizedBox(height: 12),
      _section('Recent activity', Icons.history, Column(children: snapshot.recentEvents.map((e) => ListTile(leading: const Icon(Icons.circle, size: 8), title: Text(e))).toList())),
      const SizedBox(height: 12),
      _section('Quick access', Icons.flash_on, Wrap(spacing: 8, runSpacing: 8, children: [
        FilledButton.icon(onPressed: () => setState(() => room = S8Room.presentation), icon: const Icon(Icons.groups), label: const Text('Open Evidence Challenge Arena')),
        OutlinedButton.icon(onPressed: () => setState(() => room = S8Room.medrus), icon: const Icon(Icons.history), label: const Text('Inspect memory')),
        OutlinedButton.icon(onPressed: () => setState(() => room = S8Room.veridat), icon: const Icon(Icons.fact_check), label: const Text('Inspect verification')),
      ])),
    ]);
  }

  Widget _specialistRoom(BuildContext context) {
    final character = switch (room) {
      S8Room.medrus => snapshot.medrus,
      S8Room.epistre => snapshot.epistre,
      S8Room.veridat => snapshot.veridat,
      _ => snapshot.veridat,
    };
    return Column(children: [
      S8CharacterPresentation(character: character),
      const SizedBox(height: 12),
      _section('Authoritative artifacts', Icons.inventory_2_outlined, _artifactList()),
      const SizedBox(height: 12),
      if (room == S8Room.medrus) _section('Temporal memory', Icons.timeline, _temporalView()),
      if (room == S8Room.epistre) _section('Provenance & explanation lineage', Icons.account_tree, _provenanceView()),
      if (room == S8Room.veridat) ...[
        _section('Verification boundary', Icons.fact_check, _verificationView()),
        const SizedBox(height: 12),
        _section('Contradiction & uncertainty', Icons.warning_amber_outlined, _uncertaintyView()),
      ],
    ]);
  }

  Widget _artifactList() => Column(children: snapshot.artifacts.map((a) => ListTile(
    selected: selectedArtifact == a.id,
    leading: const Icon(Icons.description_outlined),
    title: Text(a.title),
    subtitle: Text('${a.kind} · ${a.status} · ${a.id}'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => setState(() => selectedArtifact = a.id),
  )).toList()..addAll(selectedArtifact == null ? [] : [_inspector()]));

  Widget _inspector() {
    final a = snapshot.artifacts.firstWhere((x) => x.id == selectedArtifact);
    return ExpansionTile(
      initiallyExpanded: true,
      title: const Text('Artifact inspector'),
      subtitle: Text(a.id),
      children: [
        _kv('Status', a.status), _kv('Source', a.source ?? 'none'), _kv('Parents', a.parents.isEmpty ? 'none' : a.parents.join(', ')),
        _kv('Integrity', a.integrity), _kv('Temporal validity', a.temporal),
        if (a.uncertainty.isNotEmpty) _kv('Uncertainty', a.uncertainty.join('; ')),
        if (a.contradictions.isNotEmpty) _kv('Contradictions', a.contradictions.join('; ')),
        Align(alignment: Alignment.centerLeft, child: Wrap(spacing: 8, children: [
          OutlinedButton.icon(onPressed: () => setState(() => room = S8Room.epistre), icon: const Icon(Icons.route), label: const Text('Trace provenance')),
          OutlinedButton.icon(onPressed: () => setState(() => room = S8Room.veridat), icon: const Icon(Icons.fact_check), label: const Text('Verify')),
          FilledButton.icon(onPressed: () => setState(() { room = S8Room.presentation; interventionOpen = true; }), icon: const Icon(Icons.pan_tool), label: const Text('Challenge')),
        ])),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _verificationView() => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    ListTile(leading: Icon(Icons.info_outline), title: Text('insufficient_evidence'), subtitle: Text('Verification does not assert support that the supplied material cannot establish.')),
    ListTile(leading: Icon(Icons.lock_outline), title: Text('Integrity is explicit'), subtitle: Text('Integrity evidence is inspectable separately from epistemic support.')),
  ]);

  Widget _uncertaintyView() => Column(children: snapshot.unknowns.map((x) => ListTile(leading: const Icon(Icons.help_outline), title: Text('Unknown / unresolved'), subtitle: Text(x))).toList());

  Widget _temporalView() => const ListTile(leading: Icon(Icons.timeline), title: Text('Bi-temporal history'), subtitle: Text('Valid time and recorded time remain separate; invalidation is represented as state, not silent deletion.'));

  Widget _provenanceView() => const ListTile(leading: Icon(Icons.route), title: Text('Source → transformation → artifact → explanation'), subtitle: Text('Lineage is presented as inspectable relationships over shared artifact identities.'));

  Widget _flow() => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
    _flowNode('Material', Icons.input), _arrow(), _flowNode('Evidence', Icons.inventory_2), _arrow(), _flowNode('Verification', Icons.fact_check), _arrow(), _flowNode('Explanation', Icons.menu_book), _arrow(), _flowNode('Human action', Icons.pan_tool),
  ]));

  Widget _flowNode(String text, IconData icon) => Container(width: 150, padding: const EdgeInsets.all(14), margin: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(icon), const SizedBox(height: 6), Text(text, textAlign: TextAlign.center)]));
  Widget _arrow() => const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.arrow_forward));
  Widget _section(String title, IconData icon, Widget child) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleLarge)]), const Divider(), child])));
  Widget _stateChip(String title, String value, IconData icon) => Chip(avatar: Icon(icon, size: 18), label: Text('$title: $value'));
  Widget _kv(String k, String v) => ListTile(dense: dense, title: Text(k), subtitle: Text(v));

  String _roomTitle() => switch (room) {
    S8Room.home => 'S8 INTELLIGENCE ENVIRONMENT',
    S8Room.medrus => 'MEDRUS · EVIDENCE & MEMORY',
    S8Room.epistre => 'EPISTRE · PROVENANCE & EXPLANATION',
    S8Room.veridat => 'VERIDAT · VERIFICATION & TRUTH BOUNDARY',
    S8Room.presentation => 'PRESENTATION · HUMAN INTERVENTION',
  };
}
