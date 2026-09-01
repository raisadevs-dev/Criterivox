import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:presentation/character/character_presentation.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  testWidgets(
    'character presentation renders identity and idle state',
    (WidgetTester tester) async {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'IDLE',
        active: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CharacterPresentation(
              state: state,
            ),
          ),
        ),
      );

      expect(find.text('Dharen'), findsOneWidget);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('IDLE'), findsOneWidget);
    },
  );

  testWidgets(
    'character presentation renders Vivren identity',
    (WidgetTester tester) async {
      const state = PresentationState(
        agentId: 'Vivren',
        characterState: 'IDLE',
        active: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CharacterPresentation(
              state: state,
            ),
          ),
        ),
      );

      expect(find.text('Vivren'), findsOneWidget);
      expect(find.text('Context'), findsOneWidget);
      expect(find.text('IDLE'), findsOneWidget);
    },
  );

  testWidgets(
    'inactive character still renders',
    (WidgetTester tester) async {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'IDLE',
        active: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CharacterPresentation(
              state: state,
            ),
          ),
        ),
      );

      expect(find.text('Dharen'), findsOneWidget);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('IDLE'), findsOneWidget);
    },
  );

  testWidgets(
    'reduced motion still renders character',
    (WidgetTester tester) async {
      const state = PresentationState(
        agentId: 'Dharen',
        characterState: 'IDLE',
        active: true,
        reducedMotion: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CharacterPresentation(
              state: state,
            ),
          ),
        ),
      );

      expect(find.text('Dharen'), findsOneWidget);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('IDLE'), findsOneWidget);
    },
  );
}