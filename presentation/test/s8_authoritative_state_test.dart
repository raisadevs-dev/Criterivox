import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_authority.dart';
import 'package:presentation/s8_presentation_state.dart';

void main() {
  test('authoritative state preserves the upstream snapshot', () {
    final snapshot = S8PresentationSnapshot.demo();
    final state = S8AuthoritativeState.fromSnapshot(snapshot);

    expect(state.snapshot, same(snapshot));
    expect(state.artifacts.length, 3);
    expect(state.medrus.activity, S8ActivityState.receive);
    expect(state.epistre.activity, S8ActivityState.work);
    expect(state.veridat.activity, S8ActivityState.work);
  });

  test('artifact invariants reject duplicate ids and self lineage', () {
    final base = S8PresentationSnapshot.demo();
    const invalid = S8ArtifactSummary(
      id: 'demo-evidence-01',
      kind: 'evidence',
      title: 'duplicate',
      status: 'available',
      parents: const ['demo-evidence-01'],
      integrity: 'hash recorded',
      temporal: 'validity pending',
    );

    final snapshot = S8PresentationSnapshot(
      synthetic: true,
      sessionLabel: base.sessionLabel,
      lifecycleLabel: base.lifecycleLabel,
      artifacts: [base.artifacts.first, invalid],
      recentEvents: base.recentEvents,
      unknowns: base.unknowns,
      humanActions: base.humanActions,
      medrus: base.medrus,
      epistre: base.epistre,
      veridat: base.veridat,
    );

    expect(
      () => S8AuthoritativeState.fromSnapshot(snapshot),
      throwsArgumentError,
    );
  });

  test('human decision vocabulary contains only explicit human actions', () {
    expect(S8Authority.isHumanAction(S8HumanDecision.inspect), isTrue);
    expect(S8Authority.isHumanAction(S8HumanDecision.challenge), isTrue);
    expect(S8Authority.humanCan.length, 4);
  });

  test('artifact validator requires core trust fields', () {
    const artifact = S8ArtifactSummary(
      id: 'a',
      kind: 'evidence',
      title: 'source',
      status: 'available',
      integrity: 'hash recorded',
      temporal: 'validity pending',
    );

    expect(const S8ArtifactValidator().validate(artifact), isEmpty);
    expect(
      const S8ArtifactValidator().validate(const S8ArtifactSummary(
        id: 'a',
        kind: 'evidence',
        title: 'source',
        status: 'available',
        integrity: '',
        temporal: '',
      )),
      containsAll(<String>['missing integrity state', 'missing temporal state']),
    );
  });

  test('character state is data consumed from the authoritative snapshot', () {
    final state = S8AuthoritativeState.fromSnapshot(
      S8PresentationSnapshot.demo(),
    );
    expect(state.medrus.accent, const Color(0xFF26D9FF));
    expect(state.epistre.name, 'Epistre');
    expect(state.veridat.name, 'Veridat');
  });
}
