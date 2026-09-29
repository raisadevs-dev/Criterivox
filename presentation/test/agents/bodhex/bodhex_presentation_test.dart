import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/agents/bodhex/bodhex_presentation.dart';
void main(){test('Bodhex exposes action surfaces',(){expect(BodhexPresentation.characterId,'bodhex');expect(BodhexPresentation.capabilities.map((x)=>x.id),containsAll(['insight','action','preconditions','scope','recovery']));});}
