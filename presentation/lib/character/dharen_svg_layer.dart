import 'package:flutter/material.dart';
import 'character_frame.dart';
import 'character_visual_assets.dart';
import 'character_visual_state.dart';

class DharenSvgLayer extends StatelessWidget {
  final CharacterVisualState visualState;
  const DharenSvgLayer({super.key, required this.visualState});

  int _frame(String state) {
    switch (state) {
      case 'RECEIVE': return 1;
      case 'WORK': return 2;
      case 'COMMUNICATE': return 3;
      case 'HANDOFF': return 4;
      case 'COMPLETE': return 5;
      case 'WARNING': return 3;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final state = visualState.characterState;
    final frame = _frame(state);
    final duration = visualState.reducedMotion ? Duration.zero : const Duration(milliseconds: 420);
    return Semantics(
      label: 'Dharen character', value: state,
      child: SizedBox(
        width: 238, height: 286,
        child: AnimatedScale(
          scale: visualState.active ? 1 : .94, duration: duration, curve: Curves.easeOut,
          child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
            Positioned(
              bottom: 5,
              child: AnimatedContainer(
                duration: duration,
                width: state == 'WORK' || state == 'WARNING' ? 200 : 184,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: RadialGradient(colors: [
                    t.colorScheme.primary.withValues(alpha: .40),
                    t.colorScheme.primary.withValues(alpha: .10),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: duration,
              child: CharacterFrame(
                key: ValueKey(frame),
                asset: CharacterVisualAssets.sheetFor('dharen'),
                stateAsset: CharacterVisualAssets.stateFor('dharen', frame),
                index: frame, width: 166, height: 244,
                fallbackAsset: CharacterVisualAssets.sheetFor('dharen'),
              ),
            ),
            if (state == 'WORK' || state == 'COMMUNICATE' || state == 'HANDOFF' || state == 'WARNING')
              Positioned(
                top: 10, right: 19,
                child: Container(
                  width: 36, height: 36, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: t.colorScheme.primary.withValues(alpha: .28), blurRadius: 15)],
                  ),
                  child: Text(
                    state == 'WARNING' ? '!' : state == 'COMMUNICATE' ? '…' : state == 'HANDOFF' ? '↗' : '•',
                    style: TextStyle(color: t.colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
