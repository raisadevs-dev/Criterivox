import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_evidence_bureau_page.dart';

void main() {
  testWidgets('S8 opens on Home with three specialist identities', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: S8EvidenceBureauPage()));
    expect(find.text('S8 INTELLIGENCE ENVIRONMENT'), findsOneWidget);
    expect(find.text('Medrus'), findsOneWidget);
    expect(find.text('Epistre'), findsOneWidget);
    expect(find.text('Veridat'), findsOneWidget);
  });

  testWidgets('S8 supports room navigation and artifact inspection', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: S8EvidenceBureauPage()));
    await tester.tap(find.text('Veridat'));
    await tester.pumpAndSettle();
    expect(find.textContaining('VERIDAT'), findsOneWidget);
    await tester.tap(find.text('Verification record'));
    await tester.pumpAndSettle();
    expect(find.text('Artifact inspector'), findsOneWidget);
    expect(find.text('insufficient_evidence'), findsWidgets);
  });

  testWidgets('S8 exposes the human challenge arena', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: S8EvidenceBureauPage()));
    await tester.tap(find.text('Open Challenge Arena'));
    await tester.pumpAndSettle();
    expect(find.text('Evidence Challenge Arena'), findsOneWidget);
    expect(find.text('Record structured challenge'), findsOneWidget);
  });
}
