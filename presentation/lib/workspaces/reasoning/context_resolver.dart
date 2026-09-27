import 's7_conversation_state.dart';
import 's7_nlp_intents.dart';

class S7ResolvedTarget {
  const S7ResolvedTarget({required this.value, required this.confidence});

  final String? value;
  final double confidence;
}

/// Resolves small conversational references from explicit S7 session state.
/// No semantic model or network call is used.
class S7ContextResolver {
  const S7ContextResolver._();

  static S7ResolvedTarget resolve({
    required String? explicitTarget,
    required String input,
    required S7NlpIntent intent,
    required S7ConversationState state,
  }) {
    if (explicitTarget != null && explicitTarget.isNotEmpty) {
      return S7ResolvedTarget(value: explicitTarget, confidence: .95);
    }

    final lower = input.toLowerCase();
    final wantsPrevious = lower.contains('it') ||
        lower.contains('this') ||
        lower.contains('that') ||
        lower.contains('them') ||
        lower.contains('these') ||
        lower.contains('those') ||
        lower.contains('previous');

    if (!wantsPrevious) {
      return const S7ResolvedTarget(value: null, confidence: .0);
    }

    final target = switch (intent) {
      S7NlpIntent.compareHypotheses ||
      S7NlpIntent.findAlternatives ||
      S7NlpIntent.expandBranch ||
      S7NlpIntent.testHypothesis ||
      S7NlpIntent.refineHypothesis ||
      S7NlpIntent.exploreCounterfactual ||
      S7NlpIntent.exploreHypothesis => state.activeHypothesisId ?? state.activeTarget,
      _ => state.activeArtifactId ?? state.activeClaimId ?? state.activeTarget,
    };

    return S7ResolvedTarget(
      value: target,
      confidence: target == null ? .2 : .86,
    );
  }
}
