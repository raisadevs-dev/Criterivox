import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/presentation/language_mode.dart';

void main() {
  test('application language catalog exposes automatic and supported modes', () {
    expect(CriterivoxLanguage.supported.first.code, 'auto');
    expect(CriterivoxLanguage.supported, contains(CriterivoxLanguage.hindi));
    expect(CriterivoxLanguage.supported, contains(CriterivoxLanguage.marathi));
  });

  test('language selection does not alter machine-facing language codes', () {
    expect(CriterivoxLanguage.hindi.code, 'hi');
    expect(CriterivoxLanguage.marathi.code, 'mr');
    expect(CriterivoxLanguage.fromCode('unknown').code, 'auto');
  });
}
