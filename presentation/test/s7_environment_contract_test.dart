import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s7/s7_environment_page.dart';

void main() {
  testWidgets(
    'S7 exposes exactly three workspaces and no S7 Home',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: S7EnvironmentPage(),
        ),
      );

      expect(
        find.textContaining('COLLABORATION ROOM'),
        findsOneWidget,
      );

      expect(
        find.textContaining('CRITICAL INTELLIGENCE CHAMBER'),
        findsOneWidget,
      );

      expect(
        find.textContaining('HYPOTHESIS EXPLORATION CHAMBER'),
        findsOneWidget,
      );

      expect(
        find.textContaining('S7 HOME'),
        findsNothing,
      );

      expect(
        find.text('REASONING RESEARCH BUREAU'),
        findsOneWidget,
      );
    },
  );
}