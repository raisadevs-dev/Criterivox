import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/agents/anukor/anukor_presentation.dart';
void main(){test('Anukor exposes transfer surfaces',(){expect(AnukorPresentation.characterId,'anukor');expect(AnukorPresentation.capabilities.map((x)=>x.id),containsAll(['assess','adaptation','record','rejection','trace']));});}
