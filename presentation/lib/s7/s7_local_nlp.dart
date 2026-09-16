import 's7_nlp_intents.dart';

/// Result of deterministic local language interpretation.
class S7LocalNlpResult {
  const S7LocalNlpResult({
    required this.intent,
    required this.target,
    required this.tokens,
    required this.confidence,
  });

  /// Stable wire name retained for compatibility with the existing S7 UI.
  final String intent;
  final String? target;
  final List<String> tokens;
  final double confidence;
}

class S7LocalNlp {
  const S7LocalNlp._();

  static S7LocalNlpResult analyze(String input) {
    final normalized = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9? ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final tokens = normalized.isEmpty ? <String>[] : normalized.split(' ');

    final scores = <S7NlpIntent, int>{
      for (final intent in S7NlpIntent.values)
        intent: _phraseHits(
          normalized,
          tokens,
          S7NlpIntentRegistry.phrases[intent] ?? const [],
        ),
    };

    if (normalized == 'why' || normalized == 'why?') {
      scores[S7NlpIntent.askReasoning] =
          (scores[S7NlpIntent.askReasoning] ?? 0) + 3;
    }
    if (normalized == 'yes') {
      scores[S7NlpIntent.confirm] = 3;
    }
    if (normalized == 'no') {
      scores[S7NlpIntent.reject] = 3;
    }

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final winner = ranked.first;
    final intent = winner.value == 0 ? S7NlpIntent.general : winner.key;
    final hits = winner.value;
    final confidence = hits == 0
        ? .35
        : (0.52 + hits * .11).clamp(.52, .94).toDouble();

    return S7LocalNlpResult(
      intent: intent.wireName,
      target: _targetFor(intent, normalized),
      tokens: tokens,
      confidence: confidence,
    );
  }

  static int _phraseHits(
    String input,
    List<String> tokens,
    List<String> phrases,
  ) {
    var hits = 0;
    for (final phrase in phrases) {
      if (phrase.contains(' ')) {
        if (input.contains(phrase)) {
          hits++;
        }
      } else if (tokens.contains(phrase)) {
        hits++;
      }
    }
    return hits;
  }

  static String? _targetFor(S7NlpIntent intent, String input) {
    if (input.contains('hypothesis') || input.contains('hypotheses')) {
      return 'hypotheses';
    }
    if (input.contains('claim')) {
      return 'claim';
    }
    if (input.contains('evidence')) {
      return 'evidence';
    }
    if (input.contains('reasoning')) {
      return 'reasoning';
    }
    if (input.contains('assumption')) {
      return 'assumption';
    }
    if (input.contains('contradiction')) {
      return 'contradiction';
    }
    if (input.contains('provenance') || input.contains('lineage')) {
      return 'provenance';
    }
    return switch (intent) {
      S7NlpIntent.findAlternatives || S7NlpIntent.compareHypotheses =>
        'hypotheses',
      _ => null,
    };
  }

  static String response(String actor, S7LocalNlpResult result) {
    final isVivren = actor.toLowerCase() == 'vivren';
    switch (result.intent) {
      case 'ASK_EVIDENCE':
        return isVivren
            ? 'Critical inspection will examine supporting evidence, source, provenance, and evidentiary limits.'
            : 'The evidence will be treated as a constraint while candidate explanations are explored.';
      case 'CHALLENGE_CLAIM':
        return isVivren
            ? 'I will inspect the claim for contradictions, unsupported assumptions, missing context, and reasoning gaps.'
            : 'I will explore an alternative path and identify observations that could distinguish it from the current claim.';
      case 'ASK_CONTEXT':
        return isVivren
            ? 'I will separate established context from assumptions, omissions, and scope limitations.'
            : 'I will examine how changing the surrounding assumptions alters the available hypothesis branches.';
      case 'ASK_PROVENANCE':
        return isVivren
            ? 'I will trace the available provenance and keep the source lineage explicit.'
            : 'I will use source lineage as a constraint when exploring candidate explanations.';
      case 'ASK_LIMITATIONS':
        return isVivren
            ? 'I will identify uncertainty, scope limits, and unsupported transitions in the inspection path.'
            : 'I will examine how uncertainty changes the hypothesis space and possible branches.';
      case 'ASK_REASONING':
        return isVivren
            ? 'I will trace the supported reasoning path and mark where evidence stops carrying the conclusion.'
            : 'I will examine multiple explanatory paths rather than collapsing immediately to one.';
      case 'INSPECT_ASSUMPTION':
        return 'I will isolate the assumption and determine how it affects the analytical result.';
      case 'INSPECT_CONTRADICTION':
        return 'I will isolate the conflicting findings and preserve their source references.';
      case 'FIND_ALTERNATIVES':
      case 'EXPLORE_HYPOTHESIS':
      case 'EXPAND_BRANCH':
      case 'TEST_HYPOTHESIS':
      case 'REFINE_HYPOTHESIS':
      case 'EXPLORE_COUNTERFACTUAL':
        return isVivren
            ? 'I will inspect the proposed hypothesis for evidence, contradictions, and hidden assumptions.'
            : 'I will explore candidate explanations, branches, tests, and refinements without treating exploration as established truth.';
      case 'COMPARE_HYPOTHESES':
        return isVivren
            ? 'I will compare evidence quality, assumptions, provenance, contradictions, and limitations.'
            : 'I will compare candidate paths, consequences, and observations that could discriminate between them.';
      default:
        return isVivren
            ? 'Critical inspection is active. Ask about evidence, contradictions, context, provenance, or reasoning integrity.'
            : 'Hypothesis exploration is active. Ask for alternatives, branches, scenarios, comparisons, or tests.';
    }
  }
}
