
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/civilization_home_preview_page.dart';
import 'package:presentation/civilization_page.dart';
import 'package:presentation/foundation/criterivox_responsive_scene.dart';

void main() {
  test('Gate 1 defines the canonical seven fixed Homes', () {
    expect(CivilizationPage.canonicalHomes.length, 7);

    expect(
      CivilizationPage.homes.any((home) => home.id == 'gateway'),
      isTrue,
    );

    expect(
      CivilizationPage.homes.any((home) => home.id == 'evidence'),
      isTrue,
    );

    expect(
      CivilizationPage.homes.any((home) => home.id == 'knowledge'),
      isTrue,
    );
  });

  test('Anukor remains a network resident rather than a fixed Home', () {
    expect(
      CivilizationPage.homes.every(
        (home) => !home.residents.contains('anukor'),
      ),
      isTrue,
    );
  });

  test('responsive civilization keeps information available on compact view', () {
    final mobile = const CriterivoxResponsive(480);
    final tablet = const CriterivoxResponsive(1024);
    final desktop = const CriterivoxResponsive(1280);

    expect(mobile.isCompact, isTrue);
    expect(mobile.informationColumns, equals(1));

    expect(tablet.isTablet, isTrue);
    expect(tablet.informationColumns, equals(1));

    expect(desktop.isDesktop, isTrue);
    expect(desktop.informationColumns, equals(2));
  });

  testWidgets(
    'Home preview is explicitly a Gate 1 read-model boundary',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CivilizationHomePreviewPage(
            homeId: 'reasoning',
            onBack: _noop,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Reasoning House'), findsOneWidget);
      expect(
        find.text('GATE 1 · HOME ENTRY'),
        findsOneWidget,
      );
      expect(
        find.text('operational rooms deferred'),
        findsOneWidget,
      );
      expect(
        find.text('ROOM PREVIEW'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Level 1 Home-entry/read-model boundary',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Room operations are intentionally deferred',
        ),
        findsOneWidget,
      );
    },
  );
}

void _noop() {}
