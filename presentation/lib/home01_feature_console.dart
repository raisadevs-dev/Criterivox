import 'package:flutter/material.dart';

import 'presentation/browser_residency_store.dart';
import 'presentation/criterivox_theme.dart';
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';

/// Visual control plane for Sandre's eight Home 01 capabilities.
///
/// Vector lakehouse infrastructure is intentionally deferred.
class Home01FeatureConsole extends StatefulWidget {
  final PresentationState? state;
  final CharacterRuntimeClient runtime;

  const Home01FeatureConsole({
    super.key,
    required this.state,
    required this.runtime,
  });

  @override
  State<Home01FeatureConsole> createState() => _Home01FeatureConsoleState();
}

class _Home01FeatureConsoleState extends State<Home01FeatureConsole> {
  final BrowserResidencyStore _residency = BrowserResidencyStore();

  bool _synthetic = false;
  bool _trainingConsent = false;
  double _timeline = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await _residency.load();
    final prefs = raw?['home01_preferences'];

    if (!mounted || prefs is! Map) {
      return;
    }

    setState(() {
      _synthetic = prefs['synthetic'] == true;
      _trainingConsent = prefs['trainingConsent'] == true;
    });
  }

  Future<void> _save() async {
    final raw = await _residency.load() ?? <String, dynamic>{};

    raw['home01_preferences'] = <String, dynamic>{
      'synthetic': _synthetic,
      'trainingConsent': _trainingConsent,
    };

    await _residency.save(raw);
  }

  void _action(
    String action, {
    Map<String, dynamic> values = const <String, dynamic>{},
  }) {
    final id = widget.state?.foundationId;

    if (id == null) {
      return;
    }

    widget.runtime.dataAction(
      foundationId: id,
      action: action,
      recipient: 'sandre',
      values: values,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sandre action queued: $action',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);
    final state = widget.state;

    final readiness = ((state?.foundationMatchRatio ?? 0.0) * 100)
        .clamp(0.0, 100.0)
        .toDouble();

    return Container(
      color: theme.page,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          22,
          18,
          22,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hero(theme, readiness),
            const SizedBox(height: 14),
            _sectionTitle(
              'DATA FOUNDATION CONTROL PLANE',
              'Eight capability surfaces. One safeguarded local workflow.',
              theme,
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 1250
                    ? 4
                    : constraints.maxWidth > 780
                        ? 2
                        : 1;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: columns == 1 ? 2.2 : 1.35,
                  children: [
                    _readiness(theme, readiness),
                    _pipeline(theme),
                    _lineage(theme),
                    _syntheticLab(theme),
                    _semantic(theme),
                    _drift(theme),
                    _vector(theme),
                    _edd(theme),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            _privacy(theme),
          ],
        ),
      ),
    );
  }

  Widget _hero(
    CriterivoxTheme theme,
    double readiness,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.surfaceStrong,
            theme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.primary,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '${readiness.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: theme.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sandre's Data Foundation Home",
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Live stewardship • quality • lineage • '
                  'semantic readiness • controlled downstream handoff',
                  style: TextStyle(
                    color: theme.mutedText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          _pill(
            'LOCAL EXECUTION',
            theme.primary,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _readiness(
    CriterivoxTheme theme,
    double value,
  ) {
    return _card(
      '01  DATA READINESS',
      Icons.monitor_heart_outlined,
      theme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _metric(
            'Completeness',
            value,
            theme,
          ),
          _metric(
            'Schema alignment',
            value,
            theme,
          ),
          _metric(
            'Anomaly score',
            100 - value,
            theme,
          ),
          const SizedBox(height: 5),
          Text(
            value >= 85 ? 'PROVISIONAL READY' : 'REVIEW REQUIRED',
            style: TextStyle(
              color: value >= 85 ? theme.success : theme.warning,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '85% is a provisional UI alert only. '
            'Final thresholds come from validation '
            'and benchmark evidence.',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 8,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pipeline(CriterivoxTheme theme) {
    return _card(
      '02  KAELEN PIPELINE',
      Icons.account_tree_outlined,
      theme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              'INGEST',
              'VALIDATE',
              'NORMALIZE',
              'PATCH',
              'HANDOFF',
            ].map((label) {
              return _node(label, theme);
            }).toList(),
          ),
          const Spacer(),
          _button(
            'Preview transformation diff',
            Icons.compare_arrows,
            () => _action('pipeline_preview'),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _lineage(CriterivoxTheme theme) {
    return _card(
      '03  EPISTEMIC LINEAGE',
      Icons.timeline_outlined,
      theme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RAW PAYLOAD → CURATED FOUNDATION',
            style: TextStyle(
              color: theme.text,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SHA-256 lineage • timestamped transformations • '
            'reversible inspection',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 9,
            ),
          ),
          Slider(
            value: _timeline,
            onChanged: (value) {
              setState(() {
                _timeline = value;
              });
            },
            onChangeEnd: (value) {
              _action(
                'provenance_rewind',
                values: {
                  'position': value,
                },
              );
            },
          ),
          Text(
            'Timeline rewind: '
            '${(100 * _timeline).toStringAsFixed(0)}%',
            style: TextStyle(
              color: theme.primary,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _syntheticLab(
    CriterivoxTheme theme,
  ) {
    return _card(
      '04  SYNTHETIC LAB',
      Icons.science_outlined,
      theme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              'Local synthetic mode',
              style: TextStyle(
                color: theme.text,
                fontSize: 10,
              ),
            ),
            subtitle: Text(
              'No training use by default',
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 8,
              ),
            ),
            value: _synthetic,
            onChanged: (value) {
              setState(() {
                _synthetic = value;
              });
              _save();
            },
          ),
          Text(
            'Privacy-preserving fixture generation '
            'for sparse/sensitive testing.',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 8,
            ),
          ),
          const Spacer(),
          _button(
            'Generate preview',
            Icons.auto_awesome,
            () => _action(
              'synthetic_preview',
              values: {
                'local_only': true,
              },
            ),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _semantic(
    CriterivoxTheme theme,
  ) {
    return _card(
      '05  SEMANTIC INSPECTOR',
      Icons.label_outline,
      theme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AGENT READABILITY SCORE',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Active metadata • temporal markers • '
            'relationship constraints',
            style: TextStyle(
              color: theme.text,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            value: 0.72,
            minHeight: 5,
          ),
          const SizedBox(height: 5),
          Text(
            '72% baseline readability • '
            'machine-readable semantic tags',
            style: TextStyle(
              color: theme.primary,
              fontSize: 8,
            ),
          ),
          const Spacer(),
          _button(
            'Inspect metadata',
            Icons.search,
            () => _action('semantic_inspect'),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _drift(CriterivoxTheme theme) {
    return _card(
      '06  SCHEMA DRIFT',
      Icons.schema_outlined,
      theme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _pill(
                'INTERCEPTOR',
                theme.warning,
                theme,
              ),
              const Spacer(),
              Icon(
                Icons.sync,
                size: 16,
                color: theme.primary,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'OLD SCHEMA  →  NEW SCHEMA',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '+ missing key  •  rename map  •  '
            'type validation  •  rollback',
            style: TextStyle(
              color: theme.text,
              fontSize: 9,
            ),
          ),
          const Spacer(),
          _button(
            'Propose patch + diff',
            Icons.build_outlined,
            () => _action(
              'schema_patch_preview',
            ),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _vector(CriterivoxTheme theme) {
    return _card(
      '07  MULTIMODAL READINESS',
      Icons.grid_view_outlined,
      theme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EMBEDDING-READY REPRESENTATION',
            style: TextStyle(
              color: theme.primary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _modality(
                'TEXT',
                true,
                theme,
              ),
              _modality(
                'IMAGE',
                false,
                theme,
              ),
              _modality(
                'AUDIO',
                false,
                theme,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Vector lakehouse infrastructure is intentionally '
            'deferred from this sprint.',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 8,
              height: 1.3,
            ),
          ),
          const Spacer(),
          _button(
            'Prepare representation',
            Icons.memory_outlined,
            () => _action('vector_prepare'),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _edd(CriterivoxTheme theme) {
    final confirmation = widget.state?.foundationConfirmation;

    final userConfirmed =
        confirmation == 'user-confirmed' || confirmation == 'user-corrected';

    return _card(
      '08  EVALUATION GATES',
      Icons.fact_check_outlined,
      theme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EVALUATION-DRIVEN DATA QUALITY',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          _gate(
            'Provenance complete',
            true,
            theme,
          ),
          _gate(
            'Schema valid',
            true,
            theme,
          ),
          _gate(
            'Anomaly reviewed',
            true,
            theme,
          ),
          _gate(
            'User confirmed',
            userConfirmed,
            theme,
          ),
          const Spacer(),
          _button(
            'Run EDD gate',
            Icons.play_circle_outline,
            () => _action('edd_evaluate'),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _privacy(CriterivoxTheme theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surfaceStrong,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: theme.primary,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BROWSER-LOCAL DATA POLICY',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Working-set state, feature preferences, '
                  'and runtime presentation state persist in '
                  'the same browser residency store. Sensitive '
                  'payloads leave the browser only through an '
                  'explicit user action. Training use is opt-in '
                  'and defaults to OFF.',
                  style: TextStyle(
                    color: theme.mutedText,
                    fontSize: 9,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _trainingConsent,
            onChanged: (value) {
              setState(() {
                _trainingConsent = value;
              });
              _save();
            },
          ),
          Text(
            'Training consent',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    String title,
    IconData icon,
    CriterivoxTheme theme,
    Widget child,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.primary,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
    CriterivoxTheme theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.text,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: theme.mutedText,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _metric(
    String name,
    double value,
    CriterivoxTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 8,
              ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: TextStyle(
              color: theme.text,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _node(
    String label,
    CriterivoxTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.text,
          fontSize: 7,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _modality(
    String label,
    bool ready,
    CriterivoxTheme theme,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: theme.surfaceStrong,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              ready ? Icons.check_circle_outline : Icons.pause_circle_outline,
              size: 15,
              color: ready ? theme.success : theme.mutedText,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gate(
    String label,
    bool pass,
    CriterivoxTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            pass ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 13,
            color: pass ? theme.success : theme.warning,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: theme.text,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(
    String text,
    Color color,
    CriterivoxTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 7,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _button(
    String text,
    IconData icon,
    VoidCallback onTap,
    CriterivoxTheme theme,
  ) {
    return SizedBox(
      height: 30,
      child: OutlinedButton.icon(
        onPressed: widget.state?.foundationId == null ? null : onTap,
        icon: Icon(
          icon,
          size: 13,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 8,
          ),
        ),
      ),
    );
  }
}
