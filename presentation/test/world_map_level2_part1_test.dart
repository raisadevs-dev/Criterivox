import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/world_map_level2_part1_page.dart';

void main() {
  testWidgets('Level 2 Part-I exposes supervision control plane', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WorldMapLevel2Part1Page(onBack: _noop),
    ));
    await tester.pumpAndSettle();
    expect(find.text('LEVEL 2 · PART I'), findsOneWidget);
    expect(find.text('Supervision Briefing Control Plane'), findsOneWidget);
    expect(find.text('SPATIAL ROSTER · ALL 15 RESIDENTS'), findsOneWidget);
    expect(find.text('ANUKOR · NETWORK INSPECTION'), findsOneWidget);
    expect(find.text('GATE 2 · GUEST PASS BOUNDARY'), findsOneWidget);
  });
}

void _noop() {}
