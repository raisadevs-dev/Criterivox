import 's8_artifact_store.dart';
import 's8_capability_ports.dart';
import 's8_presentation_state.dart';

/// Structured explanation facts. The service only explains relationships that
/// already exist in the authoritative artifact graph.
class S8ExplanationFacts {
  final String explanationId;
  final String subjectId;
  final String conclusion;
  final List<String> evidenceIds;
  final List<String> reasoningSteps;
  final List<String> uncertainty;
  final List<String> contradictions;
  final String provenance;

  const S8ExplanationFacts({
    required this.explanationId,
    required this.subjectId,
    required this.conclusion,
    required this.evidenceIds,
    required this.reasoningSteps,
    required this.uncertainty,
    required this.contradictions,
    required this.provenance,
  });
}

/// Deterministic explanation implementation for the local S8 boundary.
/// It does not infer new truth. It translates the stored verification state,
/// lineage, uncertainty and contradictions into an explanation artifact.
class S8ExplanationService implements S8ExplanationPort {
  final S8ArtifactStore store;

  const S8ExplanationService({required this.store});

  @override
  Future<S8ArtifactSummary> explain(String artifactId) async {
    final subject = store.get(artifactId);
    if (subject == null) throw StateError('Unknown artifact: $artifactId');

    final verification = subject.kind == 'verification'
        ? subject
        : store.childrenOf(artifactId).cast<S8ArtifactSummary?>().firstWhere(
              (a) => a?.kind == 'verification',
              orElse: () => null,
            );
    if (verification == null) {
      throw StateError('Explanation requires a verification artifact for $artifactId');
    }

    final evidenceIds = verification.parents
        .where((id) => id.startsWith('evidence-'))
        .toList(growable: false);
    final contradictions = List<String>.unmodifiable(verification.contradictions);
    final uncertainty = List<String>.unmodifiable(verification.uncertainty);

    final conclusion = switch (verification.status) {
      'provisionally_supported' => 'The available evidence provisionally supports the verified subject.',
      'contradicted' => 'The verification state is contradicted by unresolved conflicting evidence.',
      _ => 'The available evidence is insufficient to support a stronger conclusion.',
    };

    final steps = <String>[
      if (evidenceIds.isNotEmpty)
        '1. Considered ${evidenceIds.length} linked evidence artifact(s).'
      else
        '1. No direct evidence artifact is linked in the verification lineage.',
      '2. Used the recorded verification status as the conclusion boundary.',
      if (contradictions.isNotEmpty)
        '3. Preserved ${contradictions.length} contradiction reference(s) rather than resolving them silently.',
      if (uncertainty.isNotEmpty)
        '4. Preserved the recorded uncertainty as an explicit limitation.',
    ];

    final explanation = S8ArtifactSummary(
      id: 'explanation-$artifactId',
      kind: 'explanation',
      title: 'Explanation for ${subject.title}',
      status: verification.status == 'provisionally_supported'
          ? 'provisional'
          : verification.status,
      source: verification.id,
      parents: [verification.id, ...evidenceIds],
      uncertainty: uncertainty,
      contradictions: contradictions,
      integrity: 'pending integrity evaluation',
      temporal: DateTime.now().toUtc().toIso8601String(),
    );
    store.put(explanation);
    return explanation;
  }

  S8ExplanationFacts inspect(String explanationId) {
    final explanation = store.get(explanationId);
    if (explanation == null || explanation.kind != 'explanation') {
      throw StateError('Unknown explanation artifact: $explanationId');
    }
    final verificationId = explanation.parents.firstWhere(
      (id) => id.startsWith('verification-'),
      orElse: () => explanation.source ?? '',
    );
    final verification = store.get(verificationId);
    if (verification == null) {
      throw StateError('Explanation has no resolvable verification parent');
    }
    final evidenceIds = explanation.parents
        .where((id) => id.startsWith('evidence-'))
        .toList(growable: false);
    return S8ExplanationFacts(
      explanationId: explanation.id,
      subjectId: verification.id,
      conclusion: switch (verification.status) {
        'provisionally_supported' => 'Provisionally supported',
        'contradicted' => 'Contradicted',
        _ => 'Insufficient evidence',
      },
      evidenceIds: evidenceIds,
      reasoningSteps: const [
        'Evidence lineage was read from the verification artifact.',
        'The recorded verification status defines the conclusion boundary.',
        'Uncertainty and contradiction records remain visible limitations.',
      ],
      uncertainty: explanation.uncertainty,
      contradictions: explanation.contradictions,
      provenance: 'verification ${verification.id}',
    );
  }
}

/// Human-facing projection for the S8 Home panels. It is a projection, not a
/// second source of truth: every entry comes from the supplied snapshot.
class S8XaiPanels {
  final List<String> recentActivity;
  final List<String> keyInsights;
  final List<String> informationFlow;

  const S8XaiPanels({
    required this.recentActivity,
    required this.keyInsights,
    required this.informationFlow,
  });

  factory S8XaiPanels.fromSnapshot(S8PresentationSnapshot snapshot) {
    final artifacts = snapshot.artifacts;
    final recent = <String>[...snapshot.recentEvents];
    for (final artifact in artifacts.reversed.take(5)) {
      recent.add('${artifact.kind}: ${artifact.title} · ${artifact.status}');
    }

    final insights = <String>[];
    insights.addAll(snapshot.unknowns.map((u) => 'Unknown: $u'));
    for (final artifact in artifacts) {
      for (final item in artifact.uncertainty) {
        insights.add('Uncertainty: $item');
      }
      for (final item in artifact.contradictions) {
        insights.add('Contradiction: $item');
      }
    }
    if (insights.isEmpty) insights.add('No unresolved uncertainty is recorded in this snapshot.');

    final flow = <String>[];
    for (final artifact in artifacts) {
      if (artifact.parents.isEmpty) {
        flow.add('${artifact.kind}: ${artifact.id}');
      } else {
        flow.add('${artifact.parents.join(', ')} → ${artifact.id}');
      }
    }
    if (flow.isEmpty) flow.add('No artifact flow is currently recorded.');

    return S8XaiPanels(
      recentActivity: List.unmodifiable(recent),
      keyInsights: List.unmodifiable(insights),
      informationFlow: List.unmodifiable(flow),
    );
  }
}
