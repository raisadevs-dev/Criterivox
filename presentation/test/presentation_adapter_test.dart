import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/presentation_adapter.dart';

void main() {
  test('adapter creates presentation state from application state', () {
    const adapter = PresentationAdapter();

    final state = adapter.adapt(
      agentId: 'dharen',
      characterState: 'RECEIVE',
      active: true,
    );

    expect(state.agentId, 'dharen');
    expect(state.characterState, 'RECEIVE');
    expect(state.active, true);
    expect(state.reducedMotion, false);
  });

  test('adapter preserves reduced-motion state', () {
    const adapter = PresentationAdapter();

    final state = adapter.adapt(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
      reducedMotion: true,
    );

    expect(state.reducedMotion, true);
  });
}