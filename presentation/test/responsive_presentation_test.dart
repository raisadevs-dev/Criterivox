import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/presentation_state.dart';
import 'package:presentation/presentation/responsive_presentation.dart';

void main() {
  test('small screens use compact scale', () {
    const presentation = ResponsivePresentation();

    expect(presentation.scaleForWidth(400), 0.85);
    expect(presentation.isCompact(400), true);
    expect(presentation.isExpanded(400), false);
  });

  test('medium screens use standard scale', () {
    const presentation = ResponsivePresentation();

    expect(presentation.scaleForWidth(800), 1.0);
    expect(presentation.isCompact(800), false);
    expect(presentation.isExpanded(800), false);
  });

  test('large screens use expanded scale', () {
    const presentation = ResponsivePresentation();

    expect(presentation.scaleForWidth(1200), 1.15);
    expect(presentation.isCompact(1200), false);
    expect(presentation.isExpanded(1200), true);
  });

  test('responsive adaptation preserves presentation state', () {
    const state = PresentationState(
      agentId: 'dharen',
      characterState: 'WORK',
      active: true,
    );

    const presentation = ResponsivePresentation();

    final result = presentation.preserveState(state);

    expect(result.agentId, 'dharen');
    expect(result.characterState, 'WORK');
    expect(result.active, true);
    expect(result.reducedMotion, false);
  });
}