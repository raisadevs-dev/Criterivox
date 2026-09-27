import 'package:flutter_test/flutter_test.dart';
import 'package:criterivox/Veridat/veridat_presentation.dart';
void main(){test('Veridat exposes verification surfaces',(){expect(VeridatPresentation.characterId,'veridat');expect(VeridatPresentation.capabilities.map((x)=>x.id),containsAll(['grounding','contradiction','provenance','temporal','integrity']));});}
