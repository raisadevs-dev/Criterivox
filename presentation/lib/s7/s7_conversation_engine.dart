import 's7_character_response_policy.dart';
import 's7_context_resolver.dart';
import 's7_conversation_state.dart';
import 's7_local_nlp.dart';
import 's7_nlp_intents.dart';

class S7ConversationAction {
  const S7ConversationAction({
    required this.intent,
    required this.target,
    required this.actor,
    required this.confidence,
    required this.requiresClarification,
    required this.message,
  });

  final S7NlpIntent intent;
  final String? target;
  final String actor;
  final double confidence;
  final bool requiresClarification;
  final String message;
}

/// Coordinates local parsing, context resolution, state, and character policy.
/// It deliberately contains no network or generative-model dependency.
class S7ConversationEngine {
  S7ConversationEngine({S7ConversationState? state})
      : state = state ?? S7ConversationState();

  final S7ConversationState state;

  S7ConversationAction process(String input) {
    final parsed = S7LocalNlp.analyze(input);
    final intent = _intentFromWireName(parsed.intent);
    final resolved = S7ContextResolver.resolve(
      explicitTarget: parsed.target,
      input: input,
      intent: intent,
      state: state,
    );

    final needsTarget = _requiresTarget(intent);
    final needsClarification = needsTarget &&
        resolved.value == null &&
        parsed.confidence < .75;

    final actor = _actorFor(intent);
    final action = S7ConversationAction(
      intent: intent,
      target: resolved.value,
      actor: actor,
      confidence: _combinedConfidence(parsed.confidence, resolved.confidence),
      requiresClarification: needsClarification,
      message: needsClarification
          ? 'The request is ambiguous. A target is required before an analytical action can be selected.'
          : S7CharacterResponsePolicy.respond(actor, parsed),
    );

    state.remember(S7ConversationTurn(
      actor: 'human',
      text: input.trim(),
      intent: intent,
      target: resolved.value,
      confidence: action.confidence,
    ));
    state.awaitingClarification = needsClarification;
    return action;
  }

  static S7NlpIntent _intentFromWireName(String value) {
    for (final intent in S7NlpIntent.values) {
      if (intent.wireName.toLowerCase() == value.toLowerCase()) return intent;
    }
    return switch (value.toLowerCase()) {
      'challenge' => S7NlpIntent.challengeClaim,
      'evidence' => S7NlpIntent.askEvidence,
      'context' => S7NlpIntent.askContext,
      'hypothesis' => S7NlpIntent.exploreHypothesis,
      'compare' => S7NlpIntent.compareHypotheses,
      'why' => S7NlpIntent.askReasoning,
      _ => S7NlpIntent.general,
    };
  }

  static bool _requiresTarget(S7NlpIntent intent) => <S7NlpIntent>{
        S7NlpIntent.askEvidence,
        S7NlpIntent.askContext,
        S7NlpIntent.askReasoning,
        S7NlpIntent.askProvenance,
        S7NlpIntent.askLimitations,
        S7NlpIntent.challengeClaim,
        S7NlpIntent.inspectReasoning,
        S7NlpIntent.inspectAssumption,
        S7NlpIntent.inspectContradiction,
        S7NlpIntent.exploreHypothesis,
        S7NlpIntent.findAlternatives,
        S7NlpIntent.compareHypotheses,
        S7NlpIntent.expandBranch,
        S7NlpIntent.testHypothesis,
        S7NlpIntent.refineHypothesis,
        S7NlpIntent.exploreCounterfactual,
      }.contains(intent);

  static String _actorFor(S7NlpIntent intent) => switch (intent) {
        S7NlpIntent.exploreHypothesis ||
        S7NlpIntent.findAlternatives ||
        S7NlpIntent.compareHypotheses ||
        S7NlpIntent.expandBranch ||
        S7NlpIntent.testHypothesis ||
        S7NlpIntent.refineHypothesis ||
        S7NlpIntent.exploreCounterfactual => 'tarkis',
        _ => 'vivren',
      };

  static double _combinedConfidence(double parser, double resolver) {
    if (resolver == 0) return parser;
    return ((parser * .65) + (resolver * .35)).clamp(.0, .99).toDouble();
  }
}
