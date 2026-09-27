import 'dart:math' as math;

import 'character_visual_profile.dart';

/// Produces deterministic SVG/vector-frame descriptions in memory for the
/// current app session. No PNG/GIF files are required.
class GeneratedVectorAnimation {
  final CharacterVisualProfile profile;
  final int sessionSeed;

  const GeneratedVectorAnimation({
    required this.profile,
    required this.sessionSeed,
  });

  String svgFrame({
    required String state,
    required int frame,
    int frameCount = 8,
  }) {
    final count = frameCount < 2 ? 2 : frameCount;
    final index = frame % count;
    final phase = index / count * math.pi * 2;
    final lift = math.sin(phase) * (state.toUpperCase() == 'IDLE' ? 1.2 : 2.6);
    final glow = .10 + .08 * (.5 + .5 * math.sin(phase * 2 + sessionSeed % 13));
    final accent = _hex(profile.accent.toARGB32());
    final body = _hex(profile.body.toARGB32());
    final hair = _hex(profile.hair.toARGB32());
    final face = _hex(profile.face.toARGB32());
    final trousers = _hex(profile.trousers.toARGB32());

    return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 238 286" width="238" height="286">
<g transform="translate(119 ${151 + lift})">
 <ellipse cx="0" cy="116" rx="63" ry="10" fill="$accent" opacity="${glow.toStringAsFixed(3)}"/>
 <path d="M-25 48 L-8 48 L-12 102 L-31 102 Z M8 48 L25 48 L31 102 L12 102 Z" fill="$trousers"/>
 <path d="M-42 -36 Q0 -48 42 -36 L31 50 Q0 61 -31 50 Z" fill="$body"/>
 <ellipse cx="0" cy="-79" rx="39" ry="43" fill="$face"/>
 <path d="M-42 -92 Q0 -119 42 -86 Q27 -104 0 -106 Q-29 -103 -42 -92Z" fill="$hair"/>
 <path d="M-17 -36 L0 42 L17 -36" fill="none" stroke="$accent" stroke-width="3" opacity=".8"/>
 <circle cx="0" cy="-132" r="${(1.2 + glow * 3).toStringAsFixed(2)}" fill="$accent"/>
</g>
</svg>''';
  }

  String _hex(int value) =>
      '#${(value & 0xffffff).toRadixString(16).padLeft(6, '0')}';
}
