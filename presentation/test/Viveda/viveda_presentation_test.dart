import 'package:flutter_test/flutter_test.dart';
import 'package:criterivox/Viveda/viveda_presentation.dart';
void main(){test('Viveda exposes knowledge surfaces',(){expect(VivedaPresentation.characterId,'viveda');expect(VivedaPresentation.capabilities.map((x)=>x.id),containsAll(['synthesis','evidence','verification','applicability','lineage']));});}
