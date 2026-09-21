import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/unified_runtime_response.dart';

void main() {
  test('parses authoritative unified runtime envelope', () {
    final value = UnifiedRuntimeResponse.fromJson({
      'character_id': 'epistre',
      'message': 'Provenance is available.',
      'task_id': 'T-1',
      'unified_journey_id': 'J-1',
      'unified_intent': 'SHOW_PROVENANCE',
      'unified_entities': {'character': 'epistre'},
      'unified_capability': 'trace_provenance',
      'unified_responsible_character': 'epistre',
      'unified_authorization': 'NOT_REQUIRED',
      'unified_state_source': 'runtime_checkpoint',
      'unified_workflow_outcome': 'checkpoint_inspected',
      'unified_status': 'RECORDED',
    });
    expect(value.journeyId, 'J-1');
    expect(value.intent, 'SHOW_PROVENANCE');
    expect(value.capability, 'trace_provenance');
    expect(value.responsibleCharacter, 'epistre');
    expect(value.isBoundaryFailure, isFalse);
  });

  test('surfaces unavailable capability without implying execution', () {
    final value = UnifiedRuntimeResponse.fromJson({
      'unified_status': 'CAPABILITY_UNAVAILABLE',
      'unified_workflow_outcome': 'no_state_change',
    });
    expect(value.isBoundaryFailure, isTrue);
    expect(value.workflowOutcome, 'no_state_change');
  });
}
