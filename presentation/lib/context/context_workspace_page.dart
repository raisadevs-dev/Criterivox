import 'package:flutter/material.dart';
import '../presentation/presentation_state.dart';
import '../presentation/criterivox_theme.dart';

class ContextWorkspacePage extends StatelessWidget {
  final PresentationState? state;
  final VoidCallback onBuildContext;
  final VoidCallback onOpenChat;
  const ContextWorkspacePage({super.key, required this.state, required this.onBuildContext, required this.onOpenChat});

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final hasContext = state?.contextId != null;
    final dimensions = state?.contextDimensions ?? const <String>[];
    final missing = state?.contextMissingDimensions ?? const <String>[];
    return Container(color: t.page, child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CONTEXT WORKSPACE', style: TextStyle(color: t.mutedText, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
      const SizedBox(height: 6),
      Text('Context Engine', style: TextStyle(color: t.text, fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text('Structure context before interpretation. Unknowns remain visible instead of being quietly promoted to facts.', style: TextStyle(color: t.mutedText, fontSize: 12, height: 1.5)),
      const SizedBox(height: 20),
      Wrap(spacing: 12, runSpacing: 12, children: [
        _Metric(label: 'S5 Material Set', value: state?.foundationMaterialSetId ?? 'Not selected', t: t),
        _Metric(label: 'Context ID', value: state?.contextId ?? 'Not built', t: t),
        _Metric(label: 'Baseline', value: state?.contextBaselineStatus ?? 'UNKNOWN', t: t),
      ]),
      const SizedBox(height: 18),
      Row(children: [
        FilledButton.icon(onPressed: state?.foundationId == null ? null : onBuildContext, icon: const Icon(Icons.account_tree_rounded, size: 17), label: const Text('Build context from S5 material')),
        const SizedBox(width: 10),
        OutlinedButton.icon(onPressed: onOpenChat, icon: const Icon(Icons.forum_outlined, size: 17), label: const Text('Character interaction')),
      ]),
      const SizedBox(height: 24),
      _Section(title: 'CONTEXT OVERVIEW', child: _KeyValueGrid(t: t, values: {
        'Context state': hasContext ? 'IMPLEMENTED' : 'WAITING FOR S5 MATERIAL',
        'Normalization': '${state?.contextNormalizationCount ?? 0} structural operation(s)',
        'Interpretation': state?.contextInterpretationId ?? 'Not available',
        'Evidence boundary': 'Observed / derived / assumed / simulated / hypothetical remain distinct',
      })),
      const SizedBox(height: 14),
      _Section(title: 'CONTEXT DIMENSIONS', child: Wrap(spacing: 8, runSpacing: 8, children: [
        for (final item in const ['content', 'creator', 'platform', 'temporal', 'audience', 'environment']) _Pill(label: item, active: dimensions.contains(item), t: t),
      ])),
      const SizedBox(height: 14),
      _Section(title: 'MISSING CONTEXT', child: missing.isEmpty && hasContext ? Text('No dimension is currently marked missing by this structural context record.', style: TextStyle(color: t.mutedText, fontSize: 11)) : Wrap(spacing: 8, runSpacing: 8, children: [for (final item in missing) _Pill(label: item, active: false, t: t)])),
      const SizedBox(height: 14),
      _Section(title: 'CONTEXTUAL BASELINE', child: _KeyValueGrid(t: t, values: {
        'Baseline ID': state?.contextBaselineId ?? 'Not created',
        'Status': state?.contextBaselineStatus ?? 'UNKNOWN',
        'Method': 'Representation / comparison boundary only',
        'Limitation': 'Empirically validated baseline-selection method is not established',
      })),
      const SizedBox(height: 14),
      _Section(title: 'INTERPRETATION', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(state?.message ?? 'No contextual interpretation has been produced yet.', style: TextStyle(color: t.text, fontSize: 12, height: 1.5)),
        const SizedBox(height: 10),
        if ((state?.contextUncertainty ?? const []).isNotEmpty) Text('UNCERTAINTY  ${state!.contextUncertainty.join(' • ')}', style: TextStyle(color: t.mutedText, fontSize: 10, height: 1.5)),
        if ((state?.contextLimitations ?? const []).isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('LIMITATIONS  ${state!.contextLimitations.join(' • ')}', style: TextStyle(color: t.mutedText, fontSize: 10, height: 1.5)),
        ],
      ])),
      const SizedBox(height: 14),
      _Section(title: 'LINEAGE', child: _KeyValueGrid(t: t, values: {
        'Material Set': state?.lineageSnapshot?['material_set_id']?.toString() ?? state?.foundationMaterialSetId ?? 'Unknown',
        'Source IDs': ((state?.lineageSnapshot?['source_ids'] as List?)?.join(', ') ?? 'Unknown'),
        'Immutable': state?.lineageSnapshot?['immutable']?.toString() ?? 'false',
      })),
    ])));
  }
}

class _Metric extends StatelessWidget { final String label, value; final CriterivoxTheme t; const _Metric({required this.label, required this.value, required this.t}); @override Widget build(BuildContext context)=>Container(width:230,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:t.surfaceStrong,borderRadius:BorderRadius.circular(16),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:TextStyle(color:t.mutedText,fontSize:9,fontWeight:FontWeight.w700)),const SizedBox(height:7),Text(value,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(color:t.text,fontSize:12,fontWeight:FontWeight.w700))]); }
class _Section extends StatelessWidget { final String title; final Widget child; const _Section({required this.title,required this.child}); @override Widget build(BuildContext context){final t=CriterivoxTheme.of(context);return Container(width:double.infinity,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:t.surface,borderRadius:BorderRadius.circular(18),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:t.mutedText,fontSize:9,fontWeight:FontWeight.w700,letterSpacing:1.1)),const SizedBox(height:12),child]));}}
class _KeyValueGrid extends StatelessWidget { final CriterivoxTheme t; final Map<String,String> values; const _KeyValueGrid({required this.t,required this.values}); @override Widget build(BuildContext context)=>Wrap(spacing:24,runSpacing:10,children:[for(final item in values.entries)SizedBox(width:250,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(item.key,style:TextStyle(color:t.mutedText,fontSize:9)),const SizedBox(height:3),Text(item.value,style:TextStyle(color:t.text,fontSize:11,height:1.35))]))]); }
class _Pill extends StatelessWidget { final String label; final bool active; final CriterivoxTheme t; const _Pill({required this.label,required this.active,required this.t}); @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),decoration:BoxDecoration(color:active?t.primary.withValues(alpha:.12):t.surfaceStrong,borderRadius:BorderRadius.circular(20),border:Border.all(color:active?t.primary.withValues(alpha:.45):t.border)),child:Text(label,style:TextStyle(color:active?t.text:t.mutedText,fontSize:10,fontWeight:FontWeight.w600))); }
