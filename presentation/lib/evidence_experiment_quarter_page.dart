import 'package:flutter/material.dart';

import 'character/session_character_animation.dart';
import 'foundation/criterivox_responsive_scene.dart';
import 'presentation/criterivox_theme.dart' as criterivox_theme;

class EvidenceExperimentQuarterPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onOpenHumanDecisionWorkspace;
  const EvidenceExperimentQuarterPage({super.key, required this.onBack, this.onOpenHumanDecisionWorkspace});
  @override State<EvidenceExperimentQuarterPage> createState() => _EvidenceExperimentQuarterPageState();
}

class _EvidenceExperimentQuarterPageState extends State<EvidenceExperimentQuarterPage> {
  final Map<String, bool> _open = <String, bool>{};
  String _status = 'READY';
  String _selectedArtifact = 'No artifact selected';

  static const _parts = <_EvidencePart>[
    _EvidencePart('hall','Evidence Hall','Shared evidence coordination','Evidence in → claim status, verification queue, contradictions and knowledge transfer','Evidence / artifacts','Inspectable evidence state'),
    _EvidencePart('grounding','Grounding Matrix','Veridat','Map claims to supporting material and expose missing support','Claims + evidence','Grounding status'),
    _EvidencePart('provenance','Provenance Workshop','Epistre','Trace source, transformation, artifact and explanation lineage','Artifacts + source references','Provenance chain'),
    _EvidencePart('memory','Temporal Memory Vault','Medrus','Retrieve retained evidence with temporal validity preserved','Evidence history','Temporal memory view'),
    _EvidencePart('contradiction','Contradiction Reconciliation','Veridat','Expose conflicting evidence without silently selecting a winner','Conflicting artifacts','Contradiction state'),
    _EvidencePart('receipt','Receipt & Artifact Vault','Epistre','Keep inspectable research receipts and artifact identities','Artifacts + events','Audit-ready receipt'),
    _EvidencePart('bitemporal','Bi-Temporal Truth Observatory','Veridat','Separate when a fact was valid from when Criterivox recorded it','Temporal facts','Valid/recorded timeline'),
    _EvidencePart('retrieval','Retrieval Mode','Medrus','Inspect retrieval boundaries, source scope and historical access','Retrieval request','Retrieved evidence set'),
    _EvidencePart('dossier','Provenance Dossier Desk','Epistre','Assemble human-readable evidence lineage for inspection','Provenance records','Dossier'),
    _EvidencePart('consolidation','Memory Consolidation Observatory','Medrus','Show how retained artifacts are consolidated while epistemic metadata remains visible','Evidence artifacts','Memory artifact'),
    _EvidencePart('integrity','Memory Integrity & Isolation Chamber','Medrus','Expose integrity and tenant/context boundaries around retained material','Stored artifacts','Integrity/isolation state'),
    _EvidencePart('tenant','Tenant Security Observatory','Medrus','Inspect tenant and context isolation boundaries','Tenant/context metadata','Access boundary'),
    _EvidencePart('drift','Semantic Entropy & Drift Observatory','Veridat','Expose semantic drift and uncertainty as inspectable state, not hidden certainty','Evidence/semantic state','Drift/uncertainty view'),
    _EvidencePart('line','Line-Level Attribution Studio','Epistre','Inspect fine-grained attribution and citation lineage','Source references','Attribution record'),
    _EvidencePart('transfer','Evidence → Knowledge Transfer','Medrus / Epistre / Veridat','Transfer validated evidence into reusable knowledge with provenance and limitations','Validated evidence','Knowledge transfer package'),
    _EvidencePart('verification','Verification Queue','Veridat','Track claims awaiting verification and explicit epistemic status','Claims + evidence','Verification result'),
  ];

  void _toggle(String id) => setState(() => _open[id] = !(_open[id] ?? false));
  void _inspect(String id) => setState(() { _selectedArtifact = id; _status = 'INSPECTING'; });

  @override Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);
    return Material(
      color: t.page,
      child: SingleChildScrollView(
        child: CriterivoxResponsiveScene(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            IconButton(tooltip: 'Return to Civilization', onPressed: widget.onBack, icon: const Icon(Icons.arrow_back_rounded)),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('HOME 06 · EVIDENCE & EXPERIMENT', style: TextStyle(color: t.primary, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
              Text('Evidence & Experiment Home', style: TextStyle(color: t.text, fontSize: 28, fontWeight: FontWeight.w800)),
              Text('Evidence / XAI Research Sub-Bureau', style: TextStyle(color: t.mutedText, fontSize: 11)),
            ])),
            _StatusPill(label: _status),
          ]),
          const SizedBox(height: 16),
          _members(t),
          const SizedBox(height: 16),
          _truthPanel(t),
          const SizedBox(height: 16),
          _partsPanel(t),
          const SizedBox(height: 16),
          _footer(t),
        ])),
      ),
    );
  }

  Widget _members(criterivox_theme.CriterivoxTheme t) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('LIVE MEMBERS', style: TextStyle(color: t.mutedText, fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 10)),
      const SizedBox(height: 12),
      const Wrap(spacing: 12, runSpacing: 12, children: [
        _MemberCard(id: 'medrus', role: 'Historical memory · temporal retrieval'),
        _MemberCard(id: 'epistre', role: 'Provenance · explanation · attribution'),
        _MemberCard(id: 'veridat', role: 'Verification · grounding · contradiction'),
      ]),
    ]),
  );

  Widget _truthPanel(criterivox_theme.CriterivoxTheme t) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('AUTHORITATIVE EVIDENCE SURFACE', style: TextStyle(color: t.text, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
      const SizedBox(height: 8),
      Text('Evidence is presented through artifacts, provenance, verification, temporal state, contradictions, uncertainty and receipts. The characters are responsibility surfaces, not independent evidence engines.', style: TextStyle(color: t.mutedText, height: 1.45, fontSize: 11)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _ActionChip(label: 'Inspect artifact', icon: Icons.description_outlined, onPressed: () => _inspect('artifact-inspector')),
        _ActionChip(label: 'Trace provenance', icon: Icons.account_tree_outlined, onPressed: () => _inspect('provenance')),
        _ActionChip(label: 'Verify claim', icon: Icons.fact_check_outlined, onPressed: () => _inspect('verification')),
        _ActionChip(label: 'View uncertainty', icon: Icons.help_outline, onPressed: () => _inspect('uncertainty')),
      ]),
      const SizedBox(height: 10),
      Text('Selected: $_selectedArtifact', style: TextStyle(color: t.mutedText, fontSize: 10)),
    ]),
  );

  Widget _partsPanel(criterivox_theme.CriterivoxTheme t) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('EVIDENCE HOME · RESPONSIBILITY PANELS', style: TextStyle(color: t.text, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
      const SizedBox(height: 4),
      Text('One home. Expandable responsibilities. No Level-2 doorway is required to reach the evidence work.', style: TextStyle(color: t.mutedText, fontSize: 10)),
      const SizedBox(height: 10),
      ..._parts.map((part) => _EvidenceExpansion(part: part, expanded: _open[part.id] ?? false, onToggle: () => _toggle(part.id), onInspect: () => _inspect(part.id))),
    ]),
  );

  Widget _footer(criterivox_theme.CriterivoxTheme t) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)),
    child: Row(children: [
      Icon(Icons.privacy_tip_outlined, color: t.mutedText, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text('This surface exposes evidence and epistemic state, not private model chain-of-thought. Uncertainty and missing support remain explicit.', style: TextStyle(color: t.mutedText, fontSize: 10, height: 1.35))),
      if (widget.onOpenHumanDecisionWorkspace != null) OutlinedButton.icon(onPressed: widget.onOpenHumanDecisionWorkspace, icon: const Icon(Icons.home_work_outlined), label: const Text('Human Residence')),
    ]),
  );
}

class _EvidencePart {
  final String id, name, owner, purpose, input, output;
  const _EvidencePart(this.id, this.name, this.owner, this.purpose, this.input, this.output);
}

class _EvidenceExpansion extends StatelessWidget {
  final _EvidencePart part; final bool expanded; final VoidCallback onToggle; final VoidCallback onInspect;
  const _EvidenceExpansion({required this.part, required this.expanded, required this.onToggle, required this.onInspect});
  @override Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: t.surfaceStrong.withValues(alpha: .55), borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)),
      child: Column(children: [
        ListTile(
          onTap: onToggle,
          leading: Icon(expanded ? Icons.expand_less : Icons.expand_more, color: t.primary),
          title: Text(part.name, style: TextStyle(color: t.text, fontWeight: FontWeight.w800, fontSize: 12)),
          subtitle: Text('${part.owner} · ${part.output}', style: TextStyle(color: t.mutedText, fontSize: 9)),
          trailing: IconButton(tooltip: 'Inspect ${part.name}', onPressed: onInspect, icon: const Icon(Icons.visibility_outlined)),
        ),
        if (expanded) Padding(
          padding: const EdgeInsets.fromLTRB(54, 0, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(part.purpose, style: TextStyle(color: t.text, fontSize: 11, height: 1.35)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _Meta(label: 'INPUT', value: part.input),
              _Meta(label: 'OUTPUT', value: part.output),
              const _Meta(label: 'STATE', value: 'Inspectable'),
            ]),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: onInspect, icon: const Icon(Icons.open_in_new, size: 15), label: const Text('Inspect responsibility')),
          ]),
        ),
      ]),
    );
  }
}

class _Meta extends StatelessWidget {
  final String label, value;
  const _Meta({required this.label, required this.value});
  @override Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: t.border)), child: Text('$label · $value', style: TextStyle(color: t.mutedText, fontSize: 9)));
  }
}

class _ActionChip extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onPressed;
  const _ActionChip({required this.label, required this.icon, required this.onPressed});
  @override Widget build(BuildContext context) => OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon, size: 15), label: Text(label));
}

class _StatusPill extends StatelessWidget {
  final String label;
  const _StatusPill({required this.label});
  @override Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: t.border)), child: Text(label, style: TextStyle(color: t.primary, fontWeight: FontWeight.w800, fontSize: 9)));
  }
}

class _MemberCard extends StatelessWidget {
  final String id, role;
  const _MemberCard({required this.id, required this.role});
  @override Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);
    return Container(
      width: 205, padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)),
      child: Row(children: [
        SessionCharacterAnimationView(characterId: id, state: 'IDLE', width: 58, height: 78),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(id[0].toUpperCase() + id.substring(1), style: TextStyle(color: t.text, fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(height: 4),
          Text(role, style: TextStyle(color: t.mutedText, fontSize: 9, height: 1.25)),
        ])),
      ]),
    );
  }
}
