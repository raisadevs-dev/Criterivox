import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  test('presentation state preserves its contract', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'IDLE',
      active: false,
    );

    expect(state.agentId, 'dharen');
    expect(state.characterState, 'IDLE');
    expect(state.active, false);
    expect(state.reducedMotion, false);
  });

  test('presentation state supports reduced motion', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
      reducedMotion: true,
    );

    expect(state.reducedMotion, true);
  });

  test('copyWith preserves unchanged values', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
    );

    final updated = state.copyWith(
      characterState: 'COMPLETE',
    );

    expect(updated.agentId, 'dharen');
    expect(updated.characterState, 'COMPLETE');
    expect(updated.active, true);
    expect(updated.reducedMotion, false);
  });
}