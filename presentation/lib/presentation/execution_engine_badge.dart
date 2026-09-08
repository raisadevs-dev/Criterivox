import 'package:flutter/material.dart';

import 'criterivox_theme.dart';
import 'presentation_state.dart';

/// Client-side status indicator for the execution path currently reported by
/// the runtime. It never claims a provider/model that the backend did not report.
class ExecutionEngineBadge extends StatelessWidget {
  final PresentationState? state;
  const ExecutionEngineBadge({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final engine = state?.executionEngine ?? 'Local Deterministic Runtime';
    final tier = state?.executionTier ?? 'LOCAL';
    final fallback = state?.fallbackUsed == true;
    final label = fallback ? 'Fallback · $tier' : '$engine · $tier';
    return Tooltip(
      message: state?.taskId == null
          ? 'No active task. Character runtime is ready.'
          : 'Task ${state!.taskId} · $label',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.memory_rounded, size: 14, color: fallback ? t.warning : t.primary),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: t.mutedText, fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
