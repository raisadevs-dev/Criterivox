import 'dart:math' as math;
import 'character_visual_profile.dart';

/// Produces deterministic SVG/vector-frame descriptions in memory for the
/// current app session. The renderer can consume these frames without making
/// image files part of the architecture.
class GeneratedVectorAnimation {
  final CharacterVisualProfile profile;
  final int sessionSeed;
  const GeneratedVectorAnimation({required this.profile, required this.sessionSeed});

  String svgFrame({required String state, required int frame, int frameCount = 8}) {
    final safeCount = frameCount < 2 ? 2 : frameCount;
    final phase = ((sessionSeed.abs() + frame * 97) % 100000) / 100000 * math.pi * 2;
    final lift = math.sin(phase) * (state.toUpperCase() == 'IDLE' ? 1.2 : 2.6);
    final glow = .10 + .08 * (.5 + .5 * math.sin(phase * 2));
    final accent = _hex(profile.accent.value);
    final body = _hex(profile.body.value);
    final hair = _hex(profile.hair.value);
    final face = _hex(profile.face.value);
    return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 238 286" width="238" height="286">
<g transform="translate(119 ${151 + lift})">
 <ellipse cx="0" cy="116" rx="63" ry="10" fill="$accent" opacity="${glow.toStringAsFixed(3)}"/>
 <path d="M-25 48 L-8 48 L-12 102 L-31 102 Z M8 48 L25 48 L31 102 L12 102 Z" fill="$ {_clean(body)}"/>
 <path d="M-42 -36 Q0 -48 42 -36 L31 50 Q0 61 -31 50 Z" fill="$body"/>
 <ellipse cx="0" cy="-79" rx="39" ry="43" fill="$profileFace"/>
 <path d="M-42 -92 Q0 -119 42 -86 Q27 -104 0 -106 Q-29 -103 -42 -92Z" fill="$hair"/>
 <path d="M-17 -36 L0 42 L17 -36" fill="none" stroke="$accent" stroke-width="3" opacity=".8"/>
 <circle cx="0" cy="-132" r="${(1.2 + glow * 3).toStringAsFixed(2)}" fill="$accent"/>
</g>
</svg>'''.replace(r'$ {_clean(body)}', body).replace(r'$profileFace', face);
  }

  String _hex(int value) => '#${(value & 0xffffff).toRadixString(16).padLeft(6, '0')}';
}
