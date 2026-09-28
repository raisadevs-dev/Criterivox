import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/agents/manis/manis_presentation.dart';
void main(){test('Manis exposes challenge surfaces',(){expect(ManisPresentation.characterId,'manis');expect(ManisPresentation.capabilities.map((x)=>x.id),containsAll(['assumption','evidence','logic','tradeoff','record']));});}
