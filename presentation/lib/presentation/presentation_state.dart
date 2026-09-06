import 'dart:convert';
import '../character/character_identity.dart';

class PresentationState {
  static const allowedStates = <String>{'IDLE','RECEIVE','WORK','COMMUNICATE','HANDOFF','COMPLETE','WARNING'};
  final String agentId;
  final String characterState;
  final bool active;
  final bool reducedMotion;
  final double? prominence;
  final String? message;
  final String? event;
  final String? taskId;
  final String? taskState;
  final String? taskSource;
  final String? task;
  final int? taskDataFields;
  final int? taskContextFields;
  final List<Map<String, dynamic>> observations;
  final List<Map<String, dynamic>> findings;
  final List<Map<String, dynamic>> evidence;
  final List<String> activity;
  final String? error;

  const PresentationState({
    required this.agentId, required this.characterState, required this.active,
    this.reducedMotion = false, this.prominence, this.message, this.event,
    this.taskId, this.taskState, this.taskSource, this.task,
    this.taskDataFields, this.taskContextFields, this.observations = const [],
    this.findings = const [], this.evidence = const [], this.activity = const [], this.error,
  });

  factory PresentationState.fromJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Runtime message must be an object.');
    final version = decoded['contract_version'];
    if (version != 1) throw const FormatException('Unsupported presentation contract version.');
    final agentId = decoded['character_id'];
    final stateValue = decoded['character_state'];
    final active = decoded['active'];
    final prominence = decoded['prominence'];
    if (agentId is! String || agentId.trim().isEmpty || !CharacterIdentities.all.containsKey(agentId)) throw const FormatException('Runtime message has an unknown character.');
    if (stateValue is! String || !allowedStates.contains(stateValue.toUpperCase())) throw const FormatException('Runtime message has an unsupported state.');
    if (active is! bool || prominence is! num || prominence < 0 || prominence > 1) throw const FormatException('Runtime message has invalid character state.');
    final message = decoded['message'];
    final event = decoded['event'];
    if (message != null && message is! String) throw const FormatException('Runtime message has invalid message.');
    if (event != null && event is! String) throw const FormatException('Runtime message has invalid event.');
    List<Map<String, dynamic>> maps(dynamic value) => value is List ? value.whereType<Map>().map((x) => Map<String, dynamic>.from(x)).toList() : const [];
    List<String> strings(dynamic value) => value is List ? value.whereType<String>().toList() : const [];
    int? integer(dynamic value) => value is num ? value.toInt() : null;
    return PresentationState(
      agentId: agentId, characterState: stateValue.toUpperCase(), active: active,
      reducedMotion: decoded['reduced_motion'] == true, prominence: prominence.toDouble(),
      message: message as String?, event: event as String?,
      taskId: decoded['task_id'] as String?, taskState: decoded['task_state'] as String?,
      taskSource: decoded['task_source'] as String?, task: decoded['task'] as String?,
      taskDataFields: integer(decoded['task_data_fields']), taskContextFields: integer(decoded['task_context_fields']),
      observations: maps(decoded['observations']), findings: maps(decoded['findings']), evidence: maps(decoded['evidence']),
      activity: strings(decoded['activity']), error: decoded['error'] as String?,
    );
  }
}
