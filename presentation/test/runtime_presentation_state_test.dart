import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  test('decodes a Python presentation contract', () {
    const raw = '''{
      "contract_version": 1,
      "character_id": "Dharen",
      "character_state": "work",
      "animation": "work",
      "active": true,
      "prominence": 0.75,
      "reduced_motion": false,
      "message": "Dharen is working.",
      "event": "ANALYSIS_STARTED"
    }''';

    final state = PresentationState.fromJson(raw);

    expect(state.agentId, 'Dharen');
    expect(state.characterState, 'WORK');
    expect(state.active, isTrue);
    expect(state.prominence, 0.75);
    expect(state.message, 'Dharen is working.');
    expect(state.event, 'ANALYSIS_STARTED');
  });

  test('rejects an unsupported contract version', () {
    expect(
      () => PresentationState.fromJson('''{
        "contract_version": 2,
        "character_id": "Dharen",
        "character_state": "work",
        "active": true,
        "prominence": 0.75
      }'''),
      throwsFormatException,
    );
  });

  test('rejects an unsupported character state', () {
    expect(
      () => PresentationState.fromJson('''{
        "contract_version": 1,
        "character_id": "Dharen",
        "character_state": "unknown",
        "active": true,
        "prominence": 0.75
      }'''),
      throwsFormatException,
    );
  });
}
