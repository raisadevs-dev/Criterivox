import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/attention_presentation.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  test('inactive agent has no visual prominence', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'IDLE',
      active: false,
    );

    const presentation = AttentionPresentation();

    expect(presentation.prominence(state), 0.0);
  });

  test('active working agent has moderate prominence', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
    );

    const presentation = AttentionPresentation();

    expect(presentation.prominence(state), 0.75);
  });

  test('warning has highest prominence', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WARNING',
      active: true,
    );

    const presentation = AttentionPresentation();

    expect(presentation.prominence(state), 1.0);
  });
}