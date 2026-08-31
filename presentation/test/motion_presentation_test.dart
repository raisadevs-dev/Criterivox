import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/motion_presentation.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  test('normal presentation allows animation', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
    );

    const presentation = MotionPresentation();

    expect(presentation.shouldAnimate(state), true);
    expect(presentation.shouldUseStaticTransition(state), false);
  });

  test('reduced motion disables animation', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
      reducedMotion: true,
    );

    const presentation = MotionPresentation();

    expect(presentation.shouldAnimate(state), false);
    expect(presentation.shouldUseStaticTransition(state), true);
  });

  test('reduced motion preserves the character state', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'COMMUNICATE',
      active: true,
    );

    const presentation = MotionPresentation();

    final result = presentation.applyReducedMotion(state);

    expect(result.agentId, 'dharen');
    expect(result.characterState, 'COMMUNICATE');
    expect(result.active, true);
    expect(result.reducedMotion, true);
  });
}