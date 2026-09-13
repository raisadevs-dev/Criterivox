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
    'WARNING'
  };
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
  final String? taskCreatedAt;
  final String? taskUpdatedAt;
  final String? foundationId;
  final String? foundationMaterialSetId;
  final int? foundationSourceCount;
  final int? foundationCandidateCount;
  final String? foundationConfirmation;
  final String? foundationPreviewQuestion;
  final double? foundationMatchRatio;
  final bool? foundationAutoFill;
  final List<String> foundationIntentGuesses;
  final String? foundationRecipient;
  final int? foundationLogCount;
  final List<String> foundationLogEntries;
  final List<String> foundationConflictFields;
  final List<String> foundationConditionalProvenance;
  final String? contextId;
  final List<String> contextDimensions;
  final List<String> contextMissingDimensions;
  final int? contextNormalizationCount;
  final String? contextBaselineId;
  final String? contextBaselineStatus;
  final String? contextInterpretationId;
  final List<String> contextUncertainty;
  final List<String> contextLimitations;
  final double? contextCompressionRatio;
  final int? contextOriginalItemCount;
  final int? contextRetainedItemCount;
  final int? contextViolationCount;
  final int? contextStateVersion;
  final String? contextCheckpointId;
  final int? contextSandboxCount;
  final Map<String, dynamic>? contextTierBudget;
  final String? contextAuthoritativeInput;
  final Map<String, dynamic>? provenanceGraph;
  final Map<String, dynamic>? contextDiff;
  final int? evidenceCompleteness;
  final String? evidenceDebtLevel;
  final List<String> evidenceTags;
  final String? memoryStatus;
  final String? memoryRecheckAt;
  final String? memoryRecheckReason;
  final List<Map<String, dynamic>> observabilityEvents;
  final String? failureId;
  final String? failureType;
  final String? executionEngine;
  final String? executionTier;
  final bool? fallbackUsed;
  final String? doorAddress;
  final Map<String, dynamic>? lineageSnapshot;
  final String? coordinationId;
  final List<String> coordinationMembers;
  final String? deliveryId;
  final String? deliveryRecipient;
  final String? deliveryStatus;
  final List<Map<String, dynamic>> observations;
  final List<Map<String, dynamic>> findings;
  final List<Map<String, dynamic>> evidence;
  final List<String> activity;
  final String? error;
  const PresentationState(
      {required this.agentId,
      required this.characterState,
      required this.active,
      this.reducedMotion = false,
      this.prominence,
      this.message,
      this.event,
      this.taskId,
      this.taskState,
      this.taskSource,
      this.task,
      this.taskDataFields,
      this.taskContextFields,
      this.taskCreatedAt,
      this.taskUpdatedAt,
      this.foundationId,
      this.foundationMaterialSetId,
      this.foundationSourceCount,
      this.foundationCandidateCount,
      this.foundationConfirmation,
      this.foundationPreviewQuestion,
      this.foundationMatchRatio,
      this.foundationAutoFill,
      this.foundationIntentGuesses = const [],
      this.foundationRecipient,
      this.foundationLogCount,
      this.foundationLogEntries = const [],
      this.foundationConflictFields = const [],
      this.foundationConditionalProvenance = const [],
      this.contextId,
      this.contextDimensions = const [],
      this.contextMissingDimensions = const [],
      this.contextNormalizationCount,
      this.contextBaselineId,
      this.contextBaselineStatus,
      this.contextInterpretationId,
      this.contextUncertainty = const [],
      this.contextLimitations = const [],
      this.contextCompressionRatio,
      this.contextOriginalItemCount,
      this.contextRetainedItemCount,
      this.contextViolationCount,
      this.contextStateVersion,
      this.contextCheckpointId,
      this.contextSandboxCount,
      this.contextTierBudget,
      this.contextAuthoritativeInput,
      this.provenanceGraph,
      this.contextDiff,
      this.evidenceCompleteness,
      this.evidenceDebtLevel,
      this.evidenceTags = const [],
      this.memoryStatus,
      this.memoryRecheckAt,
      this.memoryRecheckReason,
      this.observabilityEvents = const [],
      this.failureId,
      this.failureType,
      this.executionEngine,
      this.executionTier,
      this.fallbackUsed,
      this.doorAddress,
      this.lineageSnapshot,
      this.coordinationId,
      this.coordinationMembers = const [],
      this.deliveryId,
      this.deliveryRecipient,
      this.deliveryStatus,
      this.observations = const [],
      this.findings = const [],
      this.evidence = const [],
      this.activity = const [],
      this.error});

  PresentationState copyWith(
          {String? agentId,
          String? characterState,
          bool? active,
          bool? reducedMotion,
          double? prominence,
          String? message,
          String? event,
          String? taskId,
          String? taskState,
          String? taskSource,
          String? task,
          String? foundationId,
          String? foundationMaterialSetId,
          int? foundationSourceCount,
          int? foundationCandidateCount,
          String? foundationConfirmation,
          String? contextId,
          List<String>? contextDimensions,
          List<String>? contextMissingDimensions,
          String? contextBaselineId,
          String? contextBaselineStatus,
          String? contextInterpretationId,
          double? contextCompressionRatio,
          int? contextOriginalItemCount,
          int? contextRetainedItemCount,
          int? contextViolationCount,
          int? contextStateVersion,
          String? contextCheckpointId,
          int? contextSandboxCount,
          Map<String, dynamic>? contextTierBudget,
          String? contextAuthoritativeInput,
          Map<String, dynamic>? provenanceGraph,
          Map<String, dynamic>? contextDiff,
          int? evidenceCompleteness,
          String? evidenceDebtLevel,
          List<String>? evidenceTags,
          String? memoryStatus,
          String? memoryRecheckAt,
          String? memoryRecheckReason,
          List<Map<String, dynamic>>? observabilityEvents,
          String? failureId,
          String? failureType,
          String? executionEngine,
          String? executionTier,
          bool? fallbackUsed,
          String? doorAddress,
          Map<String, dynamic>? lineageSnapshot,
          String? coordinationId,
          List<String>? coordinationMembers,
          String? deliveryId,
          String? deliveryRecipient,
          String? deliveryStatus,
          List<Map<String, dynamic>>? observations,
          List<Map<String, dynamic>>? findings,
          List<Map<String, dynamic>>? evidence,
          List<String>? activity,
          String? error}) =>
      PresentationState(
          agentId: agentId ?? this.agentId,
          characterState: characterState ?? this.characterState,
          active: active ?? this.active,
          reducedMotion: reducedMotion ?? this.reducedMotion,
          prominence: prominence ?? this.prominence,
          message: message ?? this.message,
          event: event ?? this.event,
          taskId: taskId ?? this.taskId,
          taskState: taskState ?? this.taskState,
          taskSource: taskSource ?? this.taskSource,
          task: task ?? this.task,
          taskDataFields: taskDataFields,
          taskContextFields: taskContextFields,
          taskCreatedAt: taskCreatedAt,
          taskUpdatedAt: taskUpdatedAt,
          foundationId: foundationId ?? this.foundationId,
          foundationMaterialSetId:
              foundationMaterialSetId ?? this.foundationMaterialSetId,
          foundationSourceCount:
              foundationSourceCount ?? this.foundationSourceCount,
          foundationCandidateCount:
              foundationCandidateCount ?? this.foundationCandidateCount,
          foundationConfirmation:
              foundationConfirmation ?? this.foundationConfirmation,
          foundationPreviewQuestion: foundationPreviewQuestion,
          foundationMatchRatio: foundationMatchRatio,
          foundationAutoFill: foundationAutoFill,
          foundationIntentGuesses: foundationIntentGuesses,
          foundationRecipient: foundationRecipient,
          foundationLogCount: foundationLogCount,
          foundationLogEntries: foundationLogEntries,
          foundationConflictFields: foundationConflictFields,
          foundationConditionalProvenance: foundationConditionalProvenance,
          contextId: contextId ?? this.contextId,
          contextDimensions: contextDimensions ?? this.contextDimensions,
          contextMissingDimensions:
              contextMissingDimensions ?? this.contextMissingDimensions,
          contextNormalizationCount: contextNormalizationCount,
          contextBaselineId: contextBaselineId ?? this.contextBaselineId,
          contextBaselineStatus:
              contextBaselineStatus ?? this.contextBaselineStatus,
          contextInterpretationId:
              contextInterpretationId ?? this.contextInterpretationId,
          contextUncertainty: contextUncertainty,
          contextLimitations: contextLimitations,
          contextCompressionRatio:
              contextCompressionRatio ?? this.contextCompressionRatio,
          contextOriginalItemCount:
              contextOriginalItemCount ?? this.contextOriginalItemCount,
          contextRetainedItemCount:
              contextRetainedItemCount ?? this.contextRetainedItemCount,
          contextViolationCount:
              contextViolationCount ?? this.contextViolationCount,
          contextStateVersion: contextStateVersion ?? this.contextStateVersion,
          contextCheckpointId: contextCheckpointId ?? this.contextCheckpointId,
          contextSandboxCount: contextSandboxCount ?? this.contextSandboxCount,
          contextTierBudget: contextTierBudget ?? this.contextTierBudget,
          contextAuthoritativeInput:
              contextAuthoritativeInput ?? this.contextAuthoritativeInput,
          provenanceGraph: provenanceGraph ?? this.provenanceGraph,
          contextDiff: contextDiff ?? this.contextDiff,
          evidenceCompleteness:
              evidenceCompleteness ?? this.evidenceCompleteness,
          evidenceDebtLevel: evidenceDebtLevel ?? this.evidenceDebtLevel,
          evidenceTags: evidenceTags ?? this.evidenceTags,
          memoryStatus: memoryStatus ?? this.memoryStatus,
          memoryRecheckAt: memoryRecheckAt ?? this.memoryRecheckAt,
          memoryRecheckReason: memoryRecheckReason ?? this.memoryRecheckReason,
          observabilityEvents: observabilityEvents ?? this.observabilityEvents,
          failureId: failureId ?? this.failureId,
          failureType: failureType ?? this.failureType,
          executionEngine: executionEngine ?? this.executionEngine,
          executionTier: executionTier ?? this.executionTier,
          fallbackUsed: fallbackUsed ?? this.fallbackUsed,
          doorAddress: doorAddress ?? this.doorAddress,
          lineageSnapshot: lineageSnapshot ?? this.lineageSnapshot,
          coordinationId: coordinationId ?? this.coordinationId,
          coordinationMembers: coordinationMembers ?? this.coordinationMembers,
          deliveryId: deliveryId ?? this.deliveryId,
          deliveryRecipient: deliveryRecipient ?? this.deliveryRecipient,
          deliveryStatus: deliveryStatus ?? this.deliveryStatus,
          observations: observations ?? this.observations,
          findings: findings ?? this.findings,
          evidence: evidence ?? this.evidence,
          activity: activity ?? this.activity,
          error: error ?? this.error);

  factory PresentationState.fromJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>)
      throw const FormatException('Runtime message must be an object.');
    if (decoded['contract_version'] != 1)
      throw const FormatException('Unsupported presentation contract version.');
    final agentId = decoded['character_id'];
    final stateValue = decoded['character_state'];
    final active = decoded['active'];
    final prominence = decoded['prominence'];
    if (agentId is! String ||
        agentId.trim().isEmpty ||
        !CharacterIdentities.all.containsKey(agentId))
      throw const FormatException('Runtime message has an unknown character.');
    if (stateValue is! String ||
        !allowedStates.contains(stateValue.toUpperCase()))
      throw const FormatException('Runtime message has an unsupported state.');
    if (active is! bool ||
        prominence is! num ||
        prominence < 0 ||
        prominence > 1)
      throw const FormatException(
          'Runtime message has invalid character state.');
    List<Map<String, dynamic>> maps(dynamic value) => value is List
        ? value
            .whereType<Map>()
            .map((x) => Map<String, dynamic>.from(x))
            .toList()
        : const [];
    List<String> strings(dynamic value) =>
        value is List ? value.whereType<String>().toList() : const [];
    Map<String, dynamic>? map(dynamic value) =>
        value is Map ? Map<String, dynamic>.from(value) : null;
    int? integer(dynamic value) => value is num ? value.toInt() : null;
    String? optionalString(dynamic value) => value is String ? value : null;
    bool? optionalBool(dynamic value) => value is bool ? value : null;
    double? decimal(dynamic value) => value is num ? value.toDouble() : null;
    return PresentationState(
        agentId: agentId,
        characterState: stateValue.toUpperCase(),
        active: active,
        reducedMotion: decoded['reduced_motion'] == true,
        prominence: prominence.toDouble(),
        message: optionalString(decoded['message']),
        event: optionalString(decoded['event']),
        taskId: optionalString(decoded['task_id']),
        taskState: optionalString(decoded['task_state']),
        taskSource: optionalString(decoded['task_source']),
        task: optionalString(decoded['task']),
        taskDataFields: integer(decoded['task_data_fields']),
        taskContextFields: integer(decoded['task_context_fields']),
        taskCreatedAt: optionalString(decoded['task_created_at']),
        taskUpdatedAt: optionalString(decoded['task_updated_at']),
        foundationId: optionalString(decoded['foundation_id']),
        foundationMaterialSetId:
            optionalString(decoded['foundation_material_set_id']),
        foundationSourceCount: integer(decoded['foundation_source_count']),
        foundationCandidateCount:
            integer(decoded['foundation_candidate_count']),
        foundationConfirmation:
            optionalString(decoded['foundation_confirmation']),
        foundationPreviewQuestion:
            optionalString(decoded['foundation_preview_question']),
        foundationMatchRatio: decimal(decoded['foundation_match_ratio']),
        foundationAutoFill: optionalBool(decoded['foundation_auto_fill']),
        foundationIntentGuesses: strings(decoded['foundation_intent_guesses']),
        foundationRecipient: optionalString(decoded['foundation_recipient']),
        foundationLogCount: integer(decoded['foundation_log_count']),
        foundationLogEntries: strings(decoded['foundation_log_entries']),
        foundationConflictFields:
            strings(decoded['foundation_conflict_fields']),
        foundationConditionalProvenance:
            strings(decoded['foundation_conditional_provenance']),
        contextId: optionalString(decoded['context_id']),
        contextDimensions: strings(decoded['context_dimensions']),
        contextMissingDimensions:
            strings(decoded['context_missing_dimensions']),
        contextNormalizationCount:
            integer(decoded['context_normalization_count']),
        contextBaselineId: optionalString(decoded['context_baseline_id']),
        contextBaselineStatus:
            optionalString(decoded['context_baseline_status']),
        contextInterpretationId:
            optionalString(decoded['context_interpretation_id']),
        contextUncertainty: strings(decoded['context_uncertainty']),
        contextLimitations: strings(decoded['context_limitations']),
        contextCompressionRatio: decimal(decoded['context_compression_ratio']),
        contextOriginalItemCount:
            integer(decoded['context_original_item_count']),
        contextRetainedItemCount:
            integer(decoded['context_retained_item_count']),
        contextViolationCount: integer(decoded['context_violation_count']),
        contextStateVersion: integer(decoded['context_state_version']),
        contextCheckpointId: optionalString(decoded['context_checkpoint_id']),
        contextSandboxCount: integer(decoded['context_sandbox_count']),
        contextTierBudget: map(decoded['context_tier_budget']),
        contextAuthoritativeInput:
            optionalString(decoded['context_authoritative_input']),
        provenanceGraph: map(decoded['provenance_graph']),
        contextDiff: map(decoded['context_diff']),
        evidenceCompleteness: integer(decoded['evidence_completeness']),
        evidenceDebtLevel: optionalString(decoded['evidence_debt_level']),
        evidenceTags: strings(decoded['evidence_tags']),
        memoryStatus: optionalString(decoded['memory_status']),
        memoryRecheckAt: optionalString(decoded['memory_recheck_at']),
        memoryRecheckReason: optionalString(decoded['memory_recheck_reason']),
        observabilityEvents: maps(decoded['observability_events']),
        failureId: optionalString(decoded['failure_id']),
        failureType: optionalString(decoded['failure_type']),
        executionEngine: optionalString(decoded['execution_engine']),
        executionTier: optionalString(decoded['execution_tier']),
        fallbackUsed: optionalBool(decoded['fallback_used']),
        doorAddress: optionalString(decoded['door_address']),
        lineageSnapshot: map(decoded['lineage_snapshot']),
        coordinationId: optionalString(decoded['coordination_id']),
        coordinationMembers: strings(decoded['coordination_members']),
        deliveryId: optionalString(decoded['delivery_id']),
        deliveryRecipient: optionalString(decoded['delivery_recipient']),
        deliveryStatus: optionalString(decoded['delivery_status']),
        observations: maps(decoded['observations']),
        findings: maps(decoded['findings']),
        evidence: maps(decoded['evidence']),
        activity: strings(decoded['activity']),
        error: optionalString(decoded['error']));
  }
  Map<String, dynamic> toJson() => {
        'contract_version': 1,
        'character_id': agentId,
        'character_state': characterState,
        'active': active,
        'reduced_motion': reducedMotion,
        'prominence': prominence,
        'message': message,
        'event': event,
        'task_id': taskId,
        'task_state': taskState,
        'task_source': taskSource,
        'task': task,
        'task_data_fields': taskDataFields,
        'task_context_fields': taskContextFields,
        'task_created_at': taskCreatedAt,
        'task_updated_at': taskUpdatedAt,
        'foundation_id': foundationId,
        'foundation_material_set_id': foundationMaterialSetId,
        'foundation_source_count': foundationSourceCount,
        'foundation_candidate_count': foundationCandidateCount,
        'foundation_confirmation': foundationConfirmation,
        'foundation_preview_question': foundationPreviewQuestion,
        'foundation_match_ratio': foundationMatchRatio,
        'foundation_auto_fill': foundationAutoFill,
        'foundation_intent_guesses': foundationIntentGuesses,
        'foundation_recipient': foundationRecipient,
        'foundation_log_count': foundationLogCount,
        'foundation_log_entries': foundationLogEntries,
        'foundation_conflict_fields': foundationConflictFields,
        'foundation_conditional_provenance': foundationConditionalProvenance,
        'context_id': contextId,
        'context_dimensions': contextDimensions,
        'context_missing_dimensions': contextMissingDimensions,
        'context_normalization_count': contextNormalizationCount,
        'context_baseline_id': contextBaselineId,
        'context_baseline_status': contextBaselineStatus,
        'context_interpretation_id': contextInterpretationId,
        'context_uncertainty': contextUncertainty,
        'context_limitations': contextLimitations,
        'context_compression_ratio': contextCompressionRatio,
        'context_original_item_count': contextOriginalItemCount,
        'context_retained_item_count': contextRetainedItemCount,
        'context_violation_count': contextViolationCount,
        'context_state_version': contextStateVersion,
        'context_checkpoint_id': contextCheckpointId,
        'context_sandbox_count': contextSandboxCount,
        'context_tier_budget': contextTierBudget,
        'context_authoritative_input': contextAuthoritativeInput,
        'provenance_graph': provenanceGraph,
        'context_diff': contextDiff,
        'evidence_completeness': evidenceCompleteness,
        'evidence_debt_level': evidenceDebtLevel,
        'evidence_tags': evidenceTags,
        'memory_status': memoryStatus,
        'memory_recheck_at': memoryRecheckAt,
        'memory_recheck_reason': memoryRecheckReason,
        'observability_events': observabilityEvents,
        'failure_id': failureId,
        'failure_type': failureType,
        'execution_engine': executionEngine,
        'execution_tier': executionTier,
        'fallback_used': fallbackUsed,
        'door_address': doorAddress,
        'lineage_snapshot': lineageSnapshot,
        'coordination_id': coordinationId,
        'coordination_members': coordinationMembers,
        'delivery_id': deliveryId,
        'delivery_recipient': deliveryRecipient,
        'delivery_status': deliveryStatus,
        'observations': observations,
        'findings': findings,
        'evidence': evidence,
        'activity': activity,
        'error': error
      };
}
