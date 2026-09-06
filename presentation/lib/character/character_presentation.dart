import 'package:flutter/material.dart';

import '../presentation/presentation_state.dart';
import 'character_identity.dart';
import 'character_visual_state.dart';
import 'dharen_rive_layer.dart';

/// Presentation-only character surface. Application state remains authoritative.
class CharacterPresentation extends StatelessWidget {
  final PresentationState state;

  const CharacterPresentation({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final identity = CharacterIdentities.resolve(state.agentId);
    final visualState = CharacterVisualState.fromPresentationState(state);
    return Semantics(
      container: true,
      label: '${identity.displayName}, ${identity.role}',
      value: visualState.characterState,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DharenRiveLayer(
            visualState: visualState,
            fallback: _FlutterDharenFallback(visualState: visualState),
          ),
          Text(
            identity.displayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            identity.role,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF9EA5C1),
                  letterSpacing: .5,
                ),
          ),
          const SizedBox(height: 9),
          _StateBadge(state: visualState.characterState),
        ],
      ),
    );
  }
}

/// Complete Flutter baseline while the authored Rive asset is being created.
class _FlutterDharenFallback extends StatelessWidget {
  final CharacterVisualState visualState;
  const _FlutterDharenFallback({required this.visualState});

  @override
  Widget build(BuildContext context) {
    final state = visualState.characterState;
    final working = state == 'WORK';
    final warning = state == 'WARNING';
    final communicating = state == 'COMMUNICATE';
    final complete = state == 'COMPLETE';

    return AnimatedScale(
      scale: visualState.active ? 1 : .94,
      duration: visualState.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 260),
      child: SizedBox(
        width: 238,
        height: 286,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 5,
              child: Container(
                width: working || warning ? 200 : 184,
                height: 34,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                  gradient: RadialGradient(colors: [
                    Color(0x663F35B6),
                    Color(0x221B174B),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Positioned(
              top: 18,
              child: AnimatedRotation(
                turns: working || communicating ? .015 : 0,
                duration: visualState.reducedMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 420),
                child: Container(
                  width: 166,
                  height: 166,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: working || communicating
                          ? const Color(0x668D7DFF)
                          : const Color(0x229A8CFF),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 27,
              child: Container(
                width: 154,
                height: 150,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8C7BFF),
                      Color(0xFF5B4DC7),
                      Color(0xFF33276F),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(64),
                    topRight: Radius.circular(64),
                    bottomLeft: Radius.circular(34),
                    bottomRight: Radius.circular(34),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x664B3FD0), blurRadius: 28, spreadRadius: 2),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.insights_rounded, size: 24, color: Color(0xB7E6E2FF)),
                ),
              ),
            ),
            Positioned(
              top: 35,
              child: Container(
                width: warning || communicating ? 142 : 138,
                height: warning || communicating ? 142 : 138,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-.27, -.34),
                    colors: [Colors.white, Color(0xFFE8E6F7), Color(0xFFC0BFDA)],
                  ),
                  border: Border.all(
                    color: warning ? const Color(0xFFB09FFF) : const Color(0xFF8E7BEF),
                    width: warning ? 7 : 6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: warning ? const Color(0x995B4FE4) : const Color(0x665348CF),
                      blurRadius: warning ? 38 : 28,
                      spreadRadius: warning ? 7 : 3,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Eye(working: working),
                    const SizedBox(width: 31),
                    _Eye(working: working),
                  ],
                ),
              ),
            ),
            if (working || communicating || warning)
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
                    boxShadow: [BoxShadow(color: Color(0x554D43BA), blurRadius: 15)],
                  ),
                  child: Text(
                    warning ? '!' : communicating ? '…' : '•',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
              ),
            if (complete)
              const Positioned(
                top: 92,
                child: Icon(Icons.check_circle_rounded, size: 22, color: Color(0xFF5B4FE4)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  final bool working;
  const _Eye({required this.working});

  @override
  Widget build(BuildContext context) => Container(
        width: 14,
        height: working ? 17 : 20,
        decoration: BoxDecoration(
          color: const Color(0xFF25213D),
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Center(
          child: SizedBox(
            width: 5,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF8F5FF)),
            ),
          ),
        ),
      );
}

class _StateBadge extends StatelessWidget {
  final String state;
  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF15132C),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x332E275C)),
        ),
        child: Text(
          state,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: Color(0xFFB7B1D9),
          ),
        ),
      );
}
