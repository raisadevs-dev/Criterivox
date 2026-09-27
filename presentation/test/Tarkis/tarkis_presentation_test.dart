import 'package:flutter_test/flutter_test.dart';
import 'package:criterivox/Tarkis/tarkis_presentation.dart';
void main(){test('Tarkis exposes exploration surfaces',(){expect(TarkisPresentation.characterId,'tarkis');expect(TarkisPresentation.capabilities.map((x)=>x.id),containsAll(['hypotheses','comparison','counterfactual','branches','challenge']));});}
