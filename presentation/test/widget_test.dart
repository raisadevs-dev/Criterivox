import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/main.dart';

void main() {
  testWidgets('Criterivox shell renders Bloom navigation', (tester) async {
    await tester.pumpWidget(const CriterivoxApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('CRITERIVOX'), findsOneWidget);
    expect(find.text('Research Intelligence Workspace'), findsOneWidget);
    expect(find.text('BLOOM'), findsOneWidget);
    expect(find.text('Analyze'), findsOneWidget);
  });

  testWidgets('Criterivox shell exposes workspace and chat navigation', (tester) async {
    await tester.pumpWidget(const CriterivoxApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Analysis Workspace'), findsOneWidget);
    expect(find.text('Character Chat'), findsOneWidget);
  });
}
