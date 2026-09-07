import 'package:flutter/material.dart';
import '../presentation/presentation_state.dart';
import '../presentation/criterivox_theme.dart';
import 'character_identity.dart';
import 'character_visual_state.dart';
import 'dharen_svg_layer.dart';

/// Presentation-only character surface. Application state remains authoritative.
class CharacterPresentation extends StatelessWidget {
  final PresentationState state;
  const CharacterPresentation({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
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
          Text(identity.displayName, style: TextStyle(color: t.text, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(identity.role, style: TextStyle(color: t.mutedText, fontSize: 10, letterSpacing: .5)),
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
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final warning = state == 'WARNING';
    final complete = state == 'COMPLETE';
    final accent = warning ? t.warning : complete ? t.success : t.primary;
    return Semantics(label: 'Dharen character state', value: state, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: accent.withValues(alpha: .10), borderRadius: BorderRadius.circular(999), border: Border.all(color: accent.withValues(alpha: .35))),
      child: Text(state, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: accent)),
    ));
  }
}
