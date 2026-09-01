import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/character/character_identity.dart';

void main() {
  test('known character identity resolves correctly', () {
    final identity = CharacterIdentities.resolve('Dharen');

    expect(identity.id, 'Dharen');
    expect(identity.displayName, 'Dharen');
    expect(identity.role, 'Analysis');
  });

  test('all fifteen character identities are registered', () {
    expect(CharacterIdentities.all.length, 15);
  });

  test('unknown character gets a safe fallback identity', () {
    final identity = CharacterIdentities.resolve('UnknownAgent');

    expect(identity.id, 'UnknownAgent');
    expect(identity.displayName, 'UnknownAgent');
    expect(identity.role, 'Criterivox Agent');
  });
}