import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/character/character_runtime_flutter.dart';

void main() {
  testWidgets('pure Flutter runtime renders all semantic states', (tester) async {
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
      expect(find.byType(CustomPaint), findsOneWidget);
    }
  });

  testWidgets('reduced motion renders a deterministic frame', (tester) async {
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

    expect(find.byType(CustomPaint), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CustomPaint), findsOneWidget);
  });
}
