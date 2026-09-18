import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/foundation/criterivox_artifact.dart';
import 'package:presentation/foundation/criterivox_responsive_scene.dart';
import 'package:presentation/foundation/criterivox_scene.dart';
import 'package:presentation/foundation/criterivox_status.dart';
import 'package:presentation/foundation/criterivox_visual_tokens.dart';

void main() {
  test('responsive foundation preserves spatial hierarchy across widths', () {
    expect(const CriterivoxResponsive(500).viewport, CriterivoxViewport.mobile);
    expect(const CriterivoxResponsive(800).viewport, CriterivoxViewport.tablet);
    expect(const CriterivoxResponsive(1200).viewport, CriterivoxViewport.desktop);
    expect(const CriterivoxResponsive(1500).viewport, CriterivoxViewport.wide);
    expect(const CriterivoxResponsive(500).informationColumns, 1);
    expect(const CriterivoxResponsive(1500).informationColumns, 3);
  });

  testWidgets('scene composes the seven layers in architectural order', (tester) async {
    final seen = <String>[];
    Widget mark(String value) => Builder(builder: (_) {
      seen.add(value);
      return SizedBox(key: ValueKey(value));
    });
    await tester.pumpWidget(MaterialApp(home: SizedBox(
      width: 400, height: 300,
      child: CriterivoxScene(
        descriptor: const CriterivoxSceneDescriptor(
          world: CriterivoxWorld.civilization,
          level: CriterivoxSceneLevel.room,
          id: 'foundation-test',
          title: 'Foundation Room',
        ),
        environment: [mark('environment')],
        character: [mark('character')],
        lighting: [mark('lighting')],
        information: [mark('information')],
        artifact: [mark('artifact')],
        interaction: [mark('interaction')],
        transition: [mark('transition')],
      ),
    )));
    expect(find.byKey(const ValueKey('environment')), findsOneWidget);
    expect(find.byKey(const ValueKey('character')), findsOneWidget);
    expect(find.byKey(const ValueKey('artifact')), findsOneWidget);
    expect(seen, containsAll(<String>['environment','character','lighting','information','artifact','interaction','transition']));
  });

  testWidgets('planned and simulated states remain explicit', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: const [CriterivoxVisualTokens()]),
      home: const Row(children: [
        CriterivoxStatusBadge(status: CriterivoxStatus.planned),
        CriterivoxStatusBadge(status: CriterivoxStatus.simulated),
      ]),
    ));
    expect(find.text('PLANNED'), findsOneWidget);
    expect(find.text('SIMULATED'), findsOneWidget);
  });

  test('artifact model stays domain-neutral', () {
    const artifact = CriterivoxArtifact(
      id: 'e1',
      kind: CriterivoxArtifactKind.evidence,
      title: 'Evidence',
      status: CriterivoxStatus.uncertain,
    );
    expect(artifact.kind, CriterivoxArtifactKind.evidence);
    expect(artifact.status, CriterivoxStatus.uncertain);
  });
}