import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/character/session_character_animation.dart';
import 'package:presentation/character/character_visual_profile.dart';

void main() {
  test('all canonical character profiles are animation-capable', () {
    for (final id in CharacterVisualProfile.registry.keys) {
      expect(SessionCharacterAnimation.supports(id), isTrue);
    }
  });

  test('profiles are deterministic within a session and character-specific',
      () {
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
