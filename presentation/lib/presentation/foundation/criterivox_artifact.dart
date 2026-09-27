import 'package:flutter/material.dart';
import 'criterivox_visual_tokens.dart';
import 'criterivox_status.dart';
import '../presentation/criterivox_theme.dart';

enum CriterivoxArtifactKind {
  evidence, reasoning, explanation, provenance, graph, context,
  decision, result, warning, uncertainty, research,
}

@immutable
class CriterivoxArtifact {
  final String id;
  final CriterivoxArtifactKind kind;
  final String title;
  final String? summary;
  final CriterivoxStatus status;
  final Map<String, String> metadata;
  const CriterivoxArtifact({
    required this.id, required this.kind, required this.title,
    this.summary, this.status = CriterivoxStatus.ready, this.metadata = const {},
  });
}

class CriterivoxArtifactCard extends StatelessWidget {
  final CriterivoxArtifact artifact;
  final VoidCallback? onOpen;
  const CriterivoxArtifactCard({super.key, required this.artifact, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final v = CriterivoxVisualTokens.of(context);
    return Semantics(
      button: onOpen != null,
      label: '${artifact.kind.name} artifact: ${artifact.title}',
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(v.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(v.space3),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(_icon(artifact.kind), color: t.primary, size: 18),
                SizedBox(width: v.space2),
                Expanded(child: Text(artifact.title, style: v.artifactTitle.copyWith(color: t.text))),
                CriterivoxStatusBadge(status: artifact.status),
              ]),
              if (artifact.summary != null) ...[
                SizedBox(height: v.space2),
                Text(artifact.summary!, style: TextStyle(color: t.mutedText, height: 1.4)),
              ],
              if (artifact.metadata.isNotEmpty) ...[
                SizedBox(height: v.space2),
                Wrap(spacing: v.space3, runSpacing: v.space1,
                  children: artifact.metadata.entries.map((e) =>
                    Text('${e.key}: ${e.value}', style: v.metadata.copyWith(color: t.mutedText))).toList()),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  IconData _icon(CriterivoxArtifactKind kind) => switch (kind) {
    CriterivoxArtifactKind.evidence => Icons.fact_check_outlined,
    CriterivoxArtifactKind.reasoning => Icons.account_tree_outlined,
    CriterivoxArtifactKind.explanation => Icons.lightbulb_outline,
    CriterivoxArtifactKind.provenance => Icons.link_outlined,
    CriterivoxArtifactKind.graph => Icons.hub_outlined,
    CriterivoxArtifactKind.context => Icons.layers_outlined,
    CriterivoxArtifactKind.decision => Icons.gavel_outlined,
    CriterivoxArtifactKind.result => Icons.check_circle_outline,
    CriterivoxArtifactKind.warning => Icons.warning_amber_outlined,
    CriterivoxArtifactKind.uncertainty => Icons.help_outline,
    CriterivoxArtifactKind.research => Icons.science_outlined,
  };
}