import 'package:flutter/material.dart';

import 'character_frame.dart';
import 'character_visual_state.dart';

/// Syvax renderer using the same semantic-state-to-frame contract as Dharen.
class SyvaxSvgLayer extends StatelessWidget {
  final CharacterVisualState visualState;

  const SyvaxSvgLayer({super.key, required this.visualState});

  int _frame(String state) {
    switch (state) {
      case 'RECEIVE':
        return 1;
      case 'WORK':
        return 2;
      case 'COMMUNICATE':
        return 3;
      case 'HANDOFF':
        return 4;
      case 'COMPLETE':
        return 5;
      case 'WARNING':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = visualState.characterState;
    final frame = _frame(state);
    final duration = visualState.reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 420);

    return Semantics(
      label: 'Syvax character',
      value: state,
      child: SizedBox(
        width: 238,
        height: 286,
        child: AnimatedScale(
          scale: visualState.active ? 1 : .94,
          duration: duration,
          curve: Curves.easeOut,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 5,
                child: AnimatedContainer(
                  duration: duration,
                  width: state == 'WORK' || state == 'WARNING' ? 200 : 184,
                  height: 34,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                    gradient: RadialGradient(
                      colors: [
                        Color(0x663F35B6),
                        Color(0x221B174B),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: duration,
                child: CharacterFrame(
                  key: ValueKey(frame),
                  asset: 'assets/characters/syvax.svg',
                  index: frame,
                  width: 166,
                  height: 244,
                  fallbackAsset: 'assets/characters/syvax.svg',
                ),
              ),
              if (state == 'WORK' || state == 'COMMUNICATE' || state == 'HANDOFF' || state == 'WARNING')
                Positioned(
                  top: 10,
                  right: 19,
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF17143A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x554D43BA), blurRadius: 15),
                      ],
                    ),
                    child: Text(
                      state == 'WARNING' ? '!' : state == 'COMMUNICATE' ? '…' : state == 'HANDOFF' ? '↗' : '•',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
