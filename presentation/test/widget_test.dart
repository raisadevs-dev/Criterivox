import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app_shell.dart';

void main() {
  testWidgets('Criterivox opens on Bloom and exposes navigation',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CriterivoxShell(isDarkMode: true, connectRuntime: false),
    ));
    await tester.pump();

    expect(find.text('Criterivox'), findsOneWidget);
    expect(find.text('Bloom'), findsOneWidget);
    expect(find.text('Analysis Workspace'), findsOneWidget);
    expect(find.text('Character Chat'), findsOneWidget);
    expect(find.text('App Introduction'), findsOneWidget);
  });

  testWidgets('navigation moves to the real workspace and chat surfaces',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CriterivoxShell(isDarkMode: true, connectRuntime: false),
    ));
    await tester.pump();

    await tester.tap(find.text('Analysis Workspace'));
    await tester.pumpAndSettle();
    expect(find.text('Analysis Workspace'), findsWidgets);
    expect(find.text('Start Analysis'), findsOneWidget);

    await tester.tap(find.text('Character Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Chat with Syvax'), findsOneWidget);
    expect(find.text('CHARACTER NETWORK'), findsOneWidget);
  });

  testWidgets('Bloom Analyze expands only its relevant paths', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CriterivoxShell(isDarkMode: true, connectRuntime: false),
    ));
    await tester.pump();

    await tester.tap(find.text('Analyze').first);
    await tester.pump();
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
  });

  testWidgets(
      'App Introduction explains both characters and implemented capabilities',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CriterivoxShell(isDarkMode: true, connectRuntime: false),
    ));
    await tester.pump();

    await tester.tap(find.text('App Introduction'));
    await tester.pump();
    expect(find.text('MEET THE MINDS'), findsOneWidget);
    expect(find.text('SYVAX'), findsWidgets);
    expect(find.text('DHAREN'), findsWidgets);
    expect(find.text('WHAT YOU CAN DO'), findsOneWidget);
    expect(find.text('Available now'), findsWidgets);
    expect(find.text('Future'), findsWidgets);
  });
}
