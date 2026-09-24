import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/character_focus_page.dart';
import '../lib/civilization_page.dart';
import '../lib/civilization_home_preview_page.dart';
import '../lib/bloom_companion.dart';
import '../lib/character/character_identity.dart';
import '../lib/level2_operational_page.dart';

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

  testWidgets('Civilization exposes semantic relationship and registry visuals', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CivilizationPage()));
    expect(find.text('Cross-home relationship network'), findsOneWidget);
    expect(find.text('Civilization home registry'), findsOneWidget);
    expect(find.text('Inspection path'), findsOneWidget);
  });

  testWidgets('Level 2 exposes semantic visual forms for each home', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Level2OperationalPage(homeId: 'evidence', onBack: () {})));
    expect(find.text('Evidence chain'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(home: Level2OperationalPage(homeId: 'decision', onBack: () {})));
    expect(find.text('Decision structure'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(home: Level2OperationalPage(homeId: 'context', onBack: () {})));
    expect(find.text('Context inspection sequence'), findsOneWidget);
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
