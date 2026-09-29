/// Domain vocabulary for the S7 Reasoning Research Bureau's local NLP.
///
/// Intents describe what the human is asking for. They do not perform
/// reasoning and they do not establish computational truth.
enum S7NlpIntent {
  askEvidence,
  askContext,
  askReasoning,
  askProvenance,
  askLimitations,
  challengeClaim,
  inspectReasoning,
  inspectAssumption,
  inspectContradiction,
  exploreHypothesis,
  findAlternatives,
  compareHypotheses,
  expandBranch,
  testHypothesis,
  refineHypothesis,
  exploreCounterfactual,
  confirm,
  reject,
  continueConversation,
  goBack,
  expand,
  clarify,
  general,
}

extension S7NlpIntentName on S7NlpIntent {
  String get wireName => switch (this) {
        S7NlpIntent.askEvidence => 'ASK_EVIDENCE',
        S7NlpIntent.askContext => 'ASK_CONTEXT',
        S7NlpIntent.askReasoning => 'ASK_REASONING',
        S7NlpIntent.askProvenance => 'ASK_PROVENANCE',
        S7NlpIntent.askLimitations => 'ASK_LIMITATIONS',
        S7NlpIntent.challengeClaim => 'CHALLENGE_CLAIM',
        S7NlpIntent.inspectReasoning => 'INSPECT_REASONING',
        S7NlpIntent.inspectAssumption => 'INSPECT_ASSUMPTION',
        S7NlpIntent.inspectContradiction => 'INSPECT_CONTRADICTION',
        S7NlpIntent.exploreHypothesis => 'EXPLORE_HYPOTHESIS',
        S7NlpIntent.findAlternatives => 'FIND_ALTERNATIVES',
        S7NlpIntent.compareHypotheses => 'COMPARE_HYPOTHESES',
        S7NlpIntent.expandBranch => 'EXPAND_BRANCH',
        S7NlpIntent.testHypothesis => 'TEST_HYPOTHESIS',
        S7NlpIntent.refineHypothesis => 'REFINE_HYPOTHESIS',
        S7NlpIntent.exploreCounterfactual => 'EXPLORE_COUNTERFACTUAL',
        S7NlpIntent.confirm => 'CONFIRM',
        S7NlpIntent.reject => 'REJECT',
        S7NlpIntent.continueConversation => 'CONTINUE',
        S7NlpIntent.goBack => 'BACK',
        S7NlpIntent.expand => 'EXPAND',
        S7NlpIntent.clarify => 'CLARIFY',
        S7NlpIntent.general => 'GENERAL',
      };
}

/// Small deterministic phrase registry. Keeping vocabulary separate from
/// the parser makes the NLP auditable and easy to extend without changing the
/// conversation engine.
class S7NlpIntentRegistry {
  const S7NlpIntentRegistry._();

  static const Map<S7NlpIntent, List<String>> phrases = {
    S7NlpIntent.askEvidence: ['evidence', 'source', 'proof', 'support', 'data'],
    S7NlpIntent.askContext: ['context', 'background', 'missing context'],
    S7NlpIntent.askReasoning: ['why', 'reason', 'because', 'reasoning', 'how did'],
    S7NlpIntent.askProvenance: ['provenance', 'origin', 'lineage', 'where did'],
    S7NlpIntent.askLimitations: ['limit', 'limitation', 'uncertain', 'uncertainty', 'weakness'],
    S7NlpIntent.challengeClaim: ['challenge', 'disagree', 'wrong', 'flaw', 'problem', 'critique'],
    S7NlpIntent.inspectReasoning: ['inspect reasoning', 'audit reasoning', 'check reasoning'],
    S7NlpIntent.inspectAssumption: ['assumption', 'assumptions', 'hidden assumption'],
    S7NlpIntent.inspectContradiction: ['contradiction', 'contradictions', 'inconsistent', 'inconsistency'],
    S7NlpIntent.exploreHypothesis: ['hypothesis', 'explore hypothesis', 'explore this'],
    S7NlpIntent.findAlternatives: ['alternative', 'alternatives', 'another possibility', 'other explanation'],
    S7NlpIntent.compareHypotheses: ['compare', 'versus', 'vs', 'difference', 'contrast'],
    S7NlpIntent.expandBranch: ['branch', 'expand branch', 'open branch'],
    S7NlpIntent.testHypothesis: ['test hypothesis', 'test this', 'test it'],
    S7NlpIntent.refineHypothesis: ['refine', 'revise hypothesis', 'narrow hypothesis'],
    S7NlpIntent.exploreCounterfactual: ['counterfactual', 'what if', 'suppose'],
    S7NlpIntent.confirm: ['yes', 'confirm', 'correct', 'do it'],
    S7NlpIntent.reject: ['no', 'reject', 'not that', 'cancel'],
    S7NlpIntent.continueConversation: ['continue', 'go on', 'keep going'],
    S7NlpIntent.goBack: ['back', 'previous', 'undo'],
    S7NlpIntent.expand: ['more', 'expand', 'elaborate', 'explain more'],
    S7NlpIntent.clarify: ['clarify', 'what do you mean'],
  };
}
