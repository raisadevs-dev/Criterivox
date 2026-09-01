import 'presentation_state.dart';

class ActivityPresentation {
  const ActivityPresentation();

  PresentationState quiet(PresentationState state) {
    return state.copyWith(
      active: false,
      characterState: 'IDLE',
    );
  }

  PresentationState active(PresentationState state) {
    return state.copyWith(
      active: true,
    );
  }

  bool isQuiet(PresentationState state) {
    return !state.active;
  }

  bool isActive(PresentationState state) {
    return state.active;
  }
}