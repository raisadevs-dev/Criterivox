import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/bloom_presentation.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  test('opening Bloom activates presentation', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'IDLE',
      active: false,
    );

    const presentation = BloomPresentation();

    final result = presentation.open(state);

    expect(result.active, true);
    expect(presentation.isOpen(result), true);
  });

  test('closing Bloom deactivates presentation', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'IDLE',
      active: true,
    );

    const presentation = BloomPresentation();

    final result = presentation.close(state);

    expect(result.active, false);
    expect(presentation.isOpen(result), false);
  });
}