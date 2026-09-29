import 'package:flutter/material.dart';

enum S8Room { home, medrus, epistre, veridat, presentation }

enum S8ActivityState { idle, receive, work, communicate, handoff, complete }

@immutable
class S8ArtifactSummary {
  final String id;
  final String kind;
  final String title;
  final String status;
  final String? source;
  final List<String> parents;
  final List<String> uncertainty;
  final List<String> contradictions;
  final String integrity;
  final String temporal;

  const S8ArtifactSummary({
    required this.id,
    required this.kind,
    required this.title,
    required this.status,
    this.source,
    this.parents = const [],
    this.uncertainty = const [],
    this.contradictions = const [],
    this.integrity = 'not evaluated',
    this.temporal = 'not specified',
  });
}

@immutable
class S8CharacterState {
  final String name;
  final String role;
  final String visualMetaphor;
  final S8ActivityState activity;
  final String activityLabel;
  final Color accent;

  const S8CharacterState({
    required this.name,
    required this.role,
    required this.visualMetaphor,
    required this.activity,
    required this.activityLabel,
    required this.accent,
  });
}

@immutable
class S8PresentationSnapshot {
  final bool synthetic;
  final String sessionLabel;
  final String lifecycleLabel;
  final List<S8ArtifactSummary> artifacts;
  final List<String> recentEvents;
  final List<String> unknowns;
  final List<String> humanActions;
  final S8CharacterState medrus;
  final S8CharacterState epistre;
  final S8CharacterState veridat;

  const S8PresentationSnapshot({
    required this.synthetic,
    required this.sessionLabel,
    required this.lifecycleLabel,
    required this.artifacts,
    required this.recentEvents,
    required this.unknowns,
    required this.humanActions,
    required this.medrus,
    required this.epistre,
    required this.veridat,
  });

  factory S8PresentationSnapshot.demo() {
    const evidence = S8ArtifactSummary(
      id: 'demo-evidence-01',
      kind: 'evidence',
      title: 'Received source material',
      status: 'available',
      source: 'synthetic intake',
      integrity: 'hash recorded',
      temporal: 'validity pending',
    );
    const verification = S8ArtifactSummary(
      id: 'demo-verification-01',
      kind: 'verification',
      title: 'Verification record',
      status: 'insufficient_evidence',
      source: 'demo-evidence-01',
      parents: ['demo-evidence-01'],
      uncertainty: ['additional supporting material required'],
      integrity: 'verified',
    );
    const explanation = S8ArtifactSummary(
      id: 'demo-explanation-01',
      kind: 'explanation',
      title: 'Explanation artifact',
      status: 'provisional',
      parents: ['demo-verification-01'],
      uncertainty: ['verification remains incomplete'],
      integrity: 'verified',
    );
    return const S8PresentationSnapshot(
      synthetic: true,
      sessionLabel: 'Standalone S8 demonstration',
      lifecycleLabel: 'material → evidence → verification → explanation',
      artifacts: [evidence, verification, explanation],
      recentEvents: [
        'Evidence intake recorded',
        'Verification boundary identified insufficient support',
        'Explanation artifact linked to verification state',
      ],
      unknowns: [
        'Additional supporting material is not present',
        'No resolution has been asserted for the open verification state',
      ],
      humanActions: [
        'Inspect evidence chain',
        'Provide supporting context',
        'Challenge verification state',
      ],
      medrus: S8CharacterState(
        name: 'Medrus',
        role: 'Evidence & Memory',
        visualMetaphor: 'sources · retention · temporal memory',
        activity: S8ActivityState.receive,
        activityLabel: 'RECEIVE',
        accent: Color(0xFF26D9FF),
      ),
      epistre: S8CharacterState(
        name: 'Epistre',
        role: 'Provenance & Explanation',
        visualMetaphor: 'lineage · attribution · understanding',
        activity: S8ActivityState.work,
        activityLabel: 'WORK',
        accent: Color(0xFFB26CFF),
      ),
      veridat: S8CharacterState(
        name: 'Veridat',
        role: 'Verification & Truth Boundary',
        visualMetaphor: 'grounding · conflict · uncertainty',
        activity: S8ActivityState.work,
        activityLabel: 'VERIFY',
        accent: Color(0xFF27E0A1),
      ),
    );
  }
}
