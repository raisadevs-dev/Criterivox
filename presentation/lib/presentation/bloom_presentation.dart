import 'presentation_state.dart';

class BloomPresentation {
  const BloomPresentation();

  PresentationState open(PresentationState state) {
    return state.copyWith(
      active: true,
    );
  }

  PresentationState close(PresentationState state) {
    return state.copyWith(
      active: false,
    );
  }

  bool isOpen(PresentationState state) {
    return state.active;
  }
}