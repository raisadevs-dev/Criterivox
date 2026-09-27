import 'package:flutter_test/flutter_test.dart';
import 'package:criterivox/Vivren/vivren_presentation.dart';
void main(){test('Vivren exposes critical reasoning surfaces',(){expect(VivrenPresentation.characterId,'vivren');expect(VivrenPresentation.capabilities.map((x)=>x.id),containsAll(['inspection','assumptions','evidence','contradictions','limitations','provenance']));});}
