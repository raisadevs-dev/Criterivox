import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/app_shell.dart';

void main() {
  testWidgets('Criterivox shell renders Bloom navigation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CriterivoxShell(
          isDarkMode: true,
          onToggleTheme: _noop,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Criterivox'), findsOneWidget);
    expect(find.text('Analyze'), findsWidgets);
    expect(find.text('Bloom'), findsOneWidget);
  });

  testWidgets('Criterivox shell exposes workspace and chat navigation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CriterivoxShell(
          isDarkMode: true,
          onToggleTheme: _noop,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Analysis Workspace'), findsOneWidget);
    expect(find.text('Character Chat'), findsOneWidget);
  });
}

void _noop() {}
