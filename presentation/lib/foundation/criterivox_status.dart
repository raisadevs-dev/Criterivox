import 'package:flutter/material.dart';
import 'criterivox_visual_tokens.dart';
import '../presentation/criterivox_theme.dart';

enum CriterivoxStatus {
  loading, ready, active, waiting, error, warning, uncertain,
  complete, unavailable, simulated, planned, researchPrototype,
}

extension CriterivoxStatusLabel on CriterivoxStatus {
  String get label => switch (this) {
    CriterivoxStatus.loading => 'LOADING',
    CriterivoxStatus.ready => 'READY',
    CriterivoxStatus.active => 'ACTIVE',
    CriterivoxStatus.waiting => 'WAITING',
    CriterivoxStatus.error => 'ERROR',
    CriterivoxStatus.warning => 'WARNING',
    CriterivoxStatus.uncertain => 'UNCERTAIN',
    CriterivoxStatus.complete => 'COMPLETE',
    CriterivoxStatus.unavailable => 'UNAVAILABLE',
    CriterivoxStatus.simulated => 'SIMULATED',
    CriterivoxStatus.planned => 'PLANNED',
    CriterivoxStatus.researchPrototype => 'RESEARCH PROTOTYPE',
  };
}

class CriterivoxStatusBadge extends StatelessWidget {
  final CriterivoxStatus status;
  final String? detail;
  const CriterivoxStatusBadge({super.key, required this.status, this.detail});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final v = CriterivoxVisualTokens.of(context);
    final color = switch (status) {
      CriterivoxStatus.error || CriterivoxStatus.warning => t.warning,
      CriterivoxStatus.complete || CriterivoxStatus.ready || CriterivoxStatus.active => t.success,
      CriterivoxStatus.planned || CriterivoxStatus.simulated || CriterivoxStatus.researchPrototype => t.mutedText,
      _ => t.primary,
    };
    return Semantics(
      label: status.label + (detail == null ? '' : ': ' + detail!),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: v.space3, vertical: v.space1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(v.radiusSmall),
          border: Border.all(color: color.withValues(alpha: .55)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, size: 7, color: color),
          SizedBox(width: v.space2),
          Text(status.label, style: v.metadata.copyWith(color: color)),
          if (detail != null) ...[
            SizedBox(width: v.space2),
            Text(detail!, style: v.metadata.copyWith(color: t.mutedText)),
          ],
        ]),
      ),
    );
  }
}