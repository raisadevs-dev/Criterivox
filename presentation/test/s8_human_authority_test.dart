import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_authority.dart';
import 'package:presentation/s8_human_authority.dart';
import 'package:presentation/s8_presentation_state.dart';

void main() {
  test('records human decisions without changing artifact truth', () async {
    final controller = S8HumanAuthorityController();
    final inspected = await controller.inspect('artifact-1');
    final challenged = await controller.challenge('artifact-1');
    final accepted = await controller.accept('artifact-1');

    expect(inspected.decision, S8HumanDecision.inspect);
    expect(challenged.requiresDomainReevaluation, isTrue);
    expect(accepted.requiresDomainReevaluation, isFalse);
    expect(controller.history, hasLength(3));
  });

  test('human action model is derived from authoritative state', () {
    const artifact = S8ArtifactSummary(
      id: 'artifact-1',
      kind: 'verification',
      title: 'Verification',
      status: 'insufficient_evidence',
      integrity: 'verified',
      temporal: '2026-09-17',
    );
    final snapshot = S8PresentationSnapshot(
      synthetic: false,
      sessionLabel: 'test',
      lifecycleLabel: 'verification',
      artifacts: const [artifact],
      recentEvents: const [],
      unknowns: const [],
      humanActions: const [],
      medrus: const S8CharacterState(name: 'Medrus', role: 'Evidence & Memory', visualMetaphor: 'evidence', activity: S8ActivityState.idle, activityLabel: 'IDLE', accent: Color(0xFF00FFFF)),
      epistre: const S8CharacterState(name: 'Epistre', role: 'Provenance & Explanation', visualMetaphor: 'provenance', activity: S8ActivityState.idle, activityLabel: 'IDLE', accent: Color(0xFFAA66FF)),
      veridat: const S8CharacterState(name: 'Veridat', role: 'Verification & Truth Boundary', visualMetaphor: 'verification', activity: S8ActivityState.idle, activityLabel: 'IDLE', accent: Color(0xFF00FF99)),
    );
    final model = S8HumanActionPanelModel.fromState(S8AuthoritativeState.fromSnapshot(snapshot), 'artifact-1');
    expect(model.allowedActions, containsAll(S8Authority.humanCan));
    expect(model.artifact.id, 'artifact-1');
  });
}
