import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/character/character_runtime_flutter.dart';

void main() {
  const semanticStates = [
    'IDLE',
    'RECEIVE',
    'WORK',
    'COMMUNICATE',
    'HANDOFF',
    'COMPLETE',
    'WARNING',
  ];

  testWidgets(
    'pure Flutter runtime renders all semantic states',
    (tester) async {
      for (final state in semanticStates) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CharacterRuntimeView(
                characterId: 'Dharen',
                state: state,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 120));

        expect(
          find.byType(CharacterRuntimeView),
          findsOneWidget,
          reason: 'Runtime should remain mounted for state $state.',
        );

        expect(
          find.byType(CustomPaint),
          findsWidgets,
          reason: 'Runtime should contain its Flutter painting layer for state $state.',
        );
      }
    },
  );

  testWidgets(
    'reduced motion renders a deterministic frame',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CharacterRuntimeView(
              characterId: 'Anuka',
              state: 'WORK',
              reducedMotion: true,
            ),
          ),
        ),
      );

      expect(
        find.byType(CharacterRuntimeView),
        findsOneWidget,
      );

      expect(
        find.byType(CustomPaint),
        findsWidgets,
      );

      await tester.pump(const Duration(seconds: 1));

      expect(
        find.byType(CharacterRuntimeView),
        findsOneWidget,
      );

      expect(
        find.byType(CustomPaint),
        findsWidgets,
      );
    },
  );
}