import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_four_room_bureau.dart';

void main() {
  testWidgets('renders the four specialist rooms plus Home hub', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: S8FourRoomBureau())));
    expect(find.text('S8 Home'), findsOneWidget);
    expect(find.text('Medrus'), findsOneWidget);
    expect(find.text('Epistre'), findsOneWidget);
    expect(find.text('Veridat'), findsOneWidget);
    expect(find.text('Presentation'), findsOneWidget);
  });

  testWidgets('room selection changes the active environment', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: S8FourRoomBureau())));
    await tester.tap(find.text('Medrus'));
    await tester.pumpAndSettle();
    expect(find.text('MEDRUS'), findsOneWidget);
    expect(find.text('Evidence & Memory'), findsOneWidget);

    await tester.tap(find.text('Veridat'));
    await tester.pumpAndSettle();
    expect(find.text('VERIDAT'), findsOneWidget);
    expect(find.text('Verification & Truth Boundary'), findsOneWidget);
  });
}
