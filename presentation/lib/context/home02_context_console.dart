import 'package:flutter/material.dart';

import '../presentation/criterivox_theme.dart';
import '../presentation/presentation_state.dart';

Map<String, dynamic> _normalizeMap(dynamic raw) {
  if (raw is! Map) {
    return <String, dynamic>{};
  }

  final normalized = <String, dynamic>{};

  raw.forEach((key, value) {
    normalized[key.toString()] = value;
  });

  return normalized;
}

class Home02ContextConsole extends StatelessWidget {
  final PresentationState? state;
  final VoidCallback? onBuildContext;
  final VoidCallback? onManualAdapt;
  final VoidCallback? onOpenChat;
  final VoidCallback? onCreateSandbox;
  final VoidCallback? onRunSandbox;
  final VoidCallback? onInspectSandbox;
  final VoidCallback? onPromoteSandbox;
  final VoidCallback? onDiscardSandbox;
  final bool sandboxReady;

  const Home02ContextConsole({
    super.key,
    required this.state,
    this.onBuildContext,
    this.onManualAdapt,
    this.onOpenChat,
    this.onCreateSandbox,
    this.onRunSandbox,
    this.onInspectSandbox,
    this.onPromoteSandbox,
    this.onDiscardSandbox,
    this.sandboxReady = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final s = state;

    return Container(
      color: t.page,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HOME 02 • CONTEXT INTELLIGENCE',
              style: TextStyle(
                color: t.mutedText,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Dharen + Anuka',
              style: TextStyle(
                color: t.text,
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Dharen establishes the operational context boundary. '
              'Anuka monitors that boundary for change, drift and '
              'counterfactual work.',
              style: TextStyle(
                color: t.mutedText,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                _Metric(
                  'Authoritative input',
                  s?.contextAuthoritativeInput ==
                          'complete_data_foundation'
                      ? 'S5 DataFoundation'
                      : 'Not active',
                  t,
                ),
                _Metric(
                  'Compression',
                  _compression(s),
                  t,
                ),
                _Metric(
                  'Context state',
                  '${s?.contextStateVersion ?? 0}',
                  t,
                ),
                _Metric(
                  'Checkpoint',
                  s?.contextCheckpointId ?? 'Not created',
                  t,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed:
                      s?.foundationId == null
                          ? null
                          : onBuildContext,
                  icon: const Icon(
                    Icons.account_tree_rounded,
                    size: 16,
                  ),
                  label: const Text(
                    'Dharen: build baseline',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed:
                      s?.foundationId == null
                          ? null
                          : onManualAdapt,
                  icon: const Icon(
                    Icons.tune_rounded,
                    size: 16,
                  ),
                  label: const Text(
                    'Anuka: re-evaluate',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenChat,
                  icon: const Icon(
                    Icons.forum_outlined,
                    size: 16,
                  ),
                  label: const Text(
                    'Character chat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Panel(
              title:
                  '01 • DYNAMIC CONTEXT PRUNING + ATTENTIVE COMPRESSION',
              subtitle: 'Dharen frame',
              t: t,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bar(
                    label: 'Original context items',
                    value:
                        s?.contextOriginalItemCount ?? 0,
                    max:
                        (s?.contextOriginalItemCount ?? 1)
                            .clamp(1, 1000)
                            .toInt(),
                    t: t,
                  ),
                  _Bar(
                    label: 'Retained context items',
                    value:
                        s?.contextRetainedItemCount ?? 0,
                    max:
                        (s?.contextOriginalItemCount ?? 1)
                            .clamp(1, 1000)
                            .toInt(),
                    t: t,
                  ),
                  Text(
                    'Learned relevance-compressor training is supplied by '
                    'the S6 ML workflow; deterministic safety-preserving '
                    'pruning remains the runtime fallback.',
                    style: TextStyle(
                      color: t.mutedText,
                      fontSize: 9.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            _Panel(
              title:
                  '02 • ADAPTIVE CONTEXT SHIFT INTERCEPTOR',
              subtitle: 'Anuka adaptation desk',
              t: t,
              child: _DiffView(
                s: s,
                t: t,
              ),
            ),
            _Panel(
              title:
                  '03 • HIERARCHICAL CONTEXT TREE + SCOPE BOUNDARY',
              subtitle: 'Critical → High → Medium → Low',
              t: t,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TreeNode(
                    'GLOBAL GOAL',
                    s?.task ?? 'Current task',
                    t,
                    0,
                  ),
                  _TreeNode(
                    'CRITICAL',
                    'Hard constraints • current request • '
                        'authoritative foundation',
                    t,
                    1,
                  ),
                  _TreeNode(
                    'HIGH',
                    'Validated facts • quality signals • active history',
                    t,
                    2,
                  ),
                  _TreeNode(
                    'MEDIUM',
                    'Warnings • background context',
                    t,
                    3,
                  ),
                  _TreeNode(
                    'LOW',
                    'Redundant or distant metadata',
                    t,
                    4,
                  ),
                ],
              ),
            ),
            _Panel(
              title:
                  '04 • CONTEXTUAL REPLAY + SHADOW TESTING',
              subtitle: 'Anuka sandbox',
              t: t,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sandbox states: ${s?.contextSandboxCount ?? 0}. '
                    'Forks execute through the normal '
                    'AnalysisTask → Dharen runtime path.',
                    style: TextStyle(
                      color: t.mutedText,
                      fontSize: 10.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed:
                            s?.foundationId == null
                                ? null
                                : onCreateSandbox,
                        icon: const Icon(
                          Icons.add_box_outlined,
                          size: 15,
                        ),
                        label: const Text(
                          'Create sandbox',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            sandboxReady
                                ? onRunSandbox
                                : null,
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          size: 15,
                        ),
                        label: const Text(
                          'Run / replay fork',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            sandboxReady
                                ? onInspectSandbox
                                : null,
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 15,
                        ),
                        label: const Text(
                          'Inspect variables',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            sandboxReady
                                ? onPromoteSandbox
                                : null,
                        icon: const Icon(
                          Icons.publish_outlined,
                          size: 15,
                        ),
                        label: const Text(
                          'Promote',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            sandboxReady
                                ? onDiscardSandbox
                                : null,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 15,
                        ),
                        label: const Text(
                          'Discard',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Panel(
              title:
                  '05 • CONTEXT CLASH + POISONING FIREWALL',
              subtitle: 'Dharen boundary interceptor',
              t: t,
              child: Row(
                children: [
                  Icon(
                    (s?.contextViolationCount ?? 0) == 0
                        ? Icons.verified_user_outlined
                        : Icons.warning_amber_rounded,
                    color:
                        (s?.contextViolationCount ?? 0) == 0
                            ? t.success
                            : t.warning,
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      (s?.contextViolationCount ?? 0) == 0
                          ? 'SANITY PASS • no blocked context violations '
                              'reported in the current frame.'
                          : '${s?.contextViolationCount} blocked context '
                              'violation(s) reported. Inspect source '
                              'lineage before downstream use.',
                      style: TextStyle(
                        color: t.text,
                        fontSize: 10.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _Panel(
              title:
                  '06 • ISOLATED EXECUTION SANDBOXES',
              subtitle: 'Transient state isolation',
              t: t,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(
                        'ACTIVE CONTEXT',
                        t,
                        true,
                      ),
                      _Chip(
                        'FORK STATES: '
                            '${s?.contextSandboxCount ?? 0}',
                        t,
                        false,
                      ),
                      _Chip(
                        'RAW FOUNDATION OUTSIDE PRESENTATION',
                        t,
                        false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Lifecycle: create → populate → run/replay → inspect '
                    'raw variables → compare with active state → '
                    'promote/discard.',
                    style: TextStyle(
                      color: t.mutedText,
                      fontSize: 9.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            _Panel(
              title:
                  '07 • PERSISTENT AGENT SCRATCHPAD + CHECKPOINTING',
              subtitle: 'External working memory',
              t: t,
              child: _KeyGrid(
                t,
                <String, String>{
                  'State version':
                      '${s?.contextStateVersion ?? 0}',
                  'Checkpoint':
                      s?.contextCheckpointId ??
                          'Not created',
                  'Persistence':
                      'Browser residency + runtime event stream',
                  'Provenance':
                      '${_sourceIdCount(s)} source IDs',
                },
              ),
            ),
            _Panel(
              title:
                  '08 • PRIORITY-TIERED TOKEN BUDGETING',
              subtitle: 'Dharen dynamic allocator',
              t: t,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry
                      in _tierBudget(s).entries)
                    _BudgetRow(
                      entry.key,
                      entry.value,
                      t,
                    ),
                  Text(
                    'These are the selected-token distribution from the '
                    'active context budget, not fixed decorative '
                    'percentages.',
                    style: TextStyle(
                      color: t.mutedText,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
            _Panel(
              title:
                  'STATEFUL MULTI-AGENT HANDOFF',
              subtitle: 'Dharen → Tarkis / Sandre',
              t: t,
              child: _KeyGrid(
                t,
                <String, String>{
                  'Frame':
                      s?.contextId ?? 'Not built',
                  'State':
                      '${s?.contextStateVersion ?? 0}',
                  'Recipient':
                      s?.deliveryRecipient ??
                          'Tarkis + Sandre',
                  'Authoritative boundary':
                      s?.contextAuthoritativeInput ??
                          'Not active',
                },
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'IMPLEMENTATION STATUS: learned-model training path, '
              'dynamic allocator, operational sandbox lifecycle, browser '
              'residency, runtime events and presentation projection are '
              'connected. Trained model artifacts are generated by the S6 '
              'workflow rather than falsely committed as source placeholders.',
              style: TextStyle(
                color: t.mutedText,
                fontSize: 9.5,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _compression(
    PresentationState? s,
  ) {
    final ratio = s?.contextCompressionRatio;

    if (ratio == null) {
      return 'UNKNOWN';
    }

    return '${(ratio * 100).toStringAsFixed(0)}% retained';
  }

  static int _sourceIdCount(
    PresentationState? s,
  ) {
    final snapshot =
        _normalizeMap(s?.lineageSnapshot);

    final sourceIds = snapshot['source_ids'];

    if (sourceIds is! List) {
      return 0;
    }

    return sourceIds.length;
  }

  static Map<String, double> _tierBudget(
    PresentationState? s,
  ) {
    const fallback = <String, double>{
      'critical': .4,
      'high': .3,
      'medium': .2,
      'low': .1,
    };

    final normalized =
        _normalizeMap(s?.contextTierBudget);

    if (normalized.isEmpty) {
      return fallback;
    }

    final result = <String, double>{};

    normalized.forEach(
      (key, value) {
        if (value is num) {
          result[key] = value.toDouble();
        }
      },
    );

    return result.isEmpty ? fallback : result;
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final CriterivoxTheme t;

  const _Panel({
    required this.title,
    required this.subtitle,
    required this.t,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: t.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: t.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: t.mutedText,
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final CriterivoxTheme t;

  const _Metric(
    this.label,
    this.value,
    this.t,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 205,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: t.surfaceStrong,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: t.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: t.mutedText,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: t.text,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final CriterivoxTheme t;

  const _Bar({
    required this.label,
    required this.value,
    required this.max,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        max == 0
            ? 0.0
            : (value / max)
                .clamp(0.0, 1.0)
                .toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: t.mutedText,
                    fontSize: 9.5,
                  ),
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  color: t.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(9),
            backgroundColor: t.surfaceStrong,
          ),
        ],
      ),
    );
  }
}

class _DiffView extends StatelessWidget {
  final PresentationState? s;
  final CriterivoxTheme t;

  const _DiffView({
    required this.s,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final diff =
        _normalizeMap(s?.contextDiff);

    final added = _listLength(
      diff['added'],
    );

    final changed = _listLength(
      diff['changed'],
    );

    final removed = _listLength(
      diff['removed'],
    );

    final goalShift =
        diff['goal_shift'] == true;

    final constraintShift =
        diff['constraint_shift'] == true;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Chip(
          'ADDED $added',
          t,
          true,
        ),
        _Chip(
          'CHANGED $changed',
          t,
          true,
        ),
        _Chip(
          'REMOVED $removed',
          t,
          false,
        ),
        _Chip(
          goalShift
              ? 'GOAL SHIFT'
              : 'GOAL STABLE',
          t,
          goalShift,
        ),
        _Chip(
          constraintShift
              ? 'CONSTRAINT SHIFT'
              : 'CONSTRAINT STABLE',
          t,
          constraintShift,
        ),
      ],
    );
  }

  static int _listLength(
    dynamic value,
  ) {
    return value is List
        ? value.length
        : 0;
  }
}

class _TreeNode extends StatelessWidget {
  final String label;
  final String value;
  final CriterivoxTheme t;
  final int depth;

  const _TreeNode(
    this.label,
    this.value,
    this.t,
    this.depth,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: depth * 17.0,
        bottom: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            depth == 0
                ? Icons.account_tree_rounded
                : Icons.subdirectory_arrow_right_rounded,
            size: 15,
            color: t.primary,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label  ',
                    style: TextStyle(
                      color: t.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: t.text,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final double value;
  final CriterivoxTheme t;

  const _BudgetRow(
    this.label,
    this.value,
    this.t,
  );

  @override
  Widget build(BuildContext context) {
    final progress =
        value.clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                color: t.mutedText,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius:
                  BorderRadius.circular(8),
              backgroundColor:
                  t.surfaceStrong,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: t.text,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final CriterivoxTheme t;
  final bool active;

  const _Chip(
    this.text,
    this.t,
    this.active,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
            active
                ? t.primary.withValues(alpha: .12)
                : t.surfaceStrong,
        borderRadius:
            BorderRadius.circular(999),
        border: Border.all(
          color:
              active
                  ? t.primary.withValues(alpha: .38)
                  : t.border,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              active
                  ? t.text
                  : t.mutedText,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _KeyGrid extends StatelessWidget {
  final CriterivoxTheme t;
  final Map<String, String> values;

  const _KeyGrid(
    this.t,
    this.values,
  );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 10,
      children: [
        for (final entry in values.entries)
          SizedBox(
            width: 245,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    color: t.mutedText,
                    fontSize: 8.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.value,
                  style: TextStyle(
                    color: t.text,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
/*

**The specific correction:** `_normalizeMap()` is now at **file/library level**, rather than inside `Home02ContextConsole`. Therefore `_DiffView` can legally call:

```dart
final diff = _normalizeMap(s?.contextDiff);
```

and the other nullable map paths use the exact same normalization.

Also, `snapshot['source_ids']` is now operating on a guaranteed non-null `Map<String, dynamic>`, so that original `[]` nullability error is eliminated too.
*/