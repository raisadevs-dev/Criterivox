import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_artifact_store.dart';
import 'package:presentation/s8_evidence_verification.dart';

void main() {
  late S8ArtifactStore store;
  late S8EvidenceVerificationService service;

  setUp(() {
    store = S8ArtifactStore();
    service = S8EvidenceVerificationService(store: store);
  });

  test('records evidence as an explicit artifact', () async {
    final artifact = await service.recordEvidence(
      title: 'Source A',
      source: 'test fixture',
      temporal: '2026-09-17',
    );

    expect(artifact.kind, 'evidence');
    expect(artifact.status, 'available');
    expect(store.get(artifact.id), same(artifact));
  });

  test('insufficient evidence never becomes a positive verification', () async {
    final evidence = await service.recordEvidence(
      title: 'Incomplete source',
      status: S8EvidenceStatus.insufficient,
    );

    final verification = await service.verify(evidence.id);

    expect(verification.status, 'insufficient_evidence');
    expect(verification.uncertainty, isNotEmpty);
  });

  test('contradictions remain explicit and affect verification', () async {
    final first = await service.recordEvidence(title: 'Source A');
    final second = await service.recordEvidence(title: 'Source B');
    final contradiction = service.recordContradiction(
      title: 'Sources disagree',
      evidenceIds: [first.id, second.id],
    );

    final verification = await service.verify(first.id);

    expect(contradiction.kind, 'contradiction');
    expect(contradiction.parents, contains(first.id));
    expect(contradiction.parents, contains(second.id));
    expect(verification.status, 'contradicted');
    expect(verification.contradictions, contains(contradiction.id));
  });

  test('verification preserves evidence lineage', () async {
    final evidence = await service.recordEvidence(title: 'Traceable source');
    final verification = await service.verify(evidence.id);

    expect(verification.parents, contains(evidence.id));
    final inspected = service.inspectVerification(verification.id);
    expect(inspected.evidenceIds, contains(evidence.id));
  });

  test('verification rejects unknown or non-evidence artifacts', () async {
    expect(
      () => service.verify('missing'),
      throwsStateError,
    );
    final verification = await service.recordEvidence(title: 'Already evidence');
    final result = await service.verify(verification.id);
    expect(result.kind, 'verification');
  });
}
