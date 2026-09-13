import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/interaction/bloom.dart';
import 'package:presentation/interaction/syvax.dart';

void main() {
  testWidgets('Bloom exposes capability gateway and activates Analyze',
      (tester) async {
    BloomCapability? selected;
    await tester.pumpWidget(
        MaterialApp(home: Bloom(onSelected: (value) => selected = value)));
    expect(find.text('Analyze'), findsOneWidget);
    expect(find.text('Compare'), findsOneWidget);
    await tester.tap(find.text('Analyze'));
    await tester.pump();
    expect(selected, BloomCapability.analyze);
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
  });

  testWidgets('Bloom keeps future capabilities visibly reserved',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: Bloom(onSelected: (_) {})));
    expect(find.bySemanticsLabel(RegExp('Compare capability, reserved')),
        findsOneWidget);
  });

  testWidgets('Syvax accepts suggested input and submits it', (tester) async {
    String? submitted;
    await tester.pumpWidget(
        MaterialApp(home: Syvax(onSubmit: (value) => submitted = value)));
    await tester
        .tap(find.text('Analyze the supplied data in the provided context.'));
    await tester.pump();
    await tester.tap(find.text('Send to Criterivox'));
    expect(submitted, 'Analyze the supplied data in the provided context.');
  });
}
