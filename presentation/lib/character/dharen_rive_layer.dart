import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'character_visual_state.dart';

/// Advanced character-animation boundary for Dharen.
///
/// Application semantics remain outside Rive. Flutter receives the semantic
/// character state and forwards the state transition to the authored Rive
/// state machine. Rive owns continuous motion, posing, facial animation and
/// transition choreography.
class DharenRiveLayer extends StatefulWidget {
  final CharacterVisualState visualState;
  final Widget fallback;

  const DharenRiveLayer({
    super.key,
    required this.visualState,
    required this.fallback,
  });

  @override
  State<DharenRiveLayer> createState() => _DharenRiveLayerState();
}

class _DharenRiveLayerState extends State<DharenRiveLayer> {
  late final rive.FileLoader _fileLoader;
  late final Future<void> _riveReady;
  String? _lastState;

  @override
  void initState() {
    super.initState();
    _riveReady = rive.RiveNative.init();
    _fileLoader = rive.FileLoader.fromAsset(
      'assets/characters/dharen.riv',
      riveFactory: rive.Factory.rive,
    );
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  void _syncSemanticState(rive.RiveWidgetController controller) {
    final semanticState = widget.visualState.characterState;
    if (_lastState == semanticState) return;
    _lastState = semanticState;
    controller.stateMachine?.trigger(semanticState)?.fire();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _riveReady,
      builder: (context, ready) {
        if (ready.connectionState != ConnectionState.done || ready.hasError) {
          return widget.fallback;
        }
        return SizedBox(
          width: 238,
          height: 286,
          child: rive.RiveWidgetBuilder(
            fileLoader: _fileLoader,
            builder: (context, state) => switch (state) {
              rive.RiveLoading() => widget.fallback,
              rive.RiveFailed() => widget.fallback,
              rive.RiveLoaded() => Builder(
                  builder: (context) {
                    _syncSemanticState(state.controller);
                    return Semantics(
                      label: 'Dharen advanced character animation',
                      value: widget.visualState.characterState,
                      child: rive.RiveWidget(
                        controller: state.controller,
                        fit: rive.Fit.contain,
                      ),
                    );
                  },
                ),
            },
          ),
        );
      },
    );
  }
}
