import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/character/character_presentation.dart';
import 'package:presentation/presentation/presentation_state.dart';

void main() {
  Future<void> pumpCharacter(
    WidgetTester tester,
    String state,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterPresentation(
            state: PresentationState(
              agentId: 'Dharen',
              characterState: state,
              active: true,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets(
    'WORK state renders correctly',
    (WidgetTester tester) async {
      await pumpCharacter(tester, 'WORK');

      expect(find.text('Dharen'), findsOneWidget);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('WORK'), findsOneWidget);
    },
  );

  testWidgets(
    'COMMUNICATE state renders correctly',
    (WidgetTester tester) async {
      await pumpCharacter(tester, 'COMMUNICATE');

      expect(find.text('COMMUNICATE'), findsOneWidget);
    },
  );

  testWidgets(
    'HANDOFF state renders correctly',
    (WidgetTester tester) async {
      await pumpCharacter(tester, 'HANDOFF');

      expect(find.text('HANDOFF'), findsOneWidget);
    },
  );

  testWidgets(
    'COMPLETE state renders correctly',
    (WidgetTester tester) async {
      await pumpCharacter(tester, 'COMPLETE');

      expect(find.text('COMPLETE'), findsOneWidget);
    },
  );

  testWidgets(
    'WARNING state renders correctly',
    (WidgetTester tester) async {
      await pumpCharacter(tester, 'WARNING');

      expect(find.text('WARNING'), findsOneWidget);
    },
  );

  testWidgets(
    'all behavioral states remain renderable',
    (WidgetTester tester) async {
      const states = [
        'IDLE',
        'RECEIVE',
        'WORK',
        'COMMUNICATE',
        'HANDOFF',
        'COMPLETE',
        'WARNING',
      ];

      for (final state in states) {
        await pumpCharacter(tester, state);

        expect(
          find.text(state),
          findsOneWidget,
          reason: 'State $state was not rendered.',
        );
      }
    },
  );
}