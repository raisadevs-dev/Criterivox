import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:presentation/main.dart';

void main() {
  testWidgets(
    'Criterivox presentation renders the runtime character shell',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CriterivoxApp());

      expect(find.text('Criterivox'), findsOneWidget);
      expect(find.text('Runtime Character Interaction'), findsOneWidget);
      expect(find.text('Synthetic data (JSON object)'), findsOneWidget);
      expect(find.text('Synthetic context (JSON object)'), findsOneWidget);
      expect(find.text('Task'), findsOneWidget);
      expect(find.text('Send analysis request to Python'), findsOneWidget);
      expect(
        find.textContaining('Waiting for the Python runtime connection'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Criterivox presentation exposes the runtime analysis action',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CriterivoxApp());

      final button = find.widgetWithText(
        FilledButton,
        'Send analysis request to Python',
      );
      expect(button, findsOneWidget);
    },
  );

  testWidgets(
    'Criterivox presentation provides accessible runtime status',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CriterivoxApp());

      expect(find.bySemanticsLabel('Dharen status'), findsNothing);
      expect(find.bySemanticsLabel('Runtime error'), findsNothing);
    },
  );
}
