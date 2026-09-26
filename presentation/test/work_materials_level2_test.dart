import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/level2_operational_page.dart';

void main() {
  test('Level 2 catalog retains internal civilization rooms', () {
    expect(Level2Catalog.forHome('reasoning').any((r) => r.id == 'reasoning.debate'), isTrue);
    expect(Level2Catalog.forHome('evidence').any((r) => r.id == 'evidence.provenance'), isTrue);
  });

  test('Level 2 operational catalog contains real responsibilities rather than empty homes', () {
    expect(Level2Catalog.forHome('decision'), isNotEmpty);
    expect(Level2Catalog.forHome('data'), isNotEmpty);
    expect(Level2Catalog.forHome('context'), isNotEmpty);
  });
}
