import 'package:flutter_test/flutter_test.dart';
import 'package:criterivox/Dharen/dharen_presentation.dart';

void main() {
  test('Dharen presentation owns context capabilities', () {
    expect(DharenPresentation.characterId, 'dharen');
    expect(
      DharenPresentation.capabilities.map((item) => item.id),
      containsAll(<String>[
        'framing', 'scope', 'firewall', 'budget', 'handoff', 'checkpoint'
      ]),
    );
  });
}
