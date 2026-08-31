import 'dart:convert';

import '../character/character_identity.dart';

class PresentationState {
  static const allowedStates = <String>{
    'IDLE',
    'RECEIVE',
    'WORK',
    'COMMUNICATE',
    'HANDOFF',
    'COMPLETE',
    'WARNING',
  };

  final String agentId;
  final String characterState;
  final bool active;
  final bool reducedMotion;
  final double? prominence;
  final String? message;
  final String? event;

  const PresentationState({
    required this.agentId,
    required this.characterState,
    required this.active,
    this.reducedMotion = false,
    this.prominence,
    this.message,
    this.event,
  });

  factory PresentationState.fromJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Runtime message must be an object.');
    }

    final stateValue = decoded['character_state'];
    final agentId = decoded['character_id'];
    final active = decoded['active'];
    final prominence = decoded['prominence'];
    final version = decoded['contract_version'];

    if (version != 1) {
      throw const FormatException('Unsupported presentation contract version.');
    }
    if (agentId is! String || agentId.trim().isEmpty) {
      throw const FormatException('Runtime message has no character ID.');
    }
    if (!CharacterIdentities.all.containsKey(agentId)) {
      throw const FormatException('Runtime message has an unknown character.');
    }
    if (stateValue is! String) {
      throw const FormatException('Runtime message has no character state.');
    }

    final characterState = stateValue.toUpperCase();
    if (!allowedStates.contains(characterState)) {
      throw const FormatException('Runtime message has an unsupported state.');
    }
    if (active is! bool) {
      throw const FormatException('Runtime message has invalid active state.');
    }
    if (prominence is! num || prominence < 0 || prominence > 1) {
      throw const FormatException('Runtime message has invalid prominence.');
    }

    final message = decoded['message'];
    final event = decoded['event'];
    if (message != null && message is! String) {
      throw const FormatException('Runtime message has invalid message.');
    }
    if (event != null && event is! String) {
      throw const FormatException('Runtime message has invalid event.');
    }

    return PresentationState(
      agentId: agentId,
      characterState: characterState,
      active: active,
      reducedMotion: decoded['reduced_motion'] == true,
      prominence: prominence.toDouble(),
      message: message as String?,
      event: event as String?,
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
