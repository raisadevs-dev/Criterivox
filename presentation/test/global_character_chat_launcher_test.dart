import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app_shell.dart';

void main() {
  testWidgets(
    'global character chat uses one toggle and preserves chat page state',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(connectRuntime: false),
        ),
      );
      await tester.pump();

      final openChat = find.byKey(const ValueKey('global-character-chat-launcher'));
      expect(openChat, findsOneWidget);

      final openButton = tester.widget<FloatingActionButton>(openChat);
      openButton.onPressed!();
      await tester.pump();
      await _pumpUntil(
        tester,
        () => find.byKey(const ValueKey('global-character-chat-launcher')),
      );

      final globalChat = find.byKey(
        const ValueKey('global-character-chat'),
      );
      final chatInput = find.descendant(
        of: globalChat,
        matching: find.byType(TextField),
      );

      expect(find.byKey(const ValueKey('global-character-chat-launcher')), findsOneWidget);
      expect(globalChat, findsOneWidget);
      expect(chatInput, findsOneWidget);

      await tester.enterText(chatInput, 'Preserve this draft.');
      expect(find.text('Preserve this draft.'), findsOneWidget);

      final closeFinder = find.byKey(const ValueKey('global-character-chat-launcher'));
      final closeButton = tester.widget<FloatingActionButton>(closeFinder);
      closeButton.onPressed!();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const ValueKey('global-character-chat-launcher')), findsOneWidget);
      expect(find.text('Preserve this draft.'), findsOneWidget);

      final reopenFinder = find.byKey(const ValueKey('global-character-chat-launcher'));
      final reopenButton = tester.widget<FloatingActionButton>(reopenFinder);
      reopenButton.onPressed!();
      await _pumpUntil(
        tester,
        () => find.byKey(const ValueKey('global-character-chat-launcher')),
      );

      expect(find.byKey(const ValueKey('global-character-chat-launcher')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('global-character-chat')),
        findsOneWidget,
      );
      expect(find.text('Preserve this draft.'), findsOneWidget);
    },
  );

  testWidgets(
    'global character chat launcher remains available from the civilization surface',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(connectRuntime: false),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('App Introduction'));
      await tester.pump();

      final intro = find.byKey(const ValueKey('intro'));
      expect(intro, findsOneWidget);

      final registryChips = find.descendant(
        of: intro,
        matching: find.byType(ActionChip),
      );
      expect(registryChips, findsNWidgets(15));

      await tester.ensureVisible(registryChips.first);
      await tester.pump();
      await tester.tap(registryChips.first);
      await _pumpUntil(
        tester,
        () => find.byKey(const ValueKey('civilization')),
      );

      expect(
        find.text('GATE 1 · CRITERIVOX CIVILIZATION'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('global-character-chat-launcher')), findsOneWidget);

      final civilizationChatFinder = find.byKey(const ValueKey('global-character-chat-launcher'));
      final civilizationChatButton = tester.widget<FloatingActionButton>(civilizationChatFinder);
      civilizationChatButton.onPressed!();
      await _pumpUntil(
        tester,
        () => find.byKey(const ValueKey('global-character-chat-launcher')),
      );

      expect(find.byKey(const ValueKey('global-character-chat-launcher')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('global-character-chat')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('global-character-chat')),
          matching: find.byType(TextField),
        ),
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
    await tester.pump(const Duration(milliseconds: 50));
  }

  expect(finder(), findsOneWidget);
}
