import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/communication_presentation.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  test('communication changes character presentation state', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
    );

    const communication = CommunicationPresentation();

    final result = communication.communicate(state);

    expect(result.agentId, 'dharen');
    expect(result.characterState, 'COMMUNICATE');
    expect(result.active, true);
  });

  test('communication activates an inactive agent', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'IDLE',
      active: false,
    );

    const communication = CommunicationPresentation();

    final result = communication.communicate(state);

    expect(result.characterState, 'COMMUNICATE');
    expect(result.active, true);
  });
}