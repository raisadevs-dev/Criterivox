import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app_shell.dart';
import 'package:presentation/presentation/language_mode.dart';

void main() {
  testWidgets(
    'Criterivox opens on Bloom and exposes current navigation',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(
            isDarkMode: true,
            connectRuntime: false,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Criterivox'), findsWidgets);
      expect(find.text('Living Interaction'), findsOneWidget);
      expect(find.text('Lifecycle'), findsOneWidget);
      expect(find.text('START HERE'), findsOneWidget);
      expect(find.text('HUMAN TERRITORY'), findsOneWidget);
      expect(find.text('App Introduction'), findsOneWidget);
      expect(find.byTooltip(RegExp('Language')), findsOneWidget);
    },
  );

  testWidgets(
    'global character chat is available from the current application shell',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(
            isDarkMode: true,
            connectRuntime: false,
          ),
        ),
      );

      await tester.pump();

      final openChat = find.byTooltip('Open character chat');
      expect(openChat, findsOneWidget);

      await tester.tap(openChat);
      await _pumpUntil(
        tester,
        () => find.byTooltip('Close character chat'),
      );

      expect(find.byTooltip('Close character chat'), findsOneWidget);
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

  testWidgets(
    'Bloom exposes its current living interaction surface',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(
            isDarkMode: true,
            connectRuntime: false,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Living Interaction'), findsOneWidget);
      expect(
        find.text('Choose a capability and follow its contextual path.'),
        findsOneWidget,
      );
      expect(find.text('Lifecycle'), findsOneWidget);
      expect(find.text('IDLE'), findsOneWidget);
    },
  );

  testWidgets(
    'App Introduction explains the current product model',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(isDarkMode: true, connectRuntime: false),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('App Introduction'));
      await tester.pump();

      expect(find.byKey(const ValueKey('intro')), findsOneWidget);
      expect(find.text('WHAT IS CRITERIVOX'), findsOneWidget);
      expect(find.text('WHAT CAN I DO HERE'), findsOneWidget);
      expect(find.text('HOW TO USE IT'), findsOneWidget);
      expect(find.text('WHY DOES THE WORLD EXIST?'), findsOneWidget);
      expect(find.text('WHO ARE THESE CHARACTERS?'), findsOneWidget);
      expect(find.text('WHAT IS BLOOM?'), findsOneWidget);
      expect(find.text('HUMAN TERRITORY'), findsOneWidget);
    },
  );

  testWidgets(
    'application navigation localizes the sidebar labels',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CriterivoxShell(
            isDarkMode: true,
            connectRuntime: false,
            language: CriterivoxLanguage.hindi,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('यहाँ से शुरू करें'), findsOneWidget);
      expect(find.text('ऐप परिचय'), findsOneWidget);
      expect(find.text('मानव क्षेत्र'), findsOneWidget);
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
