import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/world_map_level2_part4_page.dart';

void main() {
  testWidgets('Part IV presents canonical quarter surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WorldMapLevel2Part4Page(onBack: () {}),
      ),
    );
    expect(find.text('WORLD MAP • LEVEL 2 PART IV'), findsOneWidget);
    expect(find.text('Intelligence + Decision & Action'), findsOneWidget);
    expect(find.text('INTELLIGENCE • VIVREN + TARKIS'), findsOneWidget);
    expect(find.text('DECISION & ACTION • PRAMON + BODHEX'), findsOneWidget);
  });
}
