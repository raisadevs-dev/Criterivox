import 'package:flutter_test/flutter_test.dart';
import 'package:criterivox/Anuka/anuka_presentation.dart';

void main() {
  test('Anuka presentation owns adaptive capabilities', () {
    expect(AnukaPresentation.characterId, 'anuka');
    expect(
      AnukaPresentation.capabilities.map((item) => item.id),
      containsAll(<String>[
        'activation', 'drift', 'state', 'sandbox', 'checkpoint', 'handoff'
      ]),
    );
  });
}
