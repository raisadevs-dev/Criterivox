import 's8_presentation_state.dart';

/// S8 authoritative state boundary.
///
/// Presentation widgets must render this state. Characters and animations are
/// observers of state, never sources of computational truth.
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
    for (final artifact in snapshot.artifacts) {
      if (artifact.id.trim().isEmpty || artifact.kind.trim().isEmpty) {
        throw ArgumentError('Every S8 artifact requires an id and kind');
      }
    }
    return snapshot;
  }
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
