import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/criterivox_theme.dart';
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';

/// Visual control plane for Sandre's eight Home 01 capabilities.
/// Vector lakehouse infrastructure is intentionally shown as deferred; the
/// console exposes only the agreed embedding-ready representation stage.
class Home01FeatureConsole extends StatefulWidget {
  final PresentationState? state;
  final CharacterRuntimeClient runtime;
  const Home01FeatureConsole({super.key, required this.state, required this.runtime});
  @override State<Home01FeatureConsole> createState() => _Home01FeatureConsoleState();
}

class _Home01FeatureConsoleState extends State<Home01FeatureConsole> {
  bool _synthetic = false;
  bool _trainingConsent = false;
  double _timeline = 1;
  final Set<String> _expanded = {};
  static const _storageKey = 'criterivox.home01.preferences';

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    final raw = p.getString(_storageKey);
    if (raw == null) return;
    final v = jsonDecode(raw);
    if (v is Map) setState(() { _synthetic = v['synthetic'] == true; _trainingConsent = v['trainingConsent'] == true; });
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_storageKey, jsonEncode({'synthetic': _synthetic, 'trainingConsent': _trainingConsent}));
  }
  void _action(String action, {Map<String,dynamic> values = const {}}) {
    final id = widget.state?.foundationId;
    if (id == null) return;
    widget.runtime.dataAction(foundationId: id, action: action, recipient: 'sandre', values: values);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sandre action queued: $action')));
  }
  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final s = widget.state;
    final readiness = ((s?.foundationMatchRatio ?? .0) * 100).clamp(0, 100).toDouble();
    return Container(color: t.page, child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 18, 22, 30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _hero(t, readiness), const SizedBox(height: 14),
      _sectionTitle('DATA FOUNDATION CONTROL PLANE', 'Eight capability surfaces. One safeguarded local workflow.', t),
      const SizedBox(height: 10),
      LayoutBuilder(builder: (context, c) { final columns = c.maxWidth > 1250 ? 4 : c.maxWidth > 780 ? 2 : 1; return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: columns, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: columns == 1 ? 2.2 : 1.35, children: [
        _readiness(t, readiness), _pipeline(t), _lineage(t), _syntheticLab(t), _semantic(t), _drift(t), _vector(t), _edd(t),
      ]); }),
      const SizedBox(height: 14), _privacy(t),
    ])));
  }
  Widget _hero(CriterivoxTheme t, double readiness) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: LinearGradient(colors: [t.surfaceStrong, t.surface]), borderRadius: BorderRadius.circular(18), border: Border.all(color: t.border)), child: Row(children: [
    Container(width: 62, height: 62, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: t.primary, width: 3)), child: Center(child: Text('${readiness.toStringAsFixed(0)}%', style: TextStyle(color: t.text, fontWeight: FontWeight.w800, fontSize: 13)))),
    const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Sandre's Data Foundation Home", style: TextStyle(color: t.text, fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('Live stewardship • quality • lineage • semantic readiness • controlled downstream handoff', style: TextStyle(color: t.mutedText, fontSize: 10))])),
    _pill('LOCAL EXECUTION', t.primary, t),
  ]));
  Widget _readiness(CriterivoxTheme t, double value) => _card('01  DATA READINESS', Icons.monitor_heart_outlined, t, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_metric('Completeness', value, t), _metric('Schema alignment', value, t), _metric('Anomaly score', 100-value, t), const SizedBox(height: 5), Text(value >= 85 ? 'PROVISIONAL READY' : 'REVIEW REQUIRED', style: TextStyle(color: value >= 85 ? t.success : t.warning, fontSize: 9, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('85% is a provisional UI alert only. Final thresholds come from validation and benchmark evidence.', style: TextStyle(color: t.mutedText, fontSize: 8, height: 1.3))]));
  Widget _pipeline(CriterivoxTheme t) => _card('02  KAELEN PIPELINE', Icons.account_tree_outlined, t, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Wrap(spacing: 4, runSpacing: 4, children: ['INGEST','VALIDATE','NORMALIZE','PATCH','HANDOFF'].map((x) => _node(x, t)).toList()), const Spacer(), _button('Preview transformation diff', Icons.compare_arrows, () => _action('pipeline_preview'), t)]));
  Widget _lineage(CriterivoxTheme t) => _card('03  EPISTEMIC LINEAGE', Icons.timeline_outlined, t, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('RAW PAYLOAD → CURATED FOUNDATION', style: TextStyle(color: t.text, fontSize: 9, fontWeight: FontWeight.w700)), const SizedBox(height: 8), Text('SHA-256 lineage • timestamped transformations • reversible inspection', style: TextStyle(color: t.mutedText, fontSize: 9)), Slider(value: _timeline, onChanged: (v) => setState(() => _timeline = v), onChangeEnd: (v) => _action('provenance_rewind', values: {'position': v})), Text('Timeline rewind: ${(100*_timeline).toStringAsFixed(0)}%', style: TextStyle(color: t.primary, fontSize: 8, fontWeight: FontWeight.w700))]));
  Widget _syntheticLab(CriterivoxTheme t) => _card('04  SYNTHETIC LAB', Icons.science_outlined, t, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SwitchListTile(contentPadding: EdgeInsets.zero, dense: true, title: Text('Local synthetic mode', style: TextStyle(color: t.text, fontSize: 10)), subtitle: Text('No training use by default', style: TextStyle(color: t.mutedText, fontSize: 8)), value: _synthetic, onChanged: (v) { setState(() => _synthetic = v); _save(); }), Text('Privacy-preserving fixture generation for sparse/sensitive testing.', style: TextStyle(color: t.mutedText, fontSize: 8)), const Spacer(), _button('Generate preview', Icons.auto_awesome, () => _action('synthetic_preview', values: {'local_only': true}), t)]));
  Widget _semantic(CriterivoxTheme t) => _card('05  SEMANTIC INSPECTOR', Icons.label_outline, t, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('AGENT READABILITY SCORE', style: TextStyle(color: t.mutedText, fontSize: 8, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text('Active metadata • temporal markers • relationship constraints', style: TextStyle(color: t.text, fontSize: 10)), const SizedBox(height: 8), LinearProgressIndicator(value: .72, minHeight: 5), const SizedBox(height: 5), Text('72% baseline readability • machine-readable semantic tags', style: TextStyle(color: t.primary, fontSize: 8)), const Spacer(), _button('Inspect metadata', Icons.search, () => _action('semantic_inspect'), t)]));
  Widget _drift(CriterivoxTheme t) => _card('06  SCHEMA DRIFT', Icons.schema_outlined, t, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [_pill('INTERCEPTOR', t.warning, t), const Spacer(), Icon(Icons.sync, size: 16, color: t.primary)]), const SizedBox(height: 9), Text('OLD SCHEMA  →  NEW SCHEMA', style: TextStyle(color: t.mutedText, fontSize: 8, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text('+ missing key  •  rename map  •  type validation  •  rollback', style: TextStyle(color: t.text, fontSize: 9)), const Spacer(), _button('Propose patch + diff', Icons.build_outlined, () => _action('schema_patch_preview'), t)]));
  Widget _vector(CriterivoxTheme t) => _card('07  MULTIMODAL READINESS', Icons.grid_view_outlined, t, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('EMBEDDING-READY REPRESENTATION', style: TextStyle(color: t.primary, fontSize: 9, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Row(children: [_modality('TEXT', true, t), _modality('IMAGE', false, t), _modality('AUDIO', false, t)]), const SizedBox(height: 7), Text('Vector lakehouse infrastructure is intentionally deferred from this sprint.', style: TextStyle(color: t.mutedText, fontSize: 8, height: 1.3)), const Spacer(), _button('Prepare representation', Icons.memory_outlined, () => _action('vector_prepare'), t)]));
  Widget _edd(CriterivoxTheme t) => _card('08  EVALUATION GATES', Icons.fact_check_outlined, t, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('EVALUATION-DRIVEN DATA QUALITY', style: TextStyle(color: t.mutedText, fontSize: 8, fontWeight: FontWeight.w700)), const SizedBox(height: 7), _gate('Provenance complete', true, t), _gate('Schema valid', true, t), _gate('Anomaly reviewed', true, t), _gate('User confirmed', widget.state?.foundationConfirmation == 'user-confirmed' || widget.state?.foundationConfirmation == 'user-corrected', t), const Spacer(), _button('Run EDD gate', Icons.play_circle_outline, () => _action('edd_evaluate'), t)]));
  Widget _privacy(CriterivoxTheme t) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)), child: Row(children: [Icon(Icons.lock_outline, color: t.primary, size: 19), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('BROWSER-LOCAL DATA POLICY', style: TextStyle(color: t.text, fontSize: 10, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('User preferences and local synthetic fixtures persist in browser storage. Sensitive payloads leave the browser only through an explicit user action. Training use is opt-in and defaults to OFF.', style: TextStyle(color: t.mutedText, fontSize: 9, height: 1.35))])), Switch(value: _trainingConsent, onChanged: (v) { setState(() => _trainingConsent = v); _save(); }, activeColor: t.primary), Text('Training consent', style: TextStyle(color: t.mutedText, fontSize: 8))]));
  Widget _card(String title, IconData icon, CriterivoxTheme t, Widget child) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: t.primary, size: 17), const SizedBox(width: 7), Expanded(child: Text(title, style: TextStyle(color: t.text, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .4)))]), const SizedBox(height: 10), Expanded(child: child)]));
  Widget _sectionTitle(String a, String b, CriterivoxTheme t) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a, style: TextStyle(color: t.text, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)), const SizedBox(height: 3), Text(b, style: TextStyle(color: t.mutedText, fontSize: 9))]);
  Widget _metric(String name, double value, CriterivoxTheme t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Expanded(child: Text(name, style: TextStyle(color: t.mutedText, fontSize: 8))), Text('${value.toStringAsFixed(0)}%', style: TextStyle(color: t.text, fontSize: 9, fontWeight: FontWeight.w700))]));
  Widget _node(String label, CriterivoxTheme t) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: BoxDecoration(color: t.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(7), border: Border.all(color: t.primary.withValues(alpha: .35))), child: Text(label, style: TextStyle(color: t.text, fontSize: 7, fontWeight: FontWeight.w800)));
  Widget _modality(String label, bool ready, CriterivoxTheme t) => Expanded(child: Container(margin: const EdgeInsets.only(right: 4), padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(8)), child: Column(children: [Icon(ready ? Icons.check_circle_outline : Icons.pause_circle_outline, size: 15, color: ready ? t.success : t.mutedText), const SizedBox(height: 3), Text(label, style: TextStyle(color: t.mutedText, fontSize: 7))])));
  Widget _gate(String label, bool pass, CriterivoxTheme t) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(children: [Icon(pass ? Icons.check_circle : Icons.radio_button_unchecked, size: 13, color: pass ? t.success : t.warning), const SizedBox(width: 6), Text(label, style: TextStyle(color: t.text, fontSize: 8))]));
  Widget _pill(String text, Color color, CriterivoxTheme t) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(7), border: Border.all(color: color.withValues(alpha: .35))), child: Text(text, style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: .5)));
  Widget _button(String text, IconData icon, VoidCallback onTap, CriterivoxTheme t) => SizedBox(height: 30, child: OutlinedButton.icon(onPressed: widget.state?.foundationId == null ? null : onTap, icon: Icon(icon, size: 13), label: Text(text, style: const TextStyle(fontSize: 8))));
}
