import 'package:flutter_test/flutter_test.dart';
import 'package:criterivox/Syvax/syvax_presentation.dart';

void main() {
  test('Syvax owns gateway presentation capabilities', () {
    expect(SyvaxPresentation.characterId, 'syvax');
    expect(SyvaxPresentation.capabilities.map((x) => x.id),
        containsAll(['preflight', 'intent', 'routing', 'oversight', 'rendering', 'trace']));
  });
}
