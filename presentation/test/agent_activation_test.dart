import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/agent_activation.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  test('activation marks an agent as active', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'IDLE',
      active: false,
    );

    const activation = AgentActivation();

    final result = activation.activate(state);

    expect(result.active, true);
    expect(result.agentId, 'dharen');
    expect(result.characterState, 'IDLE');
  });

  test('deactivation marks an agent as inactive', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
    );

    const activation = AgentActivation();

    final result = activation.deactivate(state);

    expect(result.active, false);
    expect(result.characterState, 'WORK');
  });
}