import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/interaction/bloom.dart';
import 'package:presentation/interaction/syvax.dart';

void main() {
  testWidgets(
    'Bloom exposes capability gateway and selects Analyze',
    (WidgetTester tester) async {
      BloomCapability? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Bloom(
            onSelected: (value) => selected = value,
          ),
        ),
      );

      expect(find.text('Analyze'), findsOneWidget);
      expect(find.text('Compare'), findsOneWidget);

      await tester.tap(find.text('Analyze'));
      await tester.pump();

      expect(selected, BloomCapability.analyze);

      expect(
        find.bySemanticsLabel(
          RegExp(r'Analyze capability, Vivren responsible for Discernment'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Bloom opens every capability without character chat or future-sprint reservation',
    (WidgetTester tester) async {
      BloomActivation? opened;

      await tester.pumpWidget(
        MaterialApp(
          home: Bloom(
            onSelected: (_) {},
            onOpenCapability: (value) => opened = value,
            activateCapability: (capability) async => BloomActivation(
              capability: capability,
              route: capability == BloomCapability.stewardship
                  ? 'stewardship'
                  : 'workspace',
              action: 'test',
              destinations: const ['Home 01'],
            ),
          ),
        ),
      );

      for (final capability in BloomCapability.values) {
        final label = Bloom.labels[capability]!;
        await tester.tap(find.text(label));
        await tester.pump();
        expect(find.text('Open'), findsOneWidget);
        await tester.tap(find.text('Open'));
        await tester.pump();
        expect(opened?.capability, capability);
      }

      expect(
        find.bySemanticsLabel(
          RegExp(r'Compare capability, Dharen responsible for Context structure'),
        ),
        findsOneWidget,
      );
      expect(find.text('reserved'), findsNothing);
    },
  );

  testWidgets(
    'Syvax accepts suggested input and submits it',
    (WidgetTester tester) async {
      String? submitted;

      await tester.pumpWidget(
        MaterialApp(
          home: Syvax(
            onSubmit: (value) => submitted = value,
          ),
        ),
      );

      const suggestedInput =
          'Analyze the supplied data in the provided context.';

      await tester.tap(find.text(suggestedInput));
      await tester.pump();

      await tester.tap(find.text('Send to Criterivox'));

      expect(submitted, suggestedInput);
    },
  );
}