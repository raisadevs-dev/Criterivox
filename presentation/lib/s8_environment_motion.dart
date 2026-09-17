import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 's8_environment.dart';
import 's8_presentation_state.dart';

/// Asset-free environmental motion. It animates atmosphere and room signals,
/// never computational truth.
class S8AnimatedRoomEnvironment extends StatelessWidget {
  final S8Room room;
  final Widget child;
  final bool motionEnabled;

  const S8AnimatedRoomEnvironment({
    super.key,
    required this.room,
    required this.child,
    this.motionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = S8RoomEnvironment(room: room, child: child);
    if (!motionEnabled) return content;

    return Stack(
      children: [
        content,
        Positioned.fill(
          child: IgnorePointer(
            child: _AmbientSignals(room: room),
          ),
        ),
      ],
    );
  }
}

class _AmbientSignals extends StatelessWidget {
  final S8Room room;
  const _AmbientSignals({required this.room});

  Color get accent => switch (room) {
        S8Room.medrus => const Color(0xFF2CCCF5),
        S8Room.epistre => const Color(0xFFB98BFF),
        S8Room.veridat => const Color(0xFF38E0A8),
        S8Room.presentation => const Color(0xFFFFC857),
        S8Room.home => const Color(0xFF4CB8FF),
      };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 24,
          right: 24,
          top: 74,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, accent.withValues(alpha: .55), Colors.transparent],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 900.ms).moveY(begin: -8, end: 10, duration: 2800.ms),
        ),
        Positioned(
          right: 40,
          top: 100,
          child: _Node(accent: accent, size: 7),
        ),
        Positioned(
          left: 48,
          top: 185,
          child: _Node(accent: accent, size: 5),
        ),
        Positioned(
          right: 90,
          bottom: 132,
          child: _Node(accent: accent, size: 4),
        ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  final Color accent;
  final double size;
  const _Node({required this.accent, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent,
          boxShadow: [BoxShadow(color: accent.withValues(alpha: .65), blurRadius: 12, spreadRadius: 2)],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: .25, end: 1, duration: 1100.ms).scale(begin: const Offset(.7, .7), end: const Offset(1.25, 1.25), duration: 1100.ms);
}
