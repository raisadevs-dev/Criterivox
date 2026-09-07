import 'package:flutter/material.dart';

import '../presentation/presentation_state.dart';
import 'character_identity.dart';
import 'character_visual_state.dart';
import 'dharen_svg_layer.dart';

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
          DharenSvgLayer(visualState: visualState),
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
