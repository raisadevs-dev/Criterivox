import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/foundation/criterivox_responsive_scene.dart';

void main() {
  group('Criterivox responsive civilization', () {
    test(
      '480px viewport is classified as compact',
      () {
        const responsive = CriterivoxResponsive(480);

        expect(
          responsive.isCompact,
          isTrue,
        );

        expect(
          responsive.viewport,
          CriterivoxViewport.mobile,
        );

        expect(
          responsive.informationColumns,
          1,
        );
      },
    );

    test(
      '768px viewport is classified as tablet',
      () {
        const responsive = CriterivoxResponsive(768);

        expect(
          responsive.isCompact,
          isFalse,
        );

        expect(
          responsive.isTablet,
          isTrue,
        );

        expect(
          responsive.informationColumns,
          1,
        );
      },
    );

    test(
      '1280px viewport is classified as desktop',
      () {
        const responsive = CriterivoxResponsive(1280);

        expect(
          responsive.isCompact,
          isFalse,
        );

        expect(
          responsive.isTablet,
          isFalse,
        );

        expect(
          responsive.isDesktop,
          isTrue,
        );
      },
    );

    testWidgets(
      'responsive civilization keeps information available on compact view',
      (tester) async {
        await tester.binding.setSurfaceSize(
          const Size(480, 900),
        );

        addTearDown(() async {
          await tester.binding.setSurfaceSize(null);
        });

        const responsive = CriterivoxResponsive(480);

        expect(
          responsive.isCompact,
          isTrue,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CriterivoxResponsiveScene(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Criterivox Civilization'),
                    Text('Character homes'),
                    Text('Relationships'),
                    Text('Responsibilities'),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        expect(
          find.text('Criterivox Civilization'),
          findsOneWidget,
        );

        expect(
          find.text('Character homes'),
          findsOneWidget,
        );

        expect(
          find.text('Relationships'),
          findsOneWidget,
        );

        expect(
          find.text('Responsibilities'),
          findsOneWidget,
        );

        expect(
          tester.takeException(),
          isNull,
        );
      },
    );
  });
}