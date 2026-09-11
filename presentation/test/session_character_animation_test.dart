import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/character/session_character_animation.dart';

void main() {
  test('current sprint characters are registered', () {
    expect(SessionCharacterAnimation.supports('anuka'), isTrue);
    expect(SessionCharacterAnimation.supports('dharen'), isTrue);
    expect(SessionCharacterAnimation.supports('kaelen'), isTrue);
    expect(SessionCharacterAnimation.supports('sandre'), isTrue);
    expect(SessionCharacterAnimation.supports('syvax'), isTrue);
    expect(SessionCharacterAnimation.supports('vivren'), isFalse);
  });

  test('profiles are deterministic within a session and character-specific', () {
    final first = SessionCharacterAnimation.profileFor('syvax');
    final second = SessionCharacterAnimation.profileFor('syvax');
    final other = SessionCharacterAnimation.profileFor('anuka');

    expect(first.duration, second.duration);
    expect(first.phase, second.phase);
    expect(first.sway, second.sway);
    expect(first.lift, second.lift);
    expect(first.emphasis, second.emphasis);
    expect(first.direction, second.direction);

    expect(
      first.duration != other.duration ||
          first.phase != other.phase ||
          first.sway != other.sway ||
          first.lift != other.lift,
      isTrue,
    );
  });
}
