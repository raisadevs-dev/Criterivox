import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s8_authority.dart';
import 'package:presentation/s8_character_system.dart';
import 'package:presentation/s8_presentation_state.dart';

void main() {
  S8CharacterState character(S8ActivityState activity) => S8CharacterState(
        name: 'Medrus',
        role: 'Evidence Specialist / Experimenter',
        visualMetaphor: 'evidence',
        activity: activity,
        activityLabel: activity.name,
        accent: Colors.amber,
      );

  testWidgets('character view maps every authoritative activity to a visual state', (tester) async {
    for (final activity in S8ActivityState.values) {
      await tester.pumpWidget(MaterialApp(home: S8CharacterView(state: character(activity))));
      expect(find.text('Medrus'), findsOneWidget);
      expect(find.text(activity.name), findsOneWidget);
    }
  });

  testWidgets('profile overlay exposes identity and current state', (tester) async {
    final state = S8AuthoritativeState.fromSnapshot(S8PresentationSnapshot.demo());
    final medrus = state.medrus;
    await tester.pumpWidget(MaterialApp(
      home: Stack(children: [
        S8CharacterProfileOverlay(character: medrus, onClose: () {}),
      ]),
    ));
    expect(find.text('Medrus'), findsOneWidget);
    expect(find.textContaining('Evidence Specialist'), findsOneWidget);
    expect(find.textContaining('Current state:'), findsOneWidget);
  });

  testWidgets('profile can be dragged without changing authoritative character state', (tester) async {
    final state = S8AuthoritativeState.fromSnapshot(S8PresentationSnapshot.demo());
    final medrus = state.medrus;
    await tester.pumpWidget(MaterialApp(
      home: Stack(children: [S8CharacterProfileOverlay(character: medrus, onClose: () {})]),
    ));
    final before = medrus.activity;
    final card = find.text('Medrus');
    await tester.drag(card, const Offset(80, 40));
    await tester.pump();
    expect(medrus.activity, before);
  });
}
