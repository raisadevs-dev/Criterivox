import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:presentation/civilization_home_preview_page.dart';
import 'package:presentation/civilization_page.dart';
import 'package:presentation/foundation/criterivox_responsive_scene.dart';

void main() {
  test('Gate 1 defines the canonical seven fixed Homes', () {
    expect(CivilizationPage.canonicalHomes.length, 7);
    expect(CivilizationPage.homes.any((h) => h.id == 'gateway'), isTrue);
    expect(CivilizationPage.homes.any((h) => h.id == 'evidence'), isTrue);
    expect(CivilizationPage.homes.any((h) => h.id == 'knowledge'), isTrue);
  });

  test('Anukor remains a network resident rather than a fixed Home', () {
    expect(CivilizationPage.homes.every((h) => !h.residents.contains('anukor')), isTrue);
  });

  test('responsive civilization keeps information available on compact view', () {
    expect(const CriterivoxResponsive(480).isCompact, isTrue);
    expect(const CriterivoxResponsive(1024).isTablet, isTrue);
    expect(const CriterivoxResponsive(1024).informationColumns, equals(2));
  });

  testWidgets('Home preview is explicitly a Gate 1 read-model boundary', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CivilizationHomePreviewPage(
        homeId: 'reasoning',
        onBack: _noop,
      ),
    ));
    expect(find.text('Reasoning House'), findsOneWidget);
    expect(find.text('GATE 1 · HOME ENTRY'), findsOneWidget);
    expect(find.text('operational rooms deferred'), findsOneWidget);
    expect(find.text('ROOM PREVIEW'), findsOneWidget);
  });
}

void _noop() {}
