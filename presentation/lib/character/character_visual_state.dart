import '../presentation/presentation_state.dart';

class CharacterVisualState {
  final String agentId;
  final String characterState;
  final bool active;
  final double prominence;
  final bool reducedMotion;

  const CharacterVisualState({
    required this.agentId,
    required this.characterState,
    required this.active,
    required this.prominence,
    required this.reducedMotion,
  });

  factory CharacterVisualState.fromPresentationState(
    PresentationState state,
  ) {
    return CharacterVisualState(
      agentId: state.agentId,
      characterState: state.characterState,
      active: state.active,
      prominence: state.prominence,
      reducedMotion: state.reducedMotion,
    );
  }

  bool get isActive => active;

  bool get isIdle =>
      characterState == 'IDLE' || characterState == 'QUIET';

  bool get isReceiving => characterState == 'RECEIVE';

  bool get isWorking => characterState == 'WORK';

  bool get isCommunicating => characterState == 'COMMUNICATE';

  bool get isHandingOff => characterState == 'HANDOFF';

  bool get isComplete => characterState == 'COMPLETE';

  bool get isWarning => characterState == 'WARNING';

  bool get requiresUserAttention =>
      characterState == 'NEEDS_USER' || characterState == 'WARNING';

  bool get hasMotion => active && !reducedMotion;
}
