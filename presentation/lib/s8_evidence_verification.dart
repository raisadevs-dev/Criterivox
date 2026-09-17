import 's8_artifact_store.dart';
import 's8_capability_ports.dart';
import 's8_presentation_state.dart';

/// Evidence lifecycle states deliberately avoid treating absence of evidence as
/// proof of a claim.
enum S8EvidenceStatus { available, insufficient, contradictory }

enum S8VerificationStatus { provisionallySupported, insufficientEvidence, contradicted }

class S8VerificationResult {
  final String artifactId;
  final S8VerificationStatus status;
  final List<String> evidenceIds;
  final List<String> contradictions;

  const S8VerificationResult({
    required this.artifactId,
    required this.status,
    required this.evidenceIds,
    required this.contradictions,
  });

  String get statusLabel => switch (status) {
        S8VerificationStatus.provisionallySupported => 'provisionally_supported',
        S8VerificationStatus.insufficientEvidence => 'insufficient_evidence',
        S8VerificationStatus.contradicted => 'contradicted',
      };
}

/// Deterministic S8 evidence/verification service for the local presentation
/// boundary. It records explicit evidence and derives verification only from
/// stored artifact state. It does not invent source content or claim certainty.
class S8EvidenceVerificationService implements S8EvidencePort, S8VerificationPort {
  final S8ArtifactStore store;
  final S8ArtifactValidator validator;

  S8EvidenceVerificationService({
    required this.store,
    this.validator = const S8ArtifactValidator(),
  });

  @override
  Future<S8ArtifactSummary> recordEvidence({
    required String title,
    String? source,
    String temporal = 'not specified',
    S8EvidenceStatus status = S8EvidenceStatus.available,
  }) async {
    final id = 'evidence-${DateTime.now().microsecondsSinceEpoch}';
    final artifact = S8ArtifactSummary(
      id: id,
      kind: 'evidence',
      title: title,
      status: switch (status) {
        S8EvidenceStatus.available => 'available',
        S8EvidenceStatus.insufficient => 'insufficient',
        S8EvidenceStatus.contradictory => 'contradictory',
      },
      source: source,
      temporal: temporal,
      integrity: 'pending integrity evaluation',
    );
    _putChecked(artifact);
    return artifact;
  }

  /// Records an explicit contradiction between already-existing evidence.
  /// Nothing is silently discarded or merged.
  S8ArtifactSummary recordContradiction({
    required String title,
    required List<String> evidenceIds,
    String detail = 'conflicting evidence requires human review',
  }) {
    if (evidenceIds.length < 2) {
      throw ArgumentError('A contradiction requires at least two evidence artifacts');
    }
    for (final id in evidenceIds) {
      if (store.get(id) == null) throw StateError('Unknown evidence artifact: $id');
    }
    final artifact = S8ArtifactSummary(
      id: 'contradiction-${DateTime.now().microsecondsSinceEpoch}',
      kind: 'contradiction',
      title: title,
      status: 'unresolved',
      parents: List.unmodifiable(evidenceIds),
      contradictions: [detail],
      integrity: 'pending integrity evaluation',
      temporal: DateTime.now().toUtc().toIso8601String(),
    );
    _putChecked(artifact);
    return artifact;
  }

  @override
  Future<S8ArtifactSummary> verify(String artifactId) async {
    final evidence = store.get(artifactId);
    if (evidence == null) throw StateError('Unknown artifact: $artifactId');
    if (evidence.kind != 'evidence') {
      throw ArgumentError('Verification requires an evidence artifact');
    }

    final contradictions = store.artifacts
        .where((a) => a.kind == 'contradiction' && a.parents.contains(artifactId))
        .toList(growable: false);

    final status = contradictions.isNotEmpty || evidence.status == 'contradictory'
        ? S8VerificationStatus.contradicted
        : evidence.status == 'available'
            ? S8VerificationStatus.provisionallySupported
            : S8VerificationStatus.insufficientEvidence;

    final result = S8ArtifactSummary(
      id: 'verification-$artifactId',
      kind: 'verification',
      title: 'Verification record for ${evidence.title}',
      status: switch (status) {
        S8VerificationStatus.provisionallySupported => 'provisionally_supported',
        S8VerificationStatus.insufficientEvidence => 'insufficient_evidence',
        S8VerificationStatus.contradicted => 'contradicted',
      },
      source: artifactId,
      parents: [artifactId, ...contradictions.map((a) => a.id)],
      uncertainty: status == S8VerificationStatus.provisionallySupported
          ? const ['verification is provisional; no claim of certainty is made']
          : status == S8VerificationStatus.insufficientEvidence
              ? const ['supporting evidence is insufficient']
              : const ['conflicting evidence remains unresolved'],
      contradictions: contradictions.map((a) => a.id).toList(growable: false),
      integrity: 'pending integrity evaluation',
      temporal: DateTime.now().toUtc().toIso8601String(),
    );
    _putChecked(result);
    return result;
  }

  S8VerificationResult inspectVerification(String verificationId) {
    final artifact = store.get(verificationId);
    if (artifact == null || artifact.kind != 'verification') {
      throw StateError('Unknown verification artifact: $verificationId');
    }
    final status = switch (artifact.status) {
      'provisionally_supported' => S8VerificationStatus.provisionallySupported,
      'contradicted' => S8VerificationStatus.contradicted,
      _ => S8VerificationStatus.insufficientEvidence,
    };
    return S8VerificationResult(
      artifactId: verificationId,
      status: status,
      evidenceIds: artifact.parents.where((id) => id.startsWith('evidence-')).toList(growable: false),
      contradictions: artifact.contradictions,
    );
  }

  void _putChecked(S8ArtifactSummary artifact) {
    final errors = validator.validate(artifact);
    if (errors.isNotEmpty) throw ArgumentError(errors.join(', '));
    store.put(artifact);
  }
}
