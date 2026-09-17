import 's8_authority.dart';
import 's8_capability_ports.dart';
import 's8_presentation_state.dart';

class S8HumanActionResult {
  final S8HumanDecision decision;
  final String artifactId;
  final String message;
  final bool requiresDomainReevaluation;

  const S8HumanActionResult({
    required this.decision,
    required this.artifactId,
    required this.message,
    required this.requiresDomainReevaluation,
  });
}

/// Presentation-side controller for human authority. It records the human
/// decision boundary and delegates any consequential computation upstream.
class S8HumanAuthorityController implements S8HumanAuthorityPort {
  final List<S8HumanActionResult> _history = [];

  List<S8HumanActionResult> get history => List.unmodifiable(_history);

  @override
  Future<S8HumanActionResult> inspect(String artifactId) async =>
      _record(S8HumanDecision.inspect, artifactId, 'Artifact opened for human inspection.', false);

  @override
  Future<S8HumanActionResult> provideContext(String artifactId) async =>
      _record(S8HumanDecision.provideContext, artifactId, 'Human context supplied; domain reevaluation is required before truth changes.', true);

  @override
  Future<S8HumanActionResult> challenge(String artifactId) async =>
      _record(S8HumanDecision.challenge, artifactId, 'Human challenge recorded; the existing conclusion remains unchanged pending reevaluation.', true);

  @override
  Future<S8HumanActionResult> accept(String artifactId) async =>
      _record(S8HumanDecision.accept, artifactId, 'Human acceptance recorded as a decision, not as computational verification.', false);

  S8HumanActionResult _record(
    S8HumanDecision decision,
    String artifactId,
    String message,
    bool requiresDomainReevaluation,
  ) {
    if (artifactId.trim().isEmpty) throw ArgumentError('artifactId must not be empty');
    if (!S8Authority.isHumanAction(decision)) throw StateError('Unsupported human action');
    final result = S8HumanActionResult(
      decision: decision,
      artifactId: artifactId,
      message: message,
      requiresDomainReevaluation: requiresDomainReevaluation,
    );
    _history.add(result);
    return result;
  }
}

class S8HumanActionPanelModel {
  final S8ArtifactSummary artifact;
  final List<S8HumanDecision> allowedActions;
  final bool synthetic;

  const S8HumanActionPanelModel({
    required this.artifact,
    required this.allowedActions,
    required this.synthetic,
  });

  factory S8HumanActionPanelModel.fromState(
    S8AuthoritativeState state,
    String artifactId,
  ) {
    final artifact = state.artifacts.firstWhere(
      (a) => a.id == artifactId,
      orElse: () => throw StateError('Unknown artifact: $artifactId'),
    );
    return S8HumanActionPanelModel(
      artifact: artifact,
      allowedActions: S8Authority.humanCan.toList(growable: false),
      synthetic: state.isSynthetic,
    );
  }
}
