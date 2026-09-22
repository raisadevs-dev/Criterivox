
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

      final openChat = find.byTooltip(
        'Open character chat',
      );

      expect(
        openChat,
        findsOneWidget,
      );

      await tester.tap(openChat);

      await _pumpUntil(
        tester,
        () => find.byTooltip(
          'Close character chat',
        ),
      );

      expect(
        find.byTooltip('Close character chat'),
        findsOneWidget,
      );

      // The global overlay is not allowed to coexist with the dedicated
      // CharacterChatPage route. The route remains the single canonical
      // dedicated chat surface.
      await tester.tap(
        find.text('Character Chat', findRichText: false).first,
      );

      await _pumpUntil(
        tester,
        () => find.byKey(const ValueKey('chat')),
      );

      expect(
        find.byKey(const ValueKey('chat')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('global-character-chat')),
        findsNothing,
      );

      final globalChat = find.byKey(
        const ValueKey('global-character-chat'),
      );

      expect(
        globalChat,
        findsOneWidget,
      );

      final chatInput = find.descendant(
        of: globalChat,
        matching: find.byType(TextField),
      );

      expect(
        chatInput,
        findsOneWidget,
      );

      await tester.enterText(
        chatInput,
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

      // The CharacterChatPage remains mounted while the
      // overlay is hidden, so the draft must remain intact.
      expect(
        find.text('Preserve this draft.'),
        findsOneWidget,
      );

      await tester.tap(
        find.byTooltip('Open character chat'),
      );

      await _pumpUntil(
        tester,
        () => find.byTooltip(
          'Close character chat',
        ),
      );

      expect(
        find.byTooltip('Close character chat'),
        findsOneWidget,
      );

      final reopenedGlobalChat = find.byKey(
        const ValueKey('global-character-chat'),
      );

      expect(
        reopenedGlobalChat,
        findsOneWidget,
      );

      final reopenedInput = find.descendant(
        of: reopenedGlobalChat,
        matching: find.byType(TextField),
      );

      expect(
        reopenedInput,
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

      final civilizationGateway = find.text(
        'Civilization · Gate 1',
        findRichText: false,
      );

      expect(
        civilizationGateway,
        findsOneWidget,
      );

      await tester.tap(civilizationGateway);

      final civilizationPage = find.byKey(
        const ValueKey('civilization'),
      );

      await _pumpUntil(
        tester,
        () => civilizationPage,
      );

      expect(
        civilizationPage,
        findsOneWidget,
      );

      expect(
        find.text(
          'GATE 1 · CRITERIVOX CIVILIZATION',
          findRichText: false,
        ),
        findsOneWidget,
      );

      // Global Chat is an application-level capability.
      // Entering Civilization must not remove it.
      // The dedicated chat route owns the canonical chat page.
      // The global overlay must not mount a second chat surface over it.
      expect(
        find.byTooltip('Open character chat'),
        findsOneWidget,
      );

      await tester.tap(
        find.byTooltip('Open character chat'),
      );

      await _pumpUntil(
        tester,
        () => find.byTooltip(
          'Close character chat',
        ),
      );

      expect(
        find.byTooltip('Close character chat'),
        findsOneWidget,
      );

      final globalChat = find.byKey(
        const ValueKey('global-character-chat'),
      );

      expect(
        globalChat,
        findsOneWidget,
      );

      final chatInput = find.descendant(
        of: globalChat,
        matching: find.byType(TextField),
      );

      expect(
        chatInput,
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder Function() finder, {
  Duration timeout = const Duration(seconds: 4),
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
