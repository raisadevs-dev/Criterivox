import 'package:flutter/material.dart';
import 'data_stewardship_page.dart';
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';

/// Compatibility wrapper retained for callers while Home 01 has one canonical
/// operational surface: DataStewardshipPage.
class StewardshipLiveWorkspacePage extends StatelessWidget {
  final PresentationState? state;
  final CharacterRuntimeClient runtime;
  final ValueChanged<String>? onChatCharacter;

  const StewardshipLiveWorkspacePage({
    super.key,
    required this.state,
    required this.runtime,
    this.onChatCharacter,
  });

  @override
  Widget build(BuildContext context) {
    return DataStewardshipPage(
      state: state,
      runtime: runtime,
      onChatCharacter: onChatCharacter,
    );
  }
}
