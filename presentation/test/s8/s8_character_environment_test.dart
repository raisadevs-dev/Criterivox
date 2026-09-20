import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_character_presentation.dart';
import 'package:presentation/s8_evidence_bureau_page.dart';

void main() {
  testWidgets(
    'character tap opens inspectable profile card',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: S8EvidenceBureauPage(),
        ),
      );

      await tester.tap(find.text('Medrus').first);
      await tester.pumpAndSettle();

      expect(find.text('MEDRUS'), findsWidgets);
      expect(find.text('PERSONALITY'), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(
        find.textContaining('Grab and move this profile card'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'home renders the current S8 character presentation layer',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: S8EvidenceBureauPage(),
        ),
      );

      expect(
        find.byType(S8CharacterPresentation),
        findsNWidgets(3),
      );

      expect(find.text('Medrus'), findsWidgets);
      expect(find.text('Epistre'), findsWidgets);
      expect(find.text('Veridat'), findsWidgets);
    },
  );

  testWidgets(
    'each specialist room keeps its current character presentation',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: S8EvidenceBureauPage(),
        ),
      );

      final rooms = <String>[
        'Medrus',
        'Epistre',
        'Veridat',
        'Presentation',
      ];

      for (final room in rooms) {
        await tester.tap(find.text(room).first);
        await tester.pumpAndSettle();

        expect(
          find.byType(S8CharacterPresentation),
          findsOneWidget,
          reason: 'Expected one active character presentation in $room room.',
        );
      }
    },
  );

  testWidgets(
    'presentation room can be opened from the S8 home',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: S8EvidenceBureauPage(),
        ),
      );

      await tester.tap(find.text('Open Challenge Arena'));
      await tester.pumpAndSettle();

      expect(find.text('Human interaction loop'), findsOneWidget);
      expect(
        find.textContaining('Inspect → trace → question'),
        findsOneWidget,
      );
    },
  );
}