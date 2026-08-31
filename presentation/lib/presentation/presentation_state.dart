class PresentationState {
  final String agentId;
  final String characterState;
  final bool active;
  final bool reducedMotion;

  const PresentationState({
    required this.agentId,
    required this.characterState,
    required this.active,
    this.reducedMotion = false,
  });

  PresentationState copyWith({
    String? agentId,
    String? characterState,
    bool? active,
    bool? reducedMotion,
  }) {
    return PresentationState(
      agentId: agentId ?? this.agentId,
      characterState: characterState ?? this.characterState,
      active: active ?? this.active,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }
}