import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app/app_shell.dart';
import 'package:presentation/presentation/shared/language_mode.dart';

void main() {
  testWidgets(
    'Criterivox opens on Human Territory welcome and exposes navigation',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CriterivoxShell(isDarkMode: true, connectRuntime: false),
      ));
      await tester.pump();
      expect(find.text('Criterivox'), findsWidgets);
      expect(find.text('HUMAN TERRITORY'), findsWidgets);
      expect(find.text('Your goals. Your context. Your decisions.'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('HUMAN TERRITORY'), findsWidgets);
      expect(find.text('App Introduction'), findsOneWidget);
      expect(find.byTooltip(RegExp('Language')), findsOneWidget);
    },
  );

  testWidgets(
    'Human Territory quick actions are available from the application shell',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(
        home: CriterivoxShell(isDarkMode: true, connectRuntime: false),
      ));
      await tester.pump();
      final launcher = find.byKey(const ValueKey('global-character-chat-launcher'));
      expect(launcher, findsOneWidget);
      final button = tester.widget<FloatingActionButton>(launcher);
      expect(button.tooltip, 'Human Territory quick actions');
      button.onPressed!();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Human Territory launcher'), findsOneWidget);
      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Private Room'), findsOneWidget);
      expect(find.text('Decision Desk'), findsOneWidget);
      expect(find.text('Results Journal'), findsOneWidget);
      expect(find.text('Group Room'), findsOneWidget);
    },
  );

  testWidgets(
    'Human Territory exposes welcome and guest entry',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CriterivoxShell(isDarkMode: true, connectRuntime: false),
      ));
      await tester.pump();
      expect(find.text('Your goals. Your context. Your decisions.'), findsOneWidget);
      expect(find.text('Sign in / Create account'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
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
      expect(find.text('HUMAN TERRITORY'), findsWidgets);
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
