import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s7/s7_context_resolver.dart';
import 'package:presentation/s7/s7_conversation_engine.dart';
import 'package:presentation/s7/s7_conversation_state.dart';
import 'package:presentation/s7/s7_local_nlp.dart';

void main() {
  test('classifies evidence request deterministically', () {
    final result = S7LocalNlp.analyze('Show me the evidence behind this claim.');
    expect(result.intent, 'ASK_EVIDENCE');
    expect(result.target, 'claim');
    expect(result.confidence, greaterThan(.5));
  });

  test('keeps exploration intents distinct from inspection', () {
    final result = S7LocalNlp.analyze('Find alternatives and compare hypotheses.');
    expect(result.intent, 'COMPARE_HYPOTHESES');
    expect(result.target, 'hypotheses');
  });

  test('resolves a follow-up reference from conversation state', () {
    final state = S7ConversationState()
      ..activeHypothesisId = 'H1-alternatives'
      ..activeTarget = 'hypotheses';
    final resolved = S7ContextResolver.resolve(
      explicitTarget: null,
      input: 'Compare them.',
      intent: S7LocalNlp.analyze('Compare them.').intent == 'COMPARE_HYPOTHESES'
          ? _compareIntent
          : _compareIntent,
      state: state,
    );
    expect(resolved.value, 'H1-alternatives');
    expect(resolved.confidence, greaterThan(.8));
  });

  test('conversation engine preserves context across turns', () {
    final engine = S7ConversationEngine();
    final first = engine.process('Find alternatives for this hypothesis.');
    expect(first.intent.wireName, 'FIND_ALTERNATIVES');
    expect(first.actor, 'tarkis');

    engine.state.activeHypothesisId = 'H1';
    final second = engine.process('Compare them.');
    expect(second.intent.wireName, 'COMPARE_HYPOTHESES');
    expect(second.target, 'H1');
    expect(second.actor, 'tarkis');
  });
}

const _compareIntent = S7NlpIntent.compareHypotheses;
