/// Deterministic, offline NLP for S7 Debate Arena.
///
/// This deliberately does not call an online LLM, remote inference API, or
/// network service. It performs lightweight intent/entity extraction and
/// routes the result to the existing character-specific reasoning roles.
class S7LocalNlpResult {
  const S7LocalNlpResult({required this.intent, required this.target, required this.tokens, required this.confidence});
  final String intent;
  final String target;
  final List<String> tokens;
  final double confidence;
}

class S7LocalNlp {
  const S7LocalNlp._();

  static S7LocalNlpResult analyze(String input) {
    final normalized = input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9? ]'), ' ');
    final tokens = normalized.split(RegExp(r'\s+')).where((x) => x.isNotEmpty).toList();
    final score = <String, int>{
      'challenge': _hits(tokens, const ['challenge', 'disagree', 'wrong', 'flaw', 'problem', 'critique', 'contradict']),
      'evidence': _hits(tokens, const ['evidence', 'source', 'proof', 'support', 'provenance', 'data']),
      'context': _hits(tokens, const ['context', 'assumption', 'missing', 'limit', 'limitation', 'background']),
      'hypothesis': _hits(tokens, const ['hypothesis', 'alternative', 'possibility', 'scenario', 'branch', 'option', 'explain']),
      'compare': _hits(tokens, const ['compare', 'versus', 'vs', 'difference', 'better', 'both']),
      'why': _hits(tokens, const ['why', 'reason', 'cause', 'because']),
    };
    final ranked = score.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final intent = ranked.first.value == 0 ? 'general' : ranked.first.key;
    final confidence = ranked.first.value == 0 ? .35 : (0.55 + ranked.first.value * .12).clamp(.55, .95);
    final target = intent == 'hypothesis' || intent == 'compare' ? 'tarkis' : intent == 'general' ? 'both' : 'vivren';
    return S7LocalNlpResult(intent: intent, target: target, tokens: tokens, confidence: confidence.toDouble());
  }

  static int _hits(List<String> tokens, List<String> words) => tokens.where(words.contains).length;

  static String response(String actor, S7LocalNlpResult result) {
    final isVivren = actor.toLowerCase() == 'vivren';
    switch (result.intent) {
      case 'challenge':
        return isVivren
            ? 'I will test the claim for contradictions, unsupported assumptions, missing context, and reasoning integrity.'
            : 'I will construct an alternative path and identify the observation that could distinguish it from the current claim.';
      case 'evidence':
        return isVivren
            ? 'Evidence request routed to critical inspection: source, support, provenance, and evidentiary limits should remain explicit.'
            : 'I will treat the available evidence as constraints and explore which candidate hypotheses remain compatible with it.';
      case 'context':
        return isVivren
            ? 'Context inspection: I will separate what is established from assumptions, omissions, and scope limitations.'
            : 'I will examine how changing the surrounding assumptions alters the available hypothesis branches.';
      case 'hypothesis':
        return isVivren
            ? 'I will inspect the proposed hypothesis for evidence, contradictions, and hidden assumptions.'
            : 'Hypothesis exploration: I will generate alternative explanations, branches, and tests that could discriminate between them.';
      case 'compare':
        return isVivren
            ? 'Comparison from the inspection side: I will compare evidence quality, assumptions, provenance, and contradictions.'
            : 'Comparison from the exploration side: I will contrast candidate paths, consequences, and discriminating observations.';
      case 'why':
        return isVivren
            ? 'Reasoning inspection: I will trace the supported path and mark where the evidence stops carrying the conclusion.'
            : 'Reasoning exploration: I will examine multiple causal or explanatory paths rather than collapsing immediately to one.';
      default:
        return isVivren
            ? 'Critical inspection is active. Ask about evidence, contradictions, context, provenance, or reasoning integrity.'
            : 'Hypothesis exploration is active. Ask for alternatives, branches, scenarios, comparisons, or tests.';
    }
  }
}
