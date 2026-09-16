import 'package:flutter/material.dart';

import 'character/character_runtime_flutter.dart';
import 'presentation/presentation_state.dart';
import 's8_character_details.dart';
import 's8_presentation_state.dart';

/// S8 presentation identity: canonical character renderer + reference-driven
/// costume/tool details + an inspectable profile card.
class S8CharacterPresentation extends StatefulWidget {
  final S8CharacterState character;
  final bool compact;

  const S8CharacterPresentation({super.key, required this.character, this.compact = false});

  @override
  State<S8CharacterPresentation> createState() => _S8CharacterPresentationState();
}

class _S8CharacterPresentationState extends State<S8CharacterPresentation> {
  bool _profileOpen = false;
  Offset _profileOffset = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    final state = PresentationState(
      agentId: widget.character.name.toLowerCase(),
      characterState: widget.character.activity.name.toUpperCase(),
      active: widget.character.activity != S8ActivityState.idle,
      reducedMotion: false,
      prominence: 1,
    );
    final width = widget.compact ? 170.0 : 250.0;
    final height = widget.compact ? 235.0 : 300.0;

    return Semantics(
      container: true,
      label: '${widget.character.name}, ${widget.character.role}',
      value: widget.character.activityLabel,
      hint: 'Tap to open the character profile. Profile can be dragged.',
      button: true,
      child: GestureDetector(
        onTap: () => setState(() => _profileOpen = !_profileOpen),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(widget.compact ? 8 : 12),
                child: Column(children: [
                  SizedBox(
                    width: width,
                    height: height,
                    child: Stack(children: [
                      Positioned.fill(
                        child: CharacterRuntimeView(
                          characterId: state.agentId,
                          state: state.characterState,
                          reducedMotion: state.reducedMotion,
                          width: width,
                          height: height,
                        ),
                      ),
                      Positioned.fill(
                        child: S8CharacterDetails(
                          characterId: state.agentId,
                          state: state.characterState,
                          width: width,
                          height: height,
                        ),
                      ),
                    ]),
                  ),
                  Text(widget.character.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(widget.character.role),
                  const SizedBox(height: 4),
                  Text(widget.character.visualMetaphor, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 7),
                  Chip(label: Text(widget.character.activityLabel)),
                ]),
              ),
            ),
            if (_profileOpen)
              Positioned(
                left: _profileOffset.dx,
                top: _profileOffset.dy,
                child: GestureDetector(
                  onPanUpdate: (details) => setState(() => _profileOffset += details.delta),
                  onTap: () {},
                  child: _ProfileCard(character: widget.character, onClose: () => setState(() => _profileOpen = false)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final S8CharacterState character;
  final VoidCallback onClose;
  const _ProfileCard({required this.character, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final profile = _profiles[character.name.toLowerCase()] ?? const _CharacterProfile(
      personality: 'Thoughtful · methodical',
      skills: ['Research', 'Inspection', 'Communication'],
      appearance: 'Functional research attire',
      quote: 'Inspect the evidence before the conclusion.',
    );
    return Material(
      elevation: 18,
      color: const Color(0xFF071522),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 285,
        constraints: const BoxConstraints(maxHeight: 360),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: character.accent.withValues(alpha: .72)),
          boxShadow: [BoxShadow(color: character.accent.withValues(alpha: .16), blurRadius: 22)],
        ),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(character.name.toUpperCase(), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: 1.3))),
              IconButton(tooltip: 'Close profile', onPressed: onClose, icon: const Icon(Icons.close, size: 18)),
            ]),
            Text(character.role, style: TextStyle(color: character.accent, fontWeight: FontWeight.w600)),
            const Divider(height: 20),
            _profileRow('PERSONALITY', profile.personality),
            _profileRow('SKILLS', profile.skills.join('\n')),
            _profileRow('APPEARANCE', profile.appearance),
            const SizedBox(height: 8),
            Text('“${profile.quote}”', style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.drag_indicator, size: 16, color: character.accent),
              const SizedBox(width: 5),
              const Expanded(child: Text('Grab and move this profile card. It stays attached to the character panel.', style: TextStyle(fontSize: 11))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _profileRow(String title, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RichText(text: TextSpan(children: [
          TextSpan(text: '$title\n', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD7B66D))),
          TextSpan(text: value, style: const TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.35)),
        ])),
      );
}

class _CharacterProfile {
  final String personality;
  final List<String> skills;
  final String appearance;
  final String quote;
  const _CharacterProfile({required this.personality, required this.skills, required this.appearance, required this.quote});
}

const _profiles = <String, _CharacterProfile>{
  'medrus': _CharacterProfile(
    personality: 'Analytical · Persistent · Methodical · Thoughtful · Calm',
    skills: ['Research Design', 'Data Analysis', 'Experimentation', 'Verification'],
    appearance: 'Mature, composed, practical layered coat, dark bodysuit, neck cloth, glasses, research pendant and evidence slate.',
    quote: 'Evidence is not the end. It is the beginning of understanding.',
  ),
  'epistre': _CharacterProfile(
    personality: 'Wise · Curious · Patient · Compassionate · Thoughtful',
    skills: ['Historical Analysis', 'Pattern Recognition', 'Cross-Cultural Understanding', 'Knowledge Synthesis'],
    appearance: 'Elegant scholarly layered coat, dark inner suit, neck stole, glasses, star/compass pendant and knowledge tablet.',
    quote: 'The past is not behind us. It is a library, and I help you read it.',
  ),
  'veridat': _CharacterProfile(
    personality: 'Analytical · Calm · Persistent · Thoughtful · Trustworthy',
    skills: ['Data Verification', 'Source Tracing', 'Pattern Validation', 'Risk Analysis'],
    appearance: 'Refined white verification coat, fitted dark bodysuit, high neck cloth, glasses, verification insignia and evidence scanner.',
    quote: 'Evidence is not about proving you right. It is about finding what is real.',
  ),
};
