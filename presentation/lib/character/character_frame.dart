import 'package:flutter/material.dart';

import 'character_runtime.dart';

/// Compatibility entrypoint retained for callers that still ask for a
/// character frame. Rendering is now owned by the local web skeletal runtime.
class CharacterFrame extends StatelessWidget {
  final String asset;
  final int index;
  final double width;
  final double height;
  final String? fallbackAsset;
  final String? stateAsset;

  const CharacterFrame({
    super.key,
    required this.asset,
    required this.index,
    this.width = 64,
    this.height = 94,
    this.fallbackAsset,
    this.stateAsset,
  });

  @override
  Widget build(BuildContext context) {
    const states = <String>[
      'IDLE',
      'RECEIVE',
      'WORK',
      'COMMUNICATE',
      'HANDOFF',
      'COMPLETE',
      'WARNING',
    ];
    final state = states[index.clamp(0, states.length - 1)];
    final characterId = _characterId(asset, stateAsset);

    return CharacterRuntimeView(
      characterId: characterId,
      state: state,
      width: width,
      height: height,
    );
  }

  String _characterId(String asset, String? stateAsset) {
    final source = (stateAsset ?? asset).toLowerCase();
    for (final id in <String>[
      'syvax',
      'dharen',
      'sandre',
      'kaelen',
      'anuka',
      'vivren',
      'tarkis',
    ]) {
      if (source.contains(id)) return id;
    }
    return 'dharen';
  }
}
