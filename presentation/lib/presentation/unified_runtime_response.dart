class UnifiedRuntimeResponse {
  final String? characterId, message, event, taskId, journeyId, intent, target, requestedOutput, source, capability, responsibleCharacter, authorization, stateSource, workflowOutcome, status, detectedLanguage, responseLanguage;
  final Map<String, dynamic> entities;
  final double? confidence;
  const UnifiedRuntimeResponse({this.characterId,this.message,this.event,this.taskId,this.journeyId,this.intent,this.entities=const {},this.target,this.requestedOutput,this.confidence,this.source,this.capability,this.responsibleCharacter,this.authorization,this.stateSource,this.workflowOutcome,this.status,this.detectedLanguage,this.responseLanguage});
  factory UnifiedRuntimeResponse.fromJson(Map<String,dynamic> j)=>UnifiedRuntimeResponse(
    characterId:j['character_id'] as String?,message:j['message'] as String?,event:j['event'] as String?,taskId:j['task_id'] as String?,
    journeyId:j['unified_journey_id'] as String?,intent:j['unified_intent'] as String?,entities:Map<String,dynamic>.from(j['unified_entities'] as Map? ?? const {}),
    target:j['unified_target'] as String?,requestedOutput:j['unified_requested_output'] as String?,confidence:(j['unified_confidence'] as num?)?.toDouble(),
    source:j['unified_source'] as String?,capability:j['unified_capability'] as String?,responsibleCharacter:j['unified_responsible_character'] as String?,
    authorization:j['unified_authorization'] as String?,stateSource:j['unified_state_source'] as String?,workflowOutcome:j['unified_workflow_outcome'] as String?,status:j['unified_status'] as String?,detectedLanguage:j['unified_detected_language'] as String?,responseLanguage:j['unified_response_language'] as String?);
  bool get isBoundaryFailure=>status=='CAPABILITY_UNAVAILABLE'||status=='CLARIFICATION_REQUIRED'||status=='NO_AUTHORITATIVE_RECORD';
}