import 'package:flutter/material.dart';

import '../presentation/criterivox_theme.dart';
import '../presentation/presentation_state.dart';

class ContextWorkspacePage extends StatelessWidget {
  final PresentationState? state;
  final VoidCallback onBuildContext;
  final VoidCallback onOpenChat;

  const ContextWorkspacePage({
    super.key,
    required this.state,
    required this.onBuildContext,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);
    final hasContext = state?.contextId != null;
    final dimensions = state?.contextDimensions ?? const <String>[];
    final missing = state?.contextMissingDimensions ?? const <String>[];
    final evidence = state?.evidence ?? const <Map<String,dynamic>>[];
    final completeness = _evidenceCompleteness(evidence, missing.length, state?.contextUncertainty.length ?? 0);
    final debtLevel = _debtLevel(completeness, evidence.isEmpty);
    final sources = _sourceIds(state?.lineageSnapshot);

    return Container(
      color: theme.page,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CONTEXT WORKSPACE', style: TextStyle(color: theme.mutedText, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
            const SizedBox(height: 6),
            Text('Context Engine', style: TextStyle(color: theme.text, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('The context layer is now inspectable: provenance, differences, evidence completeness, memory status and agent activity stay visible instead of becoming invisible plumbing.', style: TextStyle(color: theme.mutedText, fontSize: 12, height: 1.5)),
            const SizedBox(height: 20),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _Metric(label: 'S5 Material Set', value: state?.foundationMaterialSetId ?? 'Not selected', theme: theme),
              _Metric(label: 'Context ID', value: state?.contextId ?? 'Not built', theme: theme),
              _Metric(label: 'Baseline', value: state?.contextBaselineStatus ?? 'UNKNOWN', theme: theme),
              _Metric(label: 'Evidence completeness', value: evidence.isEmpty ? 'UNKNOWN' : '$completeness%', theme: theme),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              FilledButton.icon(onPressed: state?.foundationId == null ? null : onBuildContext, icon: const Icon(Icons.account_tree_rounded, size: 17), label: const Text('Build context from S5 material')),
              const SizedBox(width: 10),
              OutlinedButton.icon(onPressed: onOpenChat, icon: const Icon(Icons.forum_outlined, size: 17), label: const Text('Character interaction')),
            ]),
            const SizedBox(height: 24),
            _Section(title: 'CONTEXT OVERVIEW', theme: theme, child: _KeyValueGrid(theme: theme, values: {
              'Context state': hasContext ? 'IMPLEMENTED' : 'WAITING FOR S5 MATERIAL',
              'Normalization': '${state?.contextNormalizationCount ?? 0} structural operation(s)',
              'Interpretation': state?.contextInterpretationId ?? 'Not available',
              'Evidence boundary': 'Observed / derived / assumed / simulated / hypothetical remain distinct',
            })),
            const SizedBox(height: 14),
            _ProvenanceGraph(theme: theme, foundationId: state?.foundationId ?? state?.foundationMaterialSetId, contextId: state?.contextId, interpretationId: state?.contextInterpretationId, sourceIds: sources),
            const SizedBox(height: 14),
            _Section(title: 'CONTEXT DIMENSIONS', theme: theme, child: Wrap(spacing: 8, runSpacing: 8, children: [for (final item in const ['content','creator','platform','temporal','audience','environment']) _Pill(label: item, active: dimensions.contains(item), theme: theme)])),
            const SizedBox(height: 14),
            _ContextDiff(theme: theme, dimensions: dimensions, missing: missing),
            const SizedBox(height: 14),
            _EvidenceDebt(theme: theme, completeness: completeness, level: debtLevel, tags: _evidenceTags(evidence, missing.length, state?.contextUncertainty.length ?? 0)),
            const SizedBox(height: 14),
            _MemoryExpiration(theme: theme, updatedAt: state?.taskUpdatedAt),
            const SizedBox(height: 14),
            _Observability(theme: theme, activity: state?.activity ?? const <String>[]),
            const SizedBox(height: 14),
            _Handoff(theme: theme, state: state),
            const SizedBox(height: 14),
            _Section(title: 'CONTEXTUAL BASELINE', theme: theme, child: _KeyValueGrid(theme: theme, values: {
              'Baseline ID': state?.contextBaselineId ?? 'Not created',
              'Status': state?.contextBaselineStatus ?? 'UNKNOWN',
              'Method': 'Representation / comparison boundary only',
              'Limitation': 'Empirically validated baseline-selection method is not established',
            })),
            const SizedBox(height: 14),
            _Section(title: 'INTERPRETATION', theme: theme, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(state?.message ?? 'No contextual interpretation has been produced yet.', style: TextStyle(color: theme.text, fontSize: 12, height: 1.5)),
              const SizedBox(height: 10),
              if ((state?.contextUncertainty ?? const <String>[]).isNotEmpty) Text('UNCERTAINTY  ${state!.contextUncertainty.join(' • ')}', style: TextStyle(color: theme.mutedText, fontSize: 10, height: 1.5)),
              if ((state?.contextLimitations ?? const <String>[]).isNotEmpty) ...[const SizedBox(height: 6),Text('LIMITATIONS  ${state!.contextLimitations.join(' • ')}', style: TextStyle(color: theme.mutedText, fontSize: 10, height: 1.5))],
            ])),
            const SizedBox(height: 14),
            _Section(title: 'LINEAGE', theme: theme, child: _KeyValueGrid(theme: theme, values: {
              'Material Set': state?.lineageSnapshot?['material_set_id']?.toString() ?? state?.foundationMaterialSetId ?? 'Unknown',
              'Source IDs': sources.isEmpty ? 'Unknown' : sources.join(', '),
              'Immutable': state?.lineageSnapshot?['immutable']?.toString() ?? 'false',
            })),
            const SizedBox(height: 14),
            _Section(title: 'MCP-READY CAPABILITY BOUNDARY', theme: theme, child: Text('IMPLEMENTED: Criterivox now has an internal capability request/response boundary. MCP remains an adapter concern, not a domain dependency. No autonomous external tool execution is implied.', style: TextStyle(color: theme.mutedText, fontSize: 11, height: 1.5))),
          ],
        ),
      ),
    );
  }

  static List<String> _sourceIds(Map<String,dynamic>? lineage) {
    final raw = lineage?['source_ids'];
    return raw is List ? raw.whereType<String>().toList() : const <String>[];
  }

  static int _evidenceCompleteness(List<Map<String,dynamic>> evidence, int missing, int uncertainty) {
    if (evidence.isEmpty) return 0;
    final supported = evidence.where((item) => {'OBSERVED','VERIFIED','CONFIRMED','SUPPORTED'}.contains((item['status'] ?? 'UNKNOWN').toString().toUpperCase())).length;
    var result = ((supported / evidence.length) * 100).round();
    result = (result - (missing * 5).clamp(0, 30) - (uncertainty * 4).clamp(0, 20)).clamp(0, 100);
    return result;
  }

  static String _debtLevel(int completeness, bool unknown) {
    if (unknown) return 'UNKNOWN';
    if (completeness >= 80) return 'LOW';
    if (completeness >= 50) return 'MEDIUM';
    return 'HIGH';
  }

  static List<String> _evidenceTags(List<Map<String,dynamic>> evidence, int missing, int uncertainty) {
    final tags = <String>{};
    if (evidence.isEmpty) tags.add('NO_EVIDENCE');
    for (final item in evidence) {
      final status = (item['status'] ?? 'UNKNOWN').toString().toUpperCase();
      if (status == 'ASSUMED' || status == 'HYPOTHETICAL') tags.add('ASSUMPTION_OR_HYPOTHESIS');
      if (status == 'SIMULATED') tags.add('SIMULATED_EVIDENCE');
      if (!{'OBSERVED','VERIFIED','CONFIRMED','SUPPORTED','ASSUMED','HYPOTHETICAL','SIMULATED'}.contains(status)) tags.add('UNVERIFIED_EVIDENCE');
    }
    if (missing > 0) tags.add('MISSING_CONTEXT');
    if (uncertainty > 0) tags.add('UNCERTAINTY');
    return tags.toList()..sort();
  }
}

class _Metric extends StatelessWidget {
  final String label,value; final CriterivoxTheme theme;
  const _Metric({required this.label,required this.value,required this.theme});
  @override Widget build(BuildContext context)=>Container(width:210,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:theme.surfaceStrong,borderRadius:BorderRadius.circular(16),border:Border.all(color:theme.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:TextStyle(color:theme.mutedText,fontSize:9,fontWeight:FontWeight.w700)),const SizedBox(height:7),Text(value,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(color:theme.text,fontSize:12,fontWeight:FontWeight.w700))]);
}

class _Section extends StatelessWidget {
  final String title; final Widget child; final CriterivoxTheme theme;
  const _Section({required this.title,required this.child,required this.theme});
  @override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:theme.surface,borderRadius:BorderRadius.circular(18),border:Border.all(color:theme.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:theme.mutedText,fontSize:9,fontWeight:FontWeight.w700,letterSpacing:1.1)),const SizedBox(height:12),child]));
}

class _KeyValueGrid extends StatelessWidget {
  final CriterivoxTheme theme; final Map<String,String> values;
  const _KeyValueGrid({required this.theme,required this.values});
  @override Widget build(BuildContext context)=>Wrap(spacing:24,runSpacing:10,children:[for(final item in values.entries)SizedBox(width:250,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(item.key,style:TextStyle(color:theme.mutedText,fontSize:9)),const SizedBox(height:3),Text(item.value,style:TextStyle(color:theme.text,fontSize:11,height:1.35))]))]);
}

class _Pill extends StatelessWidget {
  final String label; final bool active; final CriterivoxTheme theme;
  const _Pill({required this.label,required this.active,required this.theme});
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),decoration:BoxDecoration(color:active?theme.primary.withValues(alpha:.12):theme.surfaceStrong,borderRadius:BorderRadius.circular(20),border:Border.all(color:active?theme.primary.withValues(alpha:.45):theme.border)),child:Text(label,style:TextStyle(color:active?theme.text:theme.mutedText,fontSize:10,fontWeight:FontWeight.w600)));
}

class _ProvenanceGraph extends StatelessWidget {
  final CriterivoxTheme theme; final String? foundationId,contextId,interpretationId; final List<String> sourceIds;
  const _ProvenanceGraph({required this.theme,required this.foundationId,required this.contextId,required this.interpretationId,required this.sourceIds});
  @override Widget build(BuildContext context) {
    final nodes = <String>['SOURCE',if(foundationId!=null)'DATA FOUNDATION',if(contextId!=null)'CONTEXT',if(interpretationId!=null)'INTERPRETATION'];
    return _Section(title:'CONTEXT PROVENANCE GRAPH',theme:theme,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Wrap(spacing:8,runSpacing:8,children:[for(final node in nodes)_GraphNode(label:node,theme:theme)]),
      const SizedBox(height:10),
      Text(sourceIds.isEmpty?'Source nodes are not available in the current runtime payload.':'${sourceIds.length} source node(s) → foundation → context → interpretation',style:TextStyle(color:theme.mutedText,fontSize:10.5)),
      const SizedBox(height:6),
      Text('TRACEABLE GRAPH • provenance is visible; immutability remains false until storage support is established.',style:TextStyle(color:theme.mutedText,fontSize:9)),
    ]));
  }
}

class _GraphNode extends StatelessWidget { final String label; final CriterivoxTheme theme; const _GraphNode({required this.label,required this.theme}); @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:9),decoration:BoxDecoration(color:theme.surfaceStrong,borderRadius:BorderRadius.circular(12),border:Border.all(color:theme.primary.withValues(alpha:.35))),child:Text(label,style:TextStyle(color:theme.text,fontSize:9,fontWeight:FontWeight.w700))); }

class _ContextDiff extends StatelessWidget {
  final CriterivoxTheme theme; final List<String> dimensions,missing;
  const _ContextDiff({required this.theme,required this.dimensions,required this.missing});
  @override Widget build(BuildContext context)=>_Section(title:'CONTEXT DIFF',theme:theme,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('Current context vs the structural baseline boundary',style:TextStyle(color:theme.text,fontSize:11,fontWeight:FontWeight.w700)),const SizedBox(height:9),
    Wrap(spacing:8,runSpacing:8,children:[for(final item in dimensions)_Pill(label:'+ $item',active:true,theme:theme),for(final item in missing)_Pill(label:'? $item',active:false,theme:theme)]),const SizedBox(height:8),
    Text('No prior user-defined context snapshot is present in the current contract, so semantic change is not claimed. This view exposes current additions and missing dimensions until a prior snapshot is supplied.',style:TextStyle(color:theme.mutedText,fontSize:10,height:1.45)),
  ]));
}

class _EvidenceDebt extends StatelessWidget {
  final CriterivoxTheme theme; final int completeness; final String level; final List<String> tags;
  const _EvidenceDebt({required this.theme,required this.completeness,required this.level,required this.tags});
  @override Widget build(BuildContext context)=>_Section(title:'EVIDENCE DEBT',theme:theme,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Text('$completeness%',style:TextStyle(color:theme.text,fontSize:24,fontWeight:FontWeight.w800)),const SizedBox(width:12),_Pill(label:level,active:level=='LOW',theme:theme)]),const SizedBox(height:10),
    Wrap(spacing:7,runSpacing:7,children:[for(final tag in tags)_Pill(label:tag,active:false,theme:theme)]),const SizedBox(height:8),
    Text('HEURISTIC • completeness reflects current evidence status plus missing-context and uncertainty penalties. It is not a confidence probability.',style:TextStyle(color:theme.mutedText,fontSize:9.5,height:1.4)),
  ]));
}

class _MemoryExpiration extends StatelessWidget {
  final CriterivoxTheme theme; final String? updatedAt;
  const _MemoryExpiration({required this.theme,required this.updatedAt});
  @override Widget build(BuildContext context)=>_Section(title:'CONTEXT MEMORY WITH EXPIRATION',theme:theme,child:_KeyValueGrid(theme:theme,values:{
    'Current timestamp':updatedAt??'UNKNOWN',
    'Expiration policy':'RESEARCH-GATED',
    'Status':'UNKNOWN until a validated retention / recheck rule is selected',
    'Safety rule':'No contextual knowledge is silently treated as timeless',
  }));
}

class _Observability extends StatelessWidget {
  final CriterivoxTheme theme; final List<String> activity;
  const _Observability({required this.theme,required this.activity});
  @override Widget build(BuildContext context)=>_Section(title:'AGENT OBSERVABILITY TIMELINE',theme:theme,child:activity.isEmpty?Text('No activity events have been emitted yet.',style:TextStyle(color:theme.mutedText,fontSize:10.5)):Column(crossAxisAlignment:CrossAxisAlignment.start,children:[for(final item in activity.take(12))Padding(padding:const EdgeInsets.only(bottom:7),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:7,height:7,margin:const EdgeInsets.only(top:4,right:8),decoration:BoxDecoration(shape:BoxShape.circle,color:theme.primary)),Expanded(child:Text(item,style:TextStyle(color:theme.text,fontSize:10.5,height:1.4)))]))]));
}

class _Handoff extends StatelessWidget {
  final CriterivoxTheme theme; final PresentationState? state;
  const _Handoff({required this.theme,required this.state});
  @override Widget build(BuildContext context)=>_Section(title:'CONTROLLED MULTI-AGENT HANDOFF',theme:theme,child:_KeyValueGrid(theme:theme,values:{
    'Coordination ID':state?.coordinationId??'Not emitted',
    'Members':state?.coordinationMembers.join(', ')??'Not emitted',
    'Delivery':state?.deliveryId??'Not emitted',
    'Recipient':state?.deliveryRecipient??'Not emitted',
    'Status':state?.deliveryStatus??'Not emitted',
    'Boundary':'Explicit from / to / context / request fields; no implicit agent authority',
  }));
}
