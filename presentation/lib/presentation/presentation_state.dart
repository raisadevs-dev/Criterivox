import 'dart:convert';

class PresentationState {
  static const allowedStates = <String>{
    'idle',
    'receive',
    'work',
    'communicate',
    'handoff',
    'complete',
    'warning',
  };

  final String agentId;
  final String characterState;
  final bool active;
  final bool reducedMotion;
  final double prominence;
  final String? message;
  final String? event;

  const PresentationState({
    required this.agentId,
    required this.characterState,
    required this.active,
    this.reducedMotion = false,
    this.prominence = 0.25,
    this.message,
    this.event,
  });

  factory PresentationState.fromJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Runtime message must be an object.');
    }

    final state = decoded['character_state'];
    final agentId = decoded['character_id'];
    final active = decoded['active'];
    final prominence = decoded['prominence'];

    if (agentId is! String || agentId.trim().isEmpty) {
      throw const FormatException('Runtime message has no character ID.');
    }
    if (state is! String || !allowedStates.contains(state)) {
      throw const FormatException('Runtime message has an unsupported state.');
    }
    if (active is! bool) {
      throw const FormatException('Runtime message has invalid active state.');
    }
    if (prominence is! num || prominence < 0 || prominence > 1) {
      throw const FormatException('Runtime message has invalid prominence.');
    }

    final version = decoded['contract_version'];
    if (version != 1) {
      throw const FormatException('Unsupported presentation contract version.');
    }

    return PresentationState(
      agentId: agentId,
      characterState: state,
      active: active,
      reducedMotion: decoded['reduced_motion'] == true,
      prominence: prominence.toDouble(),
      message: decoded['message'] as String?,
      event: decoded['event'] as String?,
    );
  }

  PresentationState copyWith({
    String? agentId,
    String? characterState,
    bool? active,
    bool? reducedMotion,
    double? prominence,
    String? message,
    String? event,
  }) {
    return PresentationState(
      agentId: agentId ?? this.agentId,
      characterState: characterState ?? this.characterState,
      active: active ?? this.active,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      prominence: prominence ?? this.prominence,
      message: message ?? this.message,
      event: event ?? this.event,
    );
  }
}
