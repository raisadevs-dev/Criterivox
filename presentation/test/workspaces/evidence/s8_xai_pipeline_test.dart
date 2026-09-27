import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_artifact_store.dart';
import 'package:presentation/s8_explanation_pipeline.dart';
import 'package:presentation/s8_presentation_state.dart';

void main() {
  test('explanation preserves verification lineage, uncertainty and contradictions', () async {
    final store = S8ArtifactStore();
    store.put(const S8ArtifactSummary(
      id: 'evidence-1', kind: 'evidence', title: 'Source A', status: 'available',
    ));
    store.put(const S8ArtifactSummary(
      id: 'evidence-2', kind: 'evidence', title: 'Source B', status: 'available',
    ));
    store.put(const S8ArtifactSummary(
      id: 'verification-1', kind: 'verification', title: 'Verification',
      status: 'contradicted', parents: ['evidence-1', 'evidence-2'],
      uncertainty: ['date unresolved'], contradictions: ['conflict-1'],
    ));

    final service = S8ExplanationService(store: store);
    final explanation = await service.explain('verification-1');
    final facts = service.inspect(explanation.id);

    expect(explanation.kind, 'explanation');
    expect(explanation.parents, containsAll(['verification-1', 'evidence-1', 'evidence-2']));
    expect(facts.conclusion, 'Contradicted');
    expect(facts.uncertainty, contains('date unresolved'));
    expect(facts.contradictions, contains('conflict-1'));
  });

  test('XAI panels are projections of snapshot facts', () {
    final snapshot = S8PresentationSnapshot.demo();
    final panels = S8XaiPanels.fromSnapshot(snapshot);

    expect(panels.recentActivity, contains('Evidence intake recorded'));
    expect(panels.keyInsights.any((v) => v.contains('Additional supporting material')), isTrue);
    expect(panels.informationFlow.any((v) => v.contains('demo-evidence-01') && v.contains('demo-verification-01')), isTrue);
  });

  test('explanation rejects unknown artifacts', () async {
    final service = S8ExplanationService(store: S8ArtifactStore());
    await expectLater(service.explain('missing'), throwsStateError);
  });
}
