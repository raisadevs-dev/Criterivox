import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app_shell.dart';

void main() {
  testWidgets(
    'Criterivox opens on Bloom and exposes navigation',
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
      expect(find.text('Bloom'), findsOneWidget);
      expect(find.text('Analysis Workspace'), findsOneWidget);
      expect(find.text('Character Chat'), findsOneWidget);
      expect(find.text('App Introduction'), findsOneWidget);
    },
  );

  testWidgets(
    'navigation moves to the real workspace and chat surfaces',
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

      await tester.tap(find.text('Analysis Workspace'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Analysis Workspace'), findsWidgets);
      expect(find.text('Start Analysis'), findsOneWidget);

      await tester.tap(find.text('Character Chat').first);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Chat with Dharen'), findsOneWidget);
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

      await tester.tap(find.text('Analyze').first);
      await tester.pump();

      expect(find.text('Workspace'), findsOneWidget);

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
    'App Introduction explains characters and implemented capabilities',
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

      await tester.tap(find.text('App Introduction'));
      await tester.pump();

      expect(find.text('MEET THE MINDS'), findsOneWidget);
      expect(find.text('SYVAX'), findsWidgets);
      expect(find.text('DHAREN'), findsWidgets);
      expect(find.text('WHAT YOU CAN DO'), findsOneWidget);
      expect(find.text('Available now'), findsWidgets);
      expect(find.text('Future'), findsWidgets);
    },
  );
}