import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/character_focus_page.dart';
import '../lib/civilization_page.dart';
import '../lib/civilization_home_preview_page.dart';
import '../lib/bloom_companion.dart';
import '../lib/character/character_identity.dart';

void main() {
  testWidgets('Civilization exposes canonical homes and Anukor network territory', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CivilizationPage()));
    expect(find.text('Criterivox Civilization'), findsOneWidget);
    expect(find.text('Anukor · Network Territory'), findsOneWidget);
  });

  testWidgets('Character focus uses canonical character identity', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterFocusPage(characterId: 'vivren', onBack: () {}),
      ),
    );
    expect(find.text('Vivren'), findsOneWidget);
    expect(find.text('Discernment'), findsOneWidget);
    expect(find.textContaining('represents system activity'), findsOneWidget);
  });

  testWidgets('Home preview identifies residents', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CivilizationHomePreviewPage(homeId: 'reasoning', onBack: () {}),
      ),
    );
    expect(find.text('Reasoning House'), findsOneWidget);
    expect(find.text('Vivren'), findsOneWidget);
    expect(find.text('Tarkis'), findsOneWidget);
  });

  testWidgets('Bloom companion is presentation-only and contextual', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BloomCompanion(location: 'level2', characterId: 'vivren'),
      ),
    );
    expect(find.text('Vivren'), findsOneWidget);
    expect(find.textContaining('underlying system work'), findsOneWidget);
  });

  test('canonical identity registry resolves all civilization residents', () {
    const ids = [
      'syvax','sandre','kaelen','dharen','anuka','vivren','tarkis',
      'pramon','bodhex','manis','medrus','epistre','veridat','viveda','anukor',
    ];
    for (final id in ids) {
      expect(CharacterIdentities.resolve(id).id, id);
    }
  });
}
