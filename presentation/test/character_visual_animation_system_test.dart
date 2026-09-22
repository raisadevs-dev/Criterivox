import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/character/character_visual_profile.dart';
import 'package:presentation/character/generated_vector_animation.dart';
import 'package:presentation/character/session_character_animation.dart';

void main() {
  test('all fifteen specialists have complete visual profiles', () {
    const expected = <String>{
      'dharen',
      'vivren',
      'tarkis',
      'sandre',
      'pramon',
      'syvax',
      'bodhex',
      'manis',
      'anuka',
      'viveda',
      'kaelen',
      'anukor',
      'medrus',
      'epistre',
      'veridat',
    };

    expect(SessionCharacterAnimation.activeCharacters, expected);
    for (final id in expected) {
      final profile = CharacterVisualProfile.forId(id);
      expect(profile, isNotNull);
      expect(profile!.accent.value, isNot(0));
    }
  });

  test('specialists do not fall back to one shared visual signature', () {
    final profiles = SessionCharacterAnimation.activeCharacters
        .map((id) => CharacterVisualProfile.forId(id)!)
        .toList();

    final signatures = profiles
        .map((p) => [
              p.body.value,
              p.hair.value,
              p.accent.value,
              p.hairStyle.name,
              p.clothing.name,
              p.accessory.name,
            ].join(':'))
        .toSet();

    expect(signatures.length, 15);
  });

  test('session animation is character-specific and session stable', () {
    final a = SessionCharacterAnimation.profileFor('syvax');
    final b = SessionCharacterAnimation.profileFor('syvax');
    final c = SessionCharacterAnimation.profileFor('anuka');
    expect(a.duration, b.duration);
    expect(a.phase, b.phase);
    expect(a.phase, isNot(c.phase));
  });

  test('vector generator emits valid SVG frames for every current character',
      () {
    for (final id in SessionCharacterAnimation.activeCharacters) {
      final profile = CharacterVisualProfile.forId(id)!;
      final generator = GeneratedVectorAnimation(
        profile: profile,
        sessionSeed: SessionCharacterAnimation.sessionSeed,
      );
      final svg = generator.svgFrame(state: 'WORK', frame: 3, frameCount: 8);
      expect(svg, startsWith('<svg '));
      expect(svg, contains('#'));
      expect(svg, contains('viewBox="0 0 238 286"'));
    }
  });
}
