import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/character/character_identity.dart';

void main() {
  test('stable character ids remain separate from human-facing names', () {
    final identity = CharacterIdentities.resolve('viveda');

    expect(identity.id, 'viveda');
    expect(identity.displayName, 'Viveda');
    expect(identity.nameFor('en'), 'Viveda');
    expect(identity.nameFor('hi'), isNotEmpty);
  });

  test('unknown character ids remain stable for runtime routing', () {
    final identity = CharacterIdentities.resolve('runtime_only_character');

    expect(identity.id, 'runtime_only_character');
    expect(identity.displayName, 'runtime_only_character');
  });
}
