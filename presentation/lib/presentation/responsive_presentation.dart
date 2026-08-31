import 'presentation_state.dart';

class ResponsivePresentation {
  const ResponsivePresentation();

  double scaleForWidth(double width) {
    if (width < 600) {
      return 0.85;
    }

    if (width < 900) {
      return 1.0;
    }

    return 1.15;
  }

  bool isCompact(double width) {
    return width < 600;
  }

  bool isExpanded(double width) {
    return width >= 900;
  }

  PresentationState preserveState(
    PresentationState state,
  ) {
    return state.copyWith();
  }
}