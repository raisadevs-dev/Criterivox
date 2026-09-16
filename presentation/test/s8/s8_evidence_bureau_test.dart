import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_evidence_bureau_page.dart';

void main() {
  testWidgets('renders exactly four S8 rooms', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: S8EvidenceBureauPage()));
    expect(find.text('Medrus'), findsOneWidget);
    expect(find.text('Epistre'), findsOneWidget);
    expect(find.text('Veridat'), findsOneWidget);
    expect(find.text('Human'), findsOneWidget);
  });

  testWidgets('switches between rooms', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: S8EvidenceBureauPage()));
    expect(find.text('MEDRUS'), findsOneWidget);
    await tester.tap(find.text('Epistre'));
    await tester.pumpAndSettle();
    expect(find.text('EPISTRE'), findsOneWidget);
    expect(find.text('Explanation provenance'), findsOneWidget);
    await tester.tap(find.text('Veridat'));
    await tester.pumpAndSettle();
    expect(find.text('VERIDAT'), findsOneWidget);
    expect(find.text('Verification boundary'), findsOneWidget);
    await tester.tap(find.text('Human'));
    await tester.pumpAndSettle();
    expect(find.text('HUMAN INTERVENTION'), findsOneWidget);
    expect(find.text('Record question / challenge'), findsOneWidget);
  });

  testWidgets('detail view exposes S8 boundaries', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: S8EvidenceBureauPage()));
    await tester.tap(find.byTooltip('Show detail'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Presentation consumes artifacts/events/state'), findsOneWidget);
    expect(find.textContaining('Artifact content hashes'), findsOneWidget);
    expect(find.text('Boundary'), findsOneWidget);
  });
}
