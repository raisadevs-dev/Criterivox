import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_evidence_bureau_page.dart';
import 'package:presentation/s8_environment_entities.dart';

void main() {
  testWidgets('character tap opens inspectable profile card', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: S8EvidenceBureauPage()));
    await tester.tap(find.text('Medrus').first);
    await tester.pumpAndSettle();
    expect(find.text('MEDRUS'), findsWidgets);
    expect(find.text('PERSONALITY'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.textContaining('Grab and move this profile card'), findsOneWidget);
  });

  testWidgets('home renders vector environmental entity layer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: S8EvidenceBureauPage()));
    expect(find.byType(S8EnvironmentEntityCluster), findsOneWidget);
    expect(find.byType(S8EnvironmentEntity), findsWidgets);
  });

  testWidgets('each specialist room keeps its own environmental arrangement', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: S8EvidenceBureauPage()));
    for (final room in ['Medrus', 'Epistre', 'Veridat', 'Presentation']) {
      await tester.tap(find.text(room).first);
      await tester.pumpAndSettle();
      expect(find.byType(S8EnvironmentEntityCluster), findsOneWidget);
      expect(find.byType(S8EnvironmentEntity), findsWidgets);
    }
  });
}
