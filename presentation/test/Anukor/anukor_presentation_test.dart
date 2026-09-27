import 'package:flutter_test/flutter_test.dart';
import 'package:criterivox/Anukor/anukor_presentation.dart';
void main(){test('Anukor exposes transfer surfaces',(){expect(AnukorPresentation.characterId,'anukor');expect(AnukorPresentation.capabilities.map((x)=>x.id),containsAll(['assess','adaptation','record','rejection','trace']));});}
