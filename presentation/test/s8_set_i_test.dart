import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_authority.dart';
import 'package:presentation/s8_presentation_state.dart';
import 'package:presentation/s8_security.dart';

void main() {
  S8ArtifactSummary artifact({String title = 'Evidence'}) => S8ArtifactSummary(
        id: 'evidence-1',
        kind: 'evidence',
        title: title,
        status: 'available',
        integrity: 'pending integrity evaluation',
        temporal: '2026-09-17T00:00:00Z',
      );

  test('SHA-256 receipt detects artifact mutation', () {
    const service = S8IntegrityService();
    final original = artifact();
    final receipt = service.seal(original);
    expect(service.verify(original, receipt), isTrue);
    expect(service.verify(artifact(title: 'Changed'), receipt), isFalse);
  });

  test('authorization grants and revokes capabilities explicitly', () {
    final auth = S8AuthorizationService();
    auth.grant(actorId: 'human', capability: 'challenge');
    expect(auth.isAuthorized(actorId: 'human', capability: 'challenge'), isTrue);
    auth.revoke(actorId: 'human', capability: 'challenge');
    expect(auth.isAuthorized(actorId: 'human', capability: 'challenge'), isFalse);
  });

  test('security audit is append-only to consumers', () {
    final audit = S8SecurityAudit();
    audit.record(actorId: 'human', action: 'inspect', targetId: 'evidence-1');
    expect(audit.events, hasLength(1));
    expect(() => audit.events.clear(), throwsUnsupportedError);
  });

  test('human authority remains separate from verification', () async {
    final state = S8AuthoritativeState.fromSnapshot(
      S8PresentationSnapshot(
        sessionLabel: 'security-test',
        artifacts: [artifact()],
      ),
    );
    final actions = S8HumanActionPanelModel.fromState(state, 'evidence-1');
    expect(actions.allowedActions, contains(S8HumanDecision.challenge));
    expect(actions.synthetic, isFalse);
  });
}
