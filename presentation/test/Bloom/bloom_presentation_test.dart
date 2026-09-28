import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/Bloom/bloom_presentation.dart';

void main() {
  test('Bloom presentation exposes the civilization capability set', () {
    expect(BloomPresentation.capabilityCount, 7);
    expect(BloomPresentation.capabilities, hasLength(7));
  });
}
