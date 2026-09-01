import 'presentation_state.dart';

class MotionPresentation {
  const MotionPresentation();

  bool shouldAnimate(PresentationState state) {
    return !state.reducedMotion;
  }

  bool shouldUseStaticTransition(
    PresentationState state,
  ) {
    return state.reducedMotion;
  }

  PresentationState applyReducedMotion(
    PresentationState state,
  ) {
    return state.copyWith(
      reducedMotion: true,
    );
  }
}