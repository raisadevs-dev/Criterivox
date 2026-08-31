import 'presentation_state.dart';

class AgentActivation {
  const AgentActivation();

  PresentationState activate(PresentationState state) {
    return state.copyWith(active: true);
  }

  PresentationState deactivate(PresentationState state) {
    return state.copyWith(active: false);
  }
}