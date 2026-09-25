import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'character/character_identity.dart';
import 'character/character_runtime_flutter.dart';
import 's8_presentation_state.dart';

/// S8 character identity is presentation-only. Visual state is projected from
/// authoritative S8CharacterState and never used as a source of truth.
class S8CharacterView extends StatelessWidget {
  final S8CharacterState state;
  final VoidCallback? onTap;
  final bool reducedMotion;

  const S8CharacterView({
    super.key,
    required this.state,
    this.onTap,
    this.reducedMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    final identity = CharacterIdentities.resolve(state.name);
    final runtimeState = _runtimeState(state.activity);

    return Semantics(
      button: onTap != null,
      label: '${identity.nameFor(Localizations.localeOf(context).languageCode)}, ${identity.role}',
      value: state.activityLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CharacterRuntimeView(
              characterId: identity.id,
              state: runtimeState,
              reducedMotion: reducedMotion,
              width: 190,
              height: 228,
            ),
            Text(
              identity.nameFor(Localizations.localeOf(context).languageCode),
              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 3),
            Text(state.activityLabel, style: TextStyle(color: state.accent, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  static String _runtimeState(S8ActivityState activity) => switch (activity) {
        S8ActivityState.idle => 'IDLE',
        S8ActivityState.receive => 'RECEIVE',
        S8ActivityState.work => 'WORK',
        S8ActivityState.communicate => 'COMMUNICATE',
        S8ActivityState.handoff => 'HANDOFF',
        S8ActivityState.complete => 'COMPLETE',
      };
}

class S8CharacterProfileOverlay extends StatelessWidget {
  final S8CharacterState character;
  final VoidCallback onClose;
  final ValueChanged<Offset>? onPositionChanged;
  final Offset initialPosition;

  const S8CharacterProfileOverlay({
    super.key,
    required this.character,
    required this.onClose,
    this.onPositionChanged,
    this.initialPosition = const Offset(24, 24),
  });

  @override
  Widget build(BuildContext context) {
    final identity = CharacterIdentities.resolve(character.name);
    return Positioned(
      left: initialPosition.dx,
      top: initialPosition.dy,
      child: Draggable<Offset>(
        feedback: Material(color: Colors.transparent, child: _card(context, identity)),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) => onPositionChanged?.call(details.offset),
        child: _card(context, identity),
      ),
    );
  }

  Widget _card(BuildContext context, CharacterIdentity identity) => Material(
        color: Colors.transparent,
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1020).withValues(alpha: .96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: character.accent.withValues(alpha: .55)),
            boxShadow: const [BoxShadow(blurRadius: 28, spreadRadius: 2, color: Colors.black54)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(identity.nameFor(Localizations.localeOf(context).languageCode), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900))),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close, color: Colors.white70)),
              ]),
              Text(identity.role, style: TextStyle(color: character.accent, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(identity.description ?? '', style: const TextStyle(color: Colors.white70, height: 1.35)),
              const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: identity.skills.map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact)).toList()),
              const SizedBox(height: 10),
              Text('Current state: ${character.activityLabel}', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 5),
              const Text('Visual identity is presentation-only and follows authoritative state.', style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ).animate().fadeIn(duration: 220.ms).scale(begin: const Offset(.96, .96)),
      );
}
