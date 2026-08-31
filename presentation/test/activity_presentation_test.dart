import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/activity_presentation.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  test('quiet state becomes inactive and idle', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'COMPLETE',
      active: true,
    );

    const presentation = ActivityPresentation();

    final result = presentation.quiet(state);

    expect(result.active, false);
    expect(result.characterState, 'IDLE');
    expect(presentation.isQuiet(result), true);
  });

  test('active state is recognized', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
    );

    const presentation = ActivityPresentation();

    expect(presentation.isActive(state), true);
    expect(presentation.isQuiet(state), false);
  });
}