import 'package:flutter/material.dart';

/// Standalone S8 presentation surface. It renders authoritative artifact/event
/// summaries supplied by the host; it does not perform evidence computation.
class S8EvidenceBureauPage extends StatefulWidget {
  const S8EvidenceBureauPage({super.key});

  @override
  State<S8EvidenceBureauPage> createState() => _S8EvidenceBureauPageState();
}

class _S8EvidenceBureauPageState extends State<S8EvidenceBureauPage> {
  int room = 0;
  bool showDetails = false;

  static const rooms = <String>[
    'MEDRUS',
    'EPISTRE',
    'VERIDAT',
    'HUMAN INTERVENTION',
  ];

  static const roomDescriptions = <String>[
    'Knowledge retention · temporal retrieval · historical context',
    'Explanation · provenance · audit narrative',
    'Grounding · verification · contradiction inspection',
    'Inspect · question · challenge · intervene',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('S8 · XAI / Evidence Research Bureau'),
        actions: [
          IconButton(
            tooltip: showDetails ? 'Hide detail' : 'Show detail',
            onPressed: () => setState(() => showDetails = !showDetails),
            icon: Icon(showDetails ? Icons.visibility_off : Icons.visibility),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: room,
            onDestinationSelected: (value) => setState(() => room = value),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.history_edu_outlined),
                selectedIcon: Icon(Icons.history_edu),
                label: Text('Medrus'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_tree_outlined),
                selectedIcon: Icon(Icons.account_tree),
                label: Text('Epistre'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.verified_outlined),
                selectedIcon: Icon(Icons.verified),
                label: Text('Veridat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pan_tool_outlined),
                selectedIcon: Icon(Icons.pan_tool),
                label: Text('Human'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(rooms[room], style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(roomDescriptions[room], style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),
                _StatusBanner(room: room),
                const SizedBox(height: 16),
                if (room == 0) const _ArtifactCard(
                  title: 'Temporal knowledge',
                  subtitle: 'Bi-temporal record inspection',
                  icon: Icons.timeline,
                ),
                if (room == 1) const _ArtifactCard(
                  title: 'Explanation provenance',
                  subtitle: 'Trace artifact → source → process',
                  icon: Icons.route,
                ),
                if (room == 2) const _ArtifactCard(
                  title: 'Verification boundary',
                  subtitle: 'Evidence, contradiction and limitation states',
                  icon: Icons.fact_check,
                ),
                if (room == 3) ...[
                  const _ArtifactCard(
                    title: 'Human intervention',
                    subtitle: 'Challenges and questions must become recorded events',
                    icon: Icons.pan_tool,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.question_mark),
                    label: const Text('Record question / challenge'),
                  ),
                ],
                if (showDetails) ...[
                  const SizedBox(height: 16),
                  const _ArtifactCard(
                    title: 'Authoritative state',
                    subtitle: 'Presentation consumes artifacts/events/state. No visual state is treated as computational truth.',
                    icon: Icons.lock_outline,
                  ),
                  const _ArtifactCard(
                    title: 'Integrity',
                    subtitle: 'Artifact content hashes and provenance references are inspectable.',
                    icon: Icons.security,
                  ),
                  const _ArtifactCard(
                    title: 'Boundary',
                    subtitle: 'S8 remains portable and does not require Syvax.',
                    icon: Icons.account_tree_outlined,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final int room;
  const _StatusBanner({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.visibility_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                room == 3
                    ? 'Human authority is active. Inspect and challenge the evidence boundary.'
                    : 'Inspect authoritative S8 artifacts and their provenance. Uncertainty remains explicit.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtifactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _ArtifactCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
