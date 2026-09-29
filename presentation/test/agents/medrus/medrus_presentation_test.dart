import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/agents/medrus/medrus_presentation.dart';
void main(){test('Medrus exposes evidence and experiment surfaces',(){expect(MedrusPresentation.characterId,'medrus');expect(MedrusPresentation.capabilities.map((x)=>x.id),containsAll(['acquisition','experiment','retrieval','uncertainty','provenance']));});}
