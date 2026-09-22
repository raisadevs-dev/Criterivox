import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app_shell.dart';

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

      expect(
        find.text('Criterivox'),
        findsWidgets,
      );

      expect(
        find.text('Bloom'),
        findsOneWidget,
      );

      expect(
        find.text('Analysis Workspace'),
        findsOneWidget,
      );

      expect(
        find.text('Civilization · Gate 1'),
        findsOneWidget,
      );

      expect(
        find.text('App Introduction'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'navigation moves to the workspace and global character chat surface',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(
        const Size(1280, 900),
      );

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

      await tester.tap(
        find.text('Analysis Workspace'),
      );

      await tester.pump(
        const Duration(milliseconds: 300),
      );

      expect(
        find.text('Analysis Workspace'),
        findsWidgets,
      );

      expect(
        find.text('Start Analysis'),
        findsOneWidget,
      );

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

  testWidgets(
    'Bloom Analyze expands only its currently implemented paths',
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

      await tester.tap(
        find.text('Analyze').first,
      );

      await tester.pump();

      expect(
        find.text('Workspace'),
        findsOneWidget,
      );

      expect(
        find.bySemanticsLabel(
          RegExp(
            r'Analyze capability, Vivren responsible for Discernment',
          ),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'App Introduction exposes the current introduction content',
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

      await tester.tap(
        find.text('App Introduction'),
      );

      await tester.pump();

      expect(
        find.byKey(
          const ValueKey('intro'),
        ),
        findsOneWidget,
      );

      expect(
        find.text('ONE SYSTEM. MANY MINDS.'),
        findsOneWidget,
      );

      expect(
        find.text('MEET THE MINDS'),
        findsOneWidget,
      );

      expect(
        find.text('SYVAX'),
        findsWidgets,
      );

      expect(
        find.text('DHAREN'),
        findsWidgets,
      );

      expect(
        find.text('THE WORKFLOW'),
        findsOneWidget,
      );

      expect(
        find.text(
          'RECEIVE → CONTEXT → REASON → PLAN → VERIFY → DELIVER',
        ),
        findsOneWidget,
      );

      expect(
        find.text('Enter Civilization'),
        findsOneWidget,
      );

      expect(
        find.text('Enter workspace'),
        findsOneWidget,
      );

      expect(
        find.text('Meet Syvax'),
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