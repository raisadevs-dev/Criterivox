import 's8_presentation_state.dart';

/// S8 authoritative state boundary.
///
/// Presentation widgets render this state. Characters and animations observe
/// it; they never create or alter computational truth.
enum S8HumanDecision { inspect, provideContext, challenge, accept }

class S8Authority {
  const S8Authority._();

  static const humanCan = <S8HumanDecision>{
    S8HumanDecision.inspect,
    S8HumanDecision.provideContext,
    S8HumanDecision.challenge,
    S8HumanDecision.accept,
  };

  static bool isHumanAction(S8HumanDecision action) => humanCan.contains(action);

  static S8PresentationSnapshot requireSnapshot(S8PresentationSnapshot snapshot) {
    if (snapshot.sessionLabel.trim().isEmpty) {
      throw ArgumentError('S8 session label must not be empty');
    }
    final ids = <String>{};
    for (final artifact in snapshot.artifacts) {
      if (artifact.id.trim().isEmpty || artifact.kind.trim().isEmpty) {
        throw ArgumentError('Every S8 artifact requires an id and kind');
      }
      if (!ids.add(artifact.id)) {
        throw ArgumentError('Duplicate S8 artifact id: ${artifact.id}');
      }
      if (artifact.parents.contains(artifact.id)) {
        throw ArgumentError('Artifact cannot be its own provenance parent: ${artifact.id}');
      }
    }
    return snapshot;
  }
}

/// Immutable authoritative state exposed to the S8 presentation layer.
///
/// The object deliberately contains no methods for verification, inference,
/// or autonomous human decisions. Those capabilities belong to upstream
/// domain services. This boundary only transports their authoritative result.
class S8AuthoritativeState {
  final S8PresentationSnapshot snapshot;

  const S8AuthoritativeState(this.snapshot);

  factory S8AuthoritativeState.fromSnapshot(S8PresentationSnapshot snapshot) =>
      S8AuthoritativeState(S8Authority.requireSnapshot(snapshot));

  List<S8ArtifactSummary> get artifacts => snapshot.artifacts;
  List<String> get recentEvents => snapshot.recentEvents;
  List<String> get unknowns => snapshot.unknowns;
  List<String> get humanActions => snapshot.humanActions;
  bool get isSynthetic => snapshot.synthetic;

  S8CharacterState get medrus => snapshot.medrus;
  S8CharacterState get epistre => snapshot.epistre;
  S8CharacterState get veridat => snapshot.veridat;
}

/// Immutable artifact/provenance contract used by the presentation boundary.
class S8ArtifactContract {
  final S8ArtifactSummary artifact;
  final String? explanationOf;
  final String? verificationOf;

  const S8ArtifactContract({
    required this.artifact,
    this.explanationOf,
    this.verificationOf,
  });

  bool get hasLineage => artifact.parents.isNotEmpty;
  bool get hasUncertainty => artifact.uncertainty.isNotEmpty;
  bool get hasContradictions => artifact.contradictions.isNotEmpty;
}
