import 'package:flutter_test/flutter_test.dart';

import 'package:presentation/main.dart';

void main() {
  testWidgets(
    'Criterivox presentation renders the first functional character',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CriterivoxApp());

      expect(find.text('Criterivox'), findsOneWidget);
      expect(find.text('Character Interaction'), findsOneWidget);
      expect(find.text('Dharen'), findsOneWidget);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('IDLE'), findsOneWidget);
    },
  );

  testWidgets(
    'Criterivox presentation changes character state',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CriterivoxApp());

      expect(find.text('IDLE'), findsOneWidget);

      await tester.tap(find.text('WORK'));
      await tester.pump();

      expect(find.text('WORK'), findsOneWidget);
    },
  );

  testWidgets(
    'Criterivox presentation supports quiet state',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CriterivoxApp());

      await tester.tap(find.text('QUIET'));
      await tester.pump();

      expect(find.text('IDLE'), findsOneWidget);
    },
  );
}