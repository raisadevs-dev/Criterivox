import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_authority.dart';
import 'package:presentation/s8_human_authority.dart';
import 'package:presentation/s8_presentation_state.dart';
import 'package:presentation/s8_security.dart';

void main() {
  S8ArtifactSummary artifact({
    String title = 'Evidence',
  }) {
    return S8ArtifactSummary(
      id: 'evidence-1',
      kind: 'evidence',
      title: title,
      status: 'available',
      integrity: 'pending integrity evaluation',
      temporal: '2026-09-17T00:00:00Z',
    );
  }

  test(
    'SHA-256 receipt detects artifact mutation',
    () {
      const service = S8IntegrityService();

      final original = artifact();

      final receipt = service.seal(
        original,
      );

      expect(
        service.verify(
          original,
          receipt,
        ),
        isTrue,
      );

      expect(
        service.verify(
          artifact(title: 'Changed'),
          receipt,
        ),
        isFalse,
      );
    },
  );

  test(
    'authorization grants and revokes capabilities explicitly',
    () {
      final auth = S8AuthorizationService();

      auth.grant(
        actorId: 'human',
        capability: 'challenge',
      );

      expect(
        auth.isAuthorized(
          actorId: 'human',
          capability: 'challenge',
        ),
        isTrue,
      );

      auth.revoke(
        actorId: 'human',
        capability: 'challenge',
      );

      expect(
        auth.isAuthorized(
          actorId: 'human',
          capability: 'challenge',
        ),
        isFalse,
      );
    },
  );

  test(
    'security audit is append-only to consumers',
    () {
      final audit = S8SecurityAudit();

      audit.record(
        actorId: 'human',
        action: 'inspect',
        targetId: 'evidence-1',
      );

      expect(
        audit.events,
        hasLength(1),
      );

      expect(
        () => audit.events.clear(),
        throwsUnsupportedError,
      );
    },
  );

  test(
    'human authority remains separate from verification',
    () {
      final base =
          S8PresentationSnapshot.demo();

      final evidence = artifact();

      final state =
          S8AuthoritativeState.fromSnapshot(
        S8PresentationSnapshot(
          synthetic: false,
          sessionLabel: 'security-test',
          lifecycleLabel:
              base.lifecycleLabel,
          artifacts: [
            evidence,
          ],
          recentEvents:
              base.recentEvents,
          unknowns:
              base.unknowns,
          humanActions:
              base.humanActions,
          medrus:
              base.medrus,
          epistre:
              base.epistre,
          veridat:
              base.veridat,
        ),
      );

      final actions =
          S8HumanActionPanelModel.fromState(
        state,
        'evidence-1',
      );

      expect(
        actions.allowedActions,
        contains(
          S8HumanDecision.challenge,
        ),
      );

      expect(
        actions.synthetic,
        isFalse,
      );

      expect(
        actions.artifact.id,
        'evidence-1',
      );
    },
  );
}