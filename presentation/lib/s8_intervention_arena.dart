import 'package:flutter/material.dart';

/// Human-facing intervention surface. It structures a challenge but never
/// decides truth or silently authorizes a consequential operation.
class S8InterventionArena extends StatefulWidget {
  final String? targetArtifactId;
  const S8InterventionArena({super.key, this.targetArtifactId});

  @override
  State<S8InterventionArena> createState() => _S8InterventionArenaState();
}

class _S8InterventionArenaState extends State<S8InterventionArena> {
  final contextController = TextEditingController();
  final alternativeController = TextEditingController();
  bool authorization = false;
  bool submitted = false;

  @override
  void dispose() {
    contextController.dispose();
    alternativeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Evidence Challenge Arena', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(widget.targetArtifactId == null ? 'Select an artifact before challenging it.' : 'Target: ${widget.targetArtifactId}'),
          const Divider(height: 28),
          TextField(controller: contextController, maxLines: 4, decoration: const InputDecoration(labelText: 'Evidence / context supplied by the human', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: alternativeController, maxLines: 3, decoration: const InputDecoration(labelText: 'Proposed alternative path or correction', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: authorization,
            onChanged: (value) => setState(() => authorization = value ?? false),
            title: const Text('I explicitly authorize a consequential re-evaluation'),
            subtitle: const Text('Authorization is separate from the challenge and does not assert that the proposed correction is true.'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: widget.targetArtifactId == null || contextController.text.trim().isEmpty ? null : () => setState(() => submitted = true),
            icon: const Icon(Icons.send),
            label: const Text('Record structured challenge'),
          ),
          if (submitted) ...[
            const SizedBox(height: 14),
            const ListTile(leading: Icon(Icons.check_circle_outline), title: Text('Challenge prepared'), subtitle: Text('The presentation has captured target, human context, alternative, and authorization state. The authoritative S8 coordinator must perform and record re-evaluation.')),
          ],
        ]),
      ),
    );
  }
}
