
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 's8_authority.dart';
import 's8_human_authority.dart';

class S8HumanAuthorityPanel extends StatefulWidget {
  final S8HumanActionPanelModel model;
  final S8HumanAuthorityController controller;
  final ValueChanged<S8HumanActionResult>? onAction;

  const S8HumanAuthorityPanel({
    super.key,
    required this.model,
    required this.controller,
    this.onAction,
  });

  @override
  State<S8HumanAuthorityPanel> createState() =>
      _S8HumanAuthorityPanelState();
}

class _S8HumanAuthorityPanelState
    extends State<S8HumanAuthorityPanel> {
  String? _message;
  bool _busy = false;

  Future<void> _run(S8HumanDecision decision) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final controller = widget.controller;

    final S8HumanActionResult result;

    switch (decision) {
      case S8HumanDecision.inspect:
        result = await controller.inspect(
          widget.model.artifact.id,
        );
        break;

      case S8HumanDecision.provideContext:
        result = await controller.provideContext(
          widget.model.artifact.id,
        );
        break;

      case S8HumanDecision.challenge:
        await controller.challenge(
          'Human review requested',
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _busy = false;
          _message = 'Challenge submitted';
        });
        return;

      case S8HumanDecision.accept:
        result = await controller.accept(
          widget.model.artifact.id,
        );
        break;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
      _message = result.message;
    });

    widget.onAction?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pan_tool_alt_outlined,
                  color: accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'HUMAN AUTHORITY',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.model.artifact.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${widget.model.artifact.status}',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.model.allowedActions
                  .map(
                    (action) => OutlinedButton.icon(
                      onPressed:
                          _busy ? null : () => _run(action),
                      icon: Icon(
                        _icon(action),
                        size: 16,
                      ),
                      label: Text(_label(action)),
                    ),
                  )
                  .toList(),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                style: TextStyle(color: accent),
              ),
            ],
            if (widget.model.synthetic) ...[
              const SizedBox(height: 8),
              const Text(
                'Synthetic demonstration state',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  String _label(S8HumanDecision action) {
    switch (action) {
      case S8HumanDecision.inspect:
        return 'Inspect';
      case S8HumanDecision.provideContext:
        return 'Provide context';
      case S8HumanDecision.challenge:
        return 'Challenge';
      case S8HumanDecision.accept:
        return 'Accept';
    }
  }

  IconData _icon(S8HumanDecision action) {
    switch (action) {
      case S8HumanDecision.inspect:
        return Icons.visibility_outlined;
      case S8HumanDecision.provideContext:
        return Icons.add_comment_outlined;
      case S8HumanDecision.challenge:
        return Icons.report_problem_outlined;
      case S8HumanDecision.accept:
        return Icons.check_circle_outline;
    }
  }
}