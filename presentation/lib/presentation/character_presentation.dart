import 'presentation_state.dart';

class CharacterPresentation {
  const CharacterPresentation({
    required this.state,
  });

  final PresentationState state;

  String get characterState => state.characterState;

  bool get isActive => state.active;

  bool get isCommunicating => characterState == 'COMMUNICATE';

  String get visualState => characterState;
}