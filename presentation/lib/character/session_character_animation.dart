import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'character_runtime.dart';

/// Session-level animation director for Criterivox characters.
///
/// A fresh seed is created for every app process. Character-specific profiles
/// are derived from that seed, so the same character can have a slightly
/// different rhythm, phase and emphasis on each session without storing image
/// assets or changing character identity.
class SessionCharacterAnimation {
  static final int sessionSeed = DateTime.now().microsecondsSinceEpoch ^ math.Random().nextInt(0x7fffffff);

  static const activeCharacters = <String>{
    'anuka',
    'dharen',
    'kaelen',
    'sandre',
    'syvax',
  };

  static bool supports(String characterId) => activeCharacters.contains(characterId.trim().toLowerCase());

  static SessionCharacterMotion profileFor(String characterId) {
    final id = characterId.trim().toLowerCase();
    var hash = sessionSeed;
    for (final unit in id.codeUnits) {
      hash = ((hash * 31) ^ unit) & 0x7fffffff;
    }
    final random = math.Random(hash);
    return SessionCharacterMotion(
      duration: 2.55 + random.nextDouble() * 1.15,
      phase: random.nextDouble() * math.pi * 2,
      sway: .45 + random.nextDouble() * .85,
      lift: .7 + random.nextDouble() * 1.4,
      emphasis: .75 + random.nextDouble() * .5,
      direction: random.nextBool() ? 1 : -1,
    );
  }
}

class SessionCharacterMotion {
  final double duration;
  final double phase;
  final double sway;
  final double lift;
  final double emphasis;
  final int direction;

  const SessionCharacterMotion({
    required this.duration,
    required this.phase,
    required this.sway,
    required this.lift,
    required this.emphasis,
    required this.direction,
  });
}

/// Places the existing procedural character renderer inside a session-driven
/// animation envelope. The renderer remains the source of truth for identity,
/// clothing, accessories and semantic states; this layer adds per-session
/// motion without PNG/GIF dependencies.
class SessionCharacterAnimationView extends StatefulWidget {
  final String characterId;
  final String state;
  final bool reducedMotion;
  final double width;
  final double height;

  const SessionCharacterAnimationView({
    super.key,
    required this.characterId,
    required this.state,
    this.reducedMotion = false,
    this.width = 238,
    this.height = 286,
  });

  @override
  State<SessionCharacterAnimationView> createState() => _SessionCharacterAnimationViewState();
}

class _SessionCharacterAnimationViewState extends State<SessionCharacterAnimationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late SessionCharacterMotion _motion;

  @override
  void initState() {
    super.initState();
    _motion = SessionCharacterAnimation.profileFor(widget.characterId);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_motion.duration * 1000).round()),
    );
    if (!widget.reducedMotion) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant SessionCharacterAnimationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.characterId != widget.characterId) {
      _motion = SessionCharacterAnimation.profileFor(widget.characterId);
      _controller.duration = Duration(milliseconds: (_motion.duration * 1000).round());
    }
    if (widget.reducedMotion) {
      _controller.stop();
    } else if (oldWidget.reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!SessionCharacterAnimation.supports(widget.characterId)) {
      return CharacterRuntimeView(
        characterId: widget.characterId,
        state: widget.state,
        reducedMotion: widget.reducedMotion,
        width: widget.width,
        height: widget.height,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _motion.phase + _controller.value * math.pi * 2;
        final wave = math.sin(phase);
        final breathe = math.sin(phase * 1.17 + .4);
        final state = widget.state.toUpperCase();
        final active = state != 'IDLE';
        final lift = wave * _motion.lift * (active ? 1.0 : .65);
        final sway = math.sin(phase * .73) * _motion.sway * _motion.direction;
        final scale = 1 + breathe * .004 * _motion.emphasis;
        final angle = math.sin(phase * .61) * .004 * _motion.direction;
        final accent = switch (widget.characterId.toLowerCase()) {
          'syvax' => const Color(0xFF62D8F5),
          'anuka' => const Color(0xFFBD7FE4),
          'sandre' => const Color(0xFF63B9A8),
          'dharen' => const Color(0xFFD98B43),
          'kaelen' => const Color(0xFFF19A3E),
          _ => Theme.of(context).colorScheme.primary,
        };

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: .035 + .025 * ((wave + 1) / 2)),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const SizedBox(width: 1, height: 1),
                ),
              ),
              Transform.translate(
                offset: Offset(sway, lift),
                child: Transform.rotate(
                  angle: angle,
                  child: Transform.scale(
                    scale: scale,
                    child: CharacterRuntimeView(
                      characterId: widget.characterId,
                      state: widget.state,
                      reducedMotion: widget.reducedMotion,
                      width: widget.width,
                      height: widget.height,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
