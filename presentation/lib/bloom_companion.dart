import 'package:flutter/material.dart';
import 'character/character_identity.dart';
import 'character/session_character_animation.dart';
import 'presentation/criterivox_theme.dart';

class BloomCompanion extends StatelessWidget {
  final String location;
  final String? characterId;
  final VoidCallback? onReturnToBloom;
  final bool compact;
  const BloomCompanion({super.key, required this.location, this.characterId, this.onReturnToBloom, this.compact = false});

  String get _title {
    if (characterId != null) return CharacterIdentities.resolve(characterId!).displayName;
    switch (location) {
      case 'bloom': return 'Bloom Companion';
      case 'civilization': return 'World Companion';
      case 'home': return 'Home Companion';
      case 'level2': return 'Inspection Companion';
      case 'reasoning-room': return 'Reasoning Companion';
      default: return 'Bloom Companion';
    }
  }

  String get _message {
    if (characterId != null) {
      final identity = CharacterIdentities.resolve(characterId!);
      return '${identity.displayName} represents ${identity.role}. The underlying system work remains in Criterivox services.';
    }
    switch (location) {
      case 'bloom': return 'You are at the civilization gateway. Choose a capability or enter the world.';
      case 'civilization': return 'Explore a district, meet a worker, and follow the responsibility into its Home.';
      case 'home': return 'You are visiting a Home. Its residents anchor the responsibility shown here.';
      case 'level2': return 'You are inspecting operational meaning. Deeper technical detail stays behind explicit inspection.';
      case 'reasoning-room': return 'You are inside a deeper reasoning surface. Return through the Home when finished.';
      default: return 'I stay with you while you explore the Criterivox world.';
    }
  }

  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final width = compact ? 220.0 : 286.0;
    return Material(color: Colors.transparent, child: Container(width: width, padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(color: t.surfaceStrong.withValues(alpha: .94), borderRadius: BorderRadius.circular(18), border: Border.all(color: t.primary.withValues(alpha: .45)), boxShadow: const [BoxShadow(blurRadius: 24, spreadRadius: 1)]),
      child: Row(children: [
        SessionCharacterAnimationView(characterId: characterId ?? 'syvax', state: 'IDLE', width: compact ? 42 : 52, height: compact ? 54 : 66),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: t.text, fontWeight: FontWeight.w800, fontSize: compact ? 9.5 : 10.5)),
          const SizedBox(height: 3),
          Text(_message, maxLines: compact ? 2 : 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: t.mutedText, fontSize: compact ? 8 : 9, height: 1.3)),
          if (onReturnToBloom != null) ...[const SizedBox(height: 4), InkWell(onTap: onReturnToBloom, child: Text('Return to Bloom', style: TextStyle(color: t.primary, fontSize: 8.5, fontWeight: FontWeight.w700)))]
        ]))
      ]),
    ));
  }
}