import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app/app_shell.dart';

void main() {
  testWidgets(
    'Human Territory launcher exposes quick actions from the welcome screen',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(
        home: CriterivoxShell(connectRuntime: false),
      ));
      await tester.pump();
      final launcher = find.byKey(const ValueKey('global-character-chat-launcher'));
      expect(launcher, findsOneWidget);
      final button = tester.widget<FloatingActionButton>(launcher);
      expect(button.tooltip, 'Human Territory quick actions');
      button.onPressed!();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('Human Territory launcher'), findsOneWidget);
      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Private Room'), findsOneWidget);
      expect(find.text('Decision Desk'), findsOneWidget);
      expect(find.text('Results Journal'), findsOneWidget);
      expect(find.text('Group Room'), findsOneWidget);
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

      final civilizationLink = find.text('Explore Civilization');
      expect(civilizationLink, findsOneWidget);
      await tester.ensureVisible(civilizationLink);
      await tester.pump();
      await tester.tap(civilizationLink);
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
        () => find.byTooltip('Close character chat'),
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
