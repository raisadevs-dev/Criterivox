import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/agents/epistre/epistre_presentation.dart';
void main(){test('Epistre exposes explanation surfaces',(){expect(EpistrePresentation.characterId,'epistre');expect(EpistrePresentation.capabilities.map((x)=>x.id),containsAll(['explain','sources','parents','limitations','provenance']));});}
