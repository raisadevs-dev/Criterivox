import 'package:flutter_test/flutter_test.dart';
import 'package:criterivox/Pramon/pramon_presentation.dart';
void main(){test('Pramon exposes planning surfaces',(){expect(PramonPresentation.characterId,'pramon');expect(PramonPresentation.capabilities.map((x)=>x.id),containsAll(['options','tradeoffs','contingency','rationale','review']));});}
