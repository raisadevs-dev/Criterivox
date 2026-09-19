import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Set 4 exposes all 15 registry-grounded characters', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = await rootBundle.loadString('assets/character_chat/character_registry.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final ids = (data['characters'] as List).map((x) => (x as Map)['id'] as String).toSet();
    expect(ids, containsAll(<String>[
      'syvax','dharen','sandre','kaelen','anuka','vivren','tarkis',
      'pramon','bodhex','medrus','epistre','veridat','manis','viveda','anukor'
    ]));
    expect(ids.length, 15);
  });
}
