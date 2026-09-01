import 'presentation_state.dart';

class HandoffPresentation {
  const HandoffPresentation();

  PresentationState senderState(PresentationState state) {
    return state.copyWith(
      characterState: 'HANDOFF',
      active: true,
    );
  }

  PresentationState receiverState(PresentationState state) {
    return state.copyWith(
      characterState: 'RECEIVE',
      active: true,
    );
  }
}