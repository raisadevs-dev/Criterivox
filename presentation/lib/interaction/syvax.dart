import 'package:flutter/material.dart';

import '../character/character_frame.dart';
import '../presentation/criterivox_theme.dart';

class Syvax extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final bool busy;

  const Syvax({super.key, required this.onSubmit, this.busy = false});

  @override
  State<Syvax> createState() => _SyvaxState();
}

class _SyvaxState extends State<Syvax> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  static const suggestions = [
    'Analyze the supplied data in the provided context.',
    'Analyze these student engagement metrics.',
    'Analyze the current synthetic dataset.',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.busy) widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: Semantics(
        container: true,
        label: 'Syvax, human-system dialogue host',
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.border),
            boxShadow: [
              BoxShadow(
                color: t.primary.withValues(alpha: .08),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _SyvaxAvatar(busy: widget.busy),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Syvax', style: TextStyle(color: t.text, fontSize: 19, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Dialogue + routing', style: TextStyle(color: t.mutedText, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.busy ? t.warning : t.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('What would you like to do?', style: TextStyle(color: t.text, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                style: TextStyle(color: t.text, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Describe what you want Criterivox to do…',
                  hintStyle: TextStyle(color: t.mutedText, fontSize: 12),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final suggestion in suggestions)
                    ActionChip(
                      avatar: const Icon(Icons.auto_awesome, size: 12),
                      label: Text(suggestion, style: TextStyle(fontSize: 9.5, color: t.mutedText)),
                      backgroundColor: t.surfaceStrong,
                      side: BorderSide(color: t.border),
                      onPressed: widget.busy
                          ? null
                          : () {
                              _controller.text = suggestion;
                              _focusNode.requestFocus();
                            },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: t.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: widget.busy ? null : _submit,
                icon: widget.busy
                    ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.arrow_upward_rounded, size: 18),
                label: Text(widget.busy ? 'Working…' : 'Send to Criterivox'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyvaxAvatar extends StatelessWidget {
  final bool busy;
  const _SyvaxAvatar({required this.busy});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: AnimatedScale(
        scale: busy ? 1.05 : 1,
        duration: const Duration(milliseconds: 280),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          child: CharacterFrame(
            key: ValueKey(busy),
            asset: 'assets/characters/syvax.svg',
            index: busy ? 2 : 0,
            width: 58,
            height: 58,
          ),
        ),
      ),
    );
  }
}
