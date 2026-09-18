import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app_shell.dart';

void main() {
  testWidgets(
    'global character chat uses one toggle and preserves chat page state',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(
            connectRuntime: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byTooltip('Open character chat'), findsOneWidget);
      expect(find.text('Chat with Dharen'), findsNothing);

      await tester.tap(find.byTooltip('Open character chat'));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byTooltip('Close character chat'), findsOneWidget);
      expect(find.text('Chat with Dharen'), findsOneWidget);

      final input = find.byHintText('Message Dharen…');
      expect(input, findsOneWidget);
      await tester.enterText(input, 'Preserve this draft.');
      expect(find.text('Preserve this draft.'), findsOneWidget);

      await tester.tap(find.byTooltip('Close character chat'));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byTooltip('Open character chat'), findsOneWidget);
      expect(find.text('Chat with Dharen'), findsNothing);

      await tester.tap(find.byTooltip('Open character chat'));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byTooltip('Close character chat'), findsOneWidget);
      expect(find.text('Chat with Dharen'), findsOneWidget);
      expect(find.text('Preserve this draft.'), findsOneWidget);
    },
  );

  testWidgets(
    'global character chat launcher remains available from the civilization surface',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(
            connectRuntime: false,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Civilization').first);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byTooltip('Open character chat'), findsOneWidget);
      expect(find.text('Criterivox Civilization'), findsOneWidget);

      await tester.tap(find.byTooltip('Open character chat'));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byTooltip('Close character chat'), findsOneWidget);
      expect(find.text('Chat with Dharen'), findsOneWidget);
    },
  );
}
