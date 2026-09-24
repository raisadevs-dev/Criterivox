import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/character/character_identity.dart';
import 'package:presentation/character/character_visual_profile.dart';

void main() {
  test('current character registry exposes all 15 specialists', () {
    expect(CharacterIdentities.all.keys.length, 15);
    expect(CharacterVisualProfile.registry.keys.length, 15);

    const expected = <String>{
      'syvax',
      'dharen',
      'sandre',
      'kaelen',
      'anuka',
      'vivren',
      'tarkis',
      'pramon',
      'bodhex',
      'medrus',
      'epistre',
      'veridat',
      'manis',
      'viveda',
      'anukor',
    };

    expect(CharacterIdentities.all.keys, containsAll(expected));
    expect(CharacterVisualProfile.registry.keys, containsAll(expected));
  });
}
