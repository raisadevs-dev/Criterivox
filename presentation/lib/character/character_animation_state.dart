enum CharacterAnimationState { idle, receive, work, communicate, handoff, warning, complete }

/// Shared visual interpretation of computational runtime state. Bloom, character
/// views and telemetry can use the same semantic state instead of inventing
/// separate visual meanings.
class CharacterAnimationStateMapper {
  static CharacterAnimationState fromRuntime({
    required String characterState,
    bool communicating = false,
    bool handoff = false,
    bool warning = false,
    bool complete = false,
  }) {
    if (warning) return CharacterAnimationState.warning;
    if (complete) return CharacterAnimationState.complete;
    if (handoff) return CharacterAnimationState.handoff;
    if (communicating) return CharacterAnimationState.communicate;
    return switch (characterState.trim().toUpperCase()) {
      'RECEIVE' || 'RECEIVING' => CharacterAnimationState.receive,
      'WORK' || 'WORKING' || 'ROUTING' || 'VALIDATING' || 'CONTEXTUALIZING' => CharacterAnimationState.work,
      'COMMUNICATE' || 'COMMUNICATING' => CharacterAnimationState.communicate,
      'HANDOFF' || 'HANDING_OFF' => CharacterAnimationState.handoff,
      'WARNING' || 'ALERT' || 'UNCERTAIN' => CharacterAnimationState.warning,
      'COMPLETE' || 'COMPLETED' || 'READY' => CharacterAnimationState.complete,
      _ => CharacterAnimationState.idle,
    };
  }

  static String bloomSignal(CharacterAnimationState state) => switch (state) {
    CharacterAnimationState.idle => 'IDLE',
    CharacterAnimationState.receive => 'RECEIVE',
    CharacterAnimationState.work => 'WORK',
    CharacterAnimationState.communicate => 'COMMUNICATE',
    CharacterAnimationState.handoff => 'HANDOFF',
    CharacterAnimationState.warning => 'WARNING',
    CharacterAnimationState.complete => 'COMPLETE',
  };
}
