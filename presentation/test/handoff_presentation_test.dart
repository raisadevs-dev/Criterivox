import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/handoff_presentation.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  test('sender enters handoff presentation state', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
    );

    const presentation = HandoffPresentation();

    final result = presentation.senderState(state);

    expect(result.characterState, 'HANDOFF');
    expect(result.active, true);
    expect(result.agentId, 'dharen');
  });

  test('receiver enters receive presentation state', () {
    const state = PresentationState(
      agentId: 'vivren',
      characterState: 'IDLE',
      active: false,
    );

    const presentation = HandoffPresentation();

    final result = presentation.receiverState(state);

    expect(result.characterState, 'RECEIVE');
    expect(result.active, true);
  });
}