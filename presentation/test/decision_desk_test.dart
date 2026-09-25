import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/decision_desk_page.dart';

void main() {
  testWidgets('Decision Desk accepts ordinary-language situations', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DecisionDeskPage()),
    );
    await tester.pump();
    expect(find.text('DECISION DESK'), findsOneWidget);
    expect(find.text('WHAT IS HAPPENING?'), findsOneWidget);
    expect(find.text('Describe the situation or question'), findsOneWidget);
    expect(find.text('Help me think this through'), findsOneWidget);
  });
}
