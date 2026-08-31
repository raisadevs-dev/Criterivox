import 'presentation_state.dart';

class PresentationAdapter {
  const PresentationAdapter();

  PresentationState adapt({
    required String agentId,
    required String characterState,
    required bool active,
    bool reducedMotion = false,
  }) {
    return PresentationState(
      agentId: agentId,
      characterState: characterState,
      active: active,
      reducedMotion: reducedMotion,
    );
  }
}