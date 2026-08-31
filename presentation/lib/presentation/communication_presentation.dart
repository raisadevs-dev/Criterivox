import 'presentation_state.dart';

class CommunicationPresentation {
  const CommunicationPresentation();

  PresentationState communicate(PresentationState state) {
    return state.copyWith(
      characterState: 'COMMUNICATE',
      active: true,
    );
  }
}