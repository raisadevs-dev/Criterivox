import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../presentation/presentation_state.dart';
import 'character_identity.dart';
import 'character_visual_state.dart';

/// Dharen's presentation is intentionally owned by the presentation layer.
///
/// Runtime/application state still comes from [PresentationState]. This file
/// only decides how that semantic state is visualised. It does not create or
/// advance task state.
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
      child: _DharenCharacter(
        identity: identity,
        visualState: visualState,
      ),
    );
  }
}

class _DharenCharacter extends StatelessWidget {
  final CharacterIdentity identity;
  final CharacterVisualState visualState;

  const _DharenCharacter({
    required this.identity,
    required this.visualState,
  });

  @override
  Widget build(BuildContext context) {
    final active = visualState.active;

    return AnimatedOpacity(
      duration: visualState.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 260),
      opacity: active ? 1 : .72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DharenFigure(visualState: visualState),
          const SizedBox(height: 2),
          Text(
            identity.displayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2,
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

/// A deliberately character-like renderer rather than the old generic
/// capsule avatar. The reference treats Dharen as a visible participant in
/// the workspace: a luminous figure, restrained UI glow, expressive face and
/// state-specific activity around him.
class _DharenFigure extends StatelessWidget {
  final CharacterVisualState visualState;

  const _DharenFigure({required this.visualState});

  @override
  Widget build(BuildContext context) {
    final config = _DharenVisual.fromState(visualState.characterState);
    final reducedMotion = visualState.reducedMotion;

    return AnimatedScale(
      scale: visualState.active
          ? config.scale * (.97 + visualState.prominence * .03)
          : .94,
      duration: reducedMotion ? Duration.zero : const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: SizedBox(
        width: 238,
        height: 286,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // The floor glow grounds the figure in the workspace instead of
            // making him look like a sticker placed on top of the UI.
            Positioned(
              bottom: 4,
              child: AnimatedContainer(
                duration: reducedMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 320),
                width: config.groundWidth,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: const RadialGradient(
                    colors: [
                      Color(0x663F35B6),
                      Color(0x221B174B),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // A quiet orbital ring is part of Dharen's visual identity. It
            // becomes more visible when the runtime says he is working.
            Positioned(
              top: 18,
              child: _Orbit(
                state: visualState.characterState,
                reducedMotion: reducedMotion,
              ),
            ),

            // Body and shoulders.
            Positioned(
              bottom: 27,
              child: _DharenBody(config: config),
            ),

            // Head / face.
            Positioned(
              top: 35,
              child: _DharenHead(
                state: visualState.characterState,
                size: config.headSize,
                borderWidth: config.borderWidth,
                reducedMotion: reducedMotion,
              ),
            ),

            if (config.showActivity)
              Positioned(
                top: 10,
                right: 20,
                child: _ActivityOrb(
                  state: visualState.characterState,
                  reducedMotion: reducedMotion,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DharenBody extends StatelessWidget {
  final _DharenVisual config;

  const _DharenBody({required this.config});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: config.bodyWidth + 42,
      height: config.bodyHeight + 24,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Shoulder silhouette.
          Positioned(
            bottom: 10,
            child: Container(
              width: config.bodyWidth + 42,
              height: 82,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF7060E9),
                    Color(0xFF3D318E),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(56),
                  topRight: Radius.circular(56),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x554B3FD0),
                    blurRadius: 26,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Central torso.
          Positioned(
            bottom: 0,
            child: Container(
              width: config.bodyWidth,
              height: config.bodyHeight,
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
                  topLeft: Radius.circular(46),
                  topRight: Radius.circular(46),
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
                border: Border.all(
                  color: const Color(0x337F72FF),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x663F34B4),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 46,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x443D327E),
                        Color(0x22201955),
                      ],
                    ),
                    border: Border.all(color: const Color(0x267F75D7)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.insights_rounded,
                      size: 22,
                      color: Color(0xB7E6E2FF),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DharenHead extends StatelessWidget {
  final String state;
  final double size;
  final double borderWidth;
  final bool reducedMotion;

  const _DharenHead({
    required this.state,
    required this.size,
    required this.borderWidth,
    required this.reducedMotion,
  });

  @override
  Widget build(BuildContext context) {
    final emphasized = const {
      'RECEIVE',
      'COMMUNICATE',
      'HANDOFF',
      'WARNING',
    }.contains(state);

    return AnimatedContainer(
      duration: reducedMotion ? Duration.zero : const Duration(milliseconds: 220),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-.27, -.34),
          radius: .9,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE8E6F7),
            Color(0xFFC0BFDA),
          ],
        ),
        border: Border.all(
          color: emphasized
              ? const Color(0xFFB09FFF)
              : const Color(0xFF8E7BEF),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: emphasized
                ? const Color(0x885B4FE4)
                : const Color(0x665348CF),
            blurRadius: emphasized ? 34 : 27,
            spreadRadius: emphasized ? 6 : 3,
          ),
        ],
      ),
      child: _DharenFace(
        state: state,
        reducedMotion: reducedMotion,
      ),
    );
  }
}

class _DharenFace extends StatelessWidget {
  final String state;
  final bool reducedMotion;

  const _DharenFace({required this.state, required this.reducedMotion});

  @override
  Widget build(BuildContext context) {
    final emphasized = const {
      'RECEIVE',
      'COMMUNICATE',
      'HANDOFF',
      'WARNING',
    }.contains(state);
    final complete = state == 'COMPLETE';
    final working = state == 'WORK';
    final communicating = state == 'COMMUNICATE';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Eye(emphasized: emphasized, working: working),
              const SizedBox(width: 31),
              _Eye(emphasized: emphasized, working: working),
            ],
          ),
          const SizedBox(height: 17),
          AnimatedContainer(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            width: communicating ? 40 : 30,
            height: complete ? 8 : 13,
            decoration: BoxDecoration(
              color: complete
                  ? const Color(0xFF51477C)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: complete
                  ? null
                  : Border.all(
                      color: const Color(0xFF635B83),
                      width: 2,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  final bool emphasized;
  final bool working;

  const _Eye({required this.emphasized, required this.working});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: emphasized ? 15 : 13,
      height: working ? 17 : (emphasized ? 21 : 19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: const Color(0xFF25213D),
        boxShadow: const [
          BoxShadow(
            color: Color(0x663B2F75),
            blurRadius: 7,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: working ? 4 : 5,
          height: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF8F5FF),
          ),
        ),
      ),
    );
  }
}

class _Orbit extends StatelessWidget {
  final String state;
  final bool reducedMotion;

  const _Orbit({required this.state, required this.reducedMotion});

  @override
  Widget build(BuildContext context) {
    final active = const {'WORK', 'COMMUNICATE', 'HANDOFF', 'WARNING'}
        .contains(state);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: active ? 1 : .55),
      duration: reducedMotion ? Duration.zero : const Duration(milliseconds: 360),
      builder: (context, value, child) => Transform.rotate(
        angle: active ? math.pi * .07 * value : 0,
        child: child,
      ),
      child: Container(
        width: 164,
        height: 164,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color.lerp(
              const Color(0x1C9A8CFF),
              const Color(0x558D7DFF),
              active ? .9 : .25,
            )!,
            width: 1,
          ),
        ),
      ),
    );
  }
}

class _ActivityOrb extends StatelessWidget {
  final String state;
  final bool reducedMotion;

  const _ActivityOrb({required this.state, required this.reducedMotion});

  @override
  Widget build(BuildContext context) {
    final symbol = switch (state) {
      'WORK' => '•',
      'COMMUNICATE' => '…',
      'HANDOFF' => '→',
      'WARNING' => '!',
      _ => '•',
    };

    return AnimatedScale(
      scale: state == 'WARNING' ? 1.08 : 1,
      duration: reducedMotion ? Duration.zero : const Duration(milliseconds: 200),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFF17143A),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x554D43BA),
              blurRadius: 15,
            ),
          ],
        ),
        child: Text(
          symbol,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _DharenVisual {
  final double scale;
  final double bodyWidth;
  final double bodyHeight;
  final double headSize;
  final double borderWidth;
  final double groundWidth;
  final bool showActivity;

  const _DharenVisual({
    required this.scale,
    required this.bodyWidth,
    required this.bodyHeight,
    required this.headSize,
    required this.borderWidth,
    required this.groundWidth,
    required this.showActivity,
  });

  factory _DharenVisual.fromState(String state) {
    return switch (state) {
      'RECEIVE' => const _DharenVisual(
          scale: 1.04,
          bodyWidth: 112,
          bodyHeight: 128,
          headSize: 139,
          borderWidth: 6,
          groundWidth: 184,
          showActivity: false,
        ),
      'WORK' => const _DharenVisual(
          scale: 1.02,
          bodyWidth: 110,
          bodyHeight: 131,
          headSize: 136,
          borderWidth: 5,
          groundWidth: 192,
          showActivity: true,
        ),
      'COMMUNICATE' => const _DharenVisual(
          scale: 1.035,
          bodyWidth: 114,
          bodyHeight: 127,
          headSize: 138,
          borderWidth: 6,
          groundWidth: 190,
          showActivity: true,
        ),
      'HANDOFF' => const _DharenVisual(
          scale: 1.05,
          bodyWidth: 116,
          bodyHeight: 130,
          headSize: 139,
          borderWidth: 6,
          groundWidth: 198,
          showActivity: true,
        ),
      'COMPLETE' => const _DharenVisual(
          scale: 1.01,
          bodyWidth: 108,
          bodyHeight: 124,
          headSize: 135,
          borderWidth: 5,
          groundWidth: 184,
          showActivity: false,
        ),
      'WARNING' => const _DharenVisual(
          scale: 1.06,
          bodyWidth: 116,
          bodyHeight: 133,
          headSize: 141,
          borderWidth: 7,
          groundWidth: 200,
          showActivity: true,
        ),
      _ => const _DharenVisual(
          scale: 1,
          bodyWidth: 108,
          bodyHeight: 123,
          headSize: 134,
          borderWidth: 5,
          groundWidth: 180,
          showActivity: false,
        ),
    };
  }
}

class _StateBadge extends StatelessWidget {
  final String state;

  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF17143A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x334C5594)),
      ),
      child: Text(
        state.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFC8CCDF),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
