
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app_shell.dart';

void main() {
  testWidgets(
    'global character chat uses one toggle and preserves chat page state',
    (tester) async {
      await tester.binding.setSurfaceSize(
        const Size(1280, 900),
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(
            connectRuntime: false,
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byTooltip('Open character chat'),
        findsOneWidget,
      );

      expect(
        find.text('Chat with Dharen'),
        findsNothing,
      );

      await tester.tap(
        find.byTooltip('Open character chat'),
      );

      await _pumpUntil(
        tester,
        () => find.text('Chat with Dharen'),
      );

      expect(
        find.byTooltip('Close character chat'),
        findsOneWidget,
      );

      expect(
        find.text('Chat with Dharen'),
        findsOneWidget,
      );

      final input = find.byWidgetPredicate(
        (widget) =>
        widget is TextField &&
        widget.decoration?.hintText == 'Message Dharen…',
      );

      expect(input, findsOneWidget);

      await tester.enterText(
        input,
        'Preserve this draft.',
      );

      expect(
        find.text('Preserve this draft.'),
        findsOneWidget,
      );

      await tester.tap(
        find.byTooltip('Close character chat'),
      );

      await tester.pump(
        const Duration(milliseconds: 300),
      );

      expect(
        find.byTooltip('Open character chat'),
        findsOneWidget,
      );

      expect(
        find.text('Chat with Dharen'),
        findsNothing,
      );

      await tester.tap(
        find.byTooltip('Open character chat'),
      );

      await _pumpUntil(
        tester,
        () => find.text('Chat with Dharen'),
      );

      expect(
        find.byTooltip('Close character chat'),
        findsOneWidget,
      );

      expect(
        find.text('Chat with Dharen'),
        findsOneWidget,
      );

      expect(
        find.text('Preserve this draft.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'global character chat launcher remains available from the civilization surface',
    (tester) async {
      await tester.binding.setSurfaceSize(
        const Size(1280, 900),
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(
            connectRuntime: false,
          ),
        ),
      );

      await tester.pump();

      final civilization = find.text(
        'Civilization · Gate 1',
      );

      expect(
        civilization,
        findsOneWidget,
      );

      await tester.tap(civilization);

      await tester.pump(
        const Duration(milliseconds: 350),
      );

      expect(
        find.text('Criterivox Civilization'),
        findsOneWidget,
      );

      expect(
        find.byTooltip('Open character chat'),
        findsOneWidget,
      );

      await tester.tap(
        find.byTooltip('Open character chat'),
      );

      await _pumpUntil(
        tester,
        () => find.text('Chat with Dharen'),
      );

      expect(
        find.byTooltip('Close character chat'),
        findsOneWidget,
      );

      expect(
        find.text('Chat with Dharen'),
        findsOneWidget,
      );

      expect(
        find.byTooltip('Open character chat'),
        findsNothing,
      );
    },
  );
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder Function() finder, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    if (finder().evaluate().isNotEmpty) {
      return;
    }

    await tester.pump(
      const Duration(milliseconds: 50),
    );
  }

  expect(
    finder(),
    findsOneWidget,
  );
}
