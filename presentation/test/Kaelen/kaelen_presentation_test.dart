import 'package:flutter_test/flutter_test.dart';

import 'package:criterivox/Kaelen/kaelen_presentation.dart';

void main() {
  test('Kaelen presentation owns build capabilities', () {
    expect(KaelenPresentation.characterId, 'kaelen');
    expect(
      KaelenPresentation.capabilities.map((item) => item.id),
      containsAll(<String>[
        'pipeline',
        'schema_drift',
        'streaming',
        'vector',
        'vector_package',
        'experimentation',
      ]),
    );
  });

  test('Kaelen chat prompts are build-specific', () {
    expect(
      KaelenPresentation.chatPrompts,
      contains('Inspect schema drift.'),
    );
    expect(
      KaelenPresentation.chatPrompts,
      contains('Prepare a normalized handoff.'),
    );
  });
}
