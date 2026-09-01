import 'package:flutter/material.dart';

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
    if (text.isEmpty || widget.busy) return;
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Syvax, human-system dialogue host',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Syvax', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Tell Criterivox what you want to do.'),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'What do you want to do?',
                  hintText: 'Describe the task for the current demo.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final suggestion in suggestions)
                    ActionChip(
                      label: Text(suggestion),
                      onPressed: widget.busy
                          ? null
                          : () {
                              _controller.text = suggestion;
                              _focusNode.requestFocus();
                            },
                    ),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: widget.busy ? null : _submit,
                icon: widget.busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.arrow_upward),
                label: Text(widget.busy ? 'Working…' : 'Send to Criterivox'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
