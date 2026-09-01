import 'presentation_state.dart';

class AttentionPresentation {
  const AttentionPresentation();

  double prominence(PresentationState state) {
    if (!state.active) {
      return 0.0;
    }

    switch (state.characterState) {
      case 'WARNING':
      case 'NEEDS_USER':
        return 1.0;
      case 'WORK':
      case 'RECEIVE':
      case 'HANDOFF':
      case 'COMMUNICATE':
        return 0.75;
      case 'COMPLETE':
        return 0.5;
      case 'IDLE':
      case 'QUIET':
      default:
        return 0.25;
    }
  }
}