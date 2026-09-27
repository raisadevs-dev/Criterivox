import 's8_presentation_state.dart';

/// Ports from the presentation boundary into authoritative S8 capabilities.
/// Implementations live outside presentation and are responsible for actual
/// evidence, provenance, verification, explanation and integrity computation.
abstract interface class S8EvidencePort {
  Future<S8ArtifactSummary> recordEvidence({
    required String title,
    String? source,
    String temporal = 'not specified',
  });
}

abstract interface class S8ProvenancePort {
  Future<List<String>> parentsFor(String artifactId);
}

abstract interface class S8VerificationPort {
  Future<S8ArtifactSummary> verify(String artifactId);
}

abstract interface class S8ExplanationPort {
  Future<S8ArtifactSummary> explain(String artifactId);
}

abstract interface class S8IntegrityPort {
  Future<String> integrityFor(String artifactId);
}

/// Human authority is represented as an explicit command boundary.
/// No character, animation, or automated presentation event can substitute
/// for a human decision.
abstract interface class S8HumanAuthorityPort {
  Future<void> inspect(String artifactId);
  Future<void> provideContext(String context);
  Future<void> challenge(String artifactId, String reason);
  Future<void> accept(String artifactId);
}
