import 'package:flutter_test/flutter_test.dart';
import 'package:criterivox/Tarkis/tarkis_presentation.dart';
void main(){test('Tarkis exposes hypothesis exploration surfaces',(){expect(TarkisPresentation.characterId,'tarkis');expect(TarkisPresentation.capabilities.map((x)=>x.id),containsAll(['generation','comparison','support','conflict','counterfactual','basis']));});}
