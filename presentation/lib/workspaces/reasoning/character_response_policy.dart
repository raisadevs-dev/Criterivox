import 's7_local_nlp.dart';

/// Converts a parsed S7 intent into a deterministic character response.
///
/// This is presentation policy, not NLP parsing and not computational truth.
/// Analytical truth must continue to come from authoritative S7 artifacts.
class S7CharacterResponsePolicy {
  const S7CharacterResponsePolicy._();

  static String respond(String actor, S7LocalNlpResult result) {
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
