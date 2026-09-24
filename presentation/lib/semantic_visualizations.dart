import 'package:flutter/material.dart';
import 'character/character_identity.dart';
import 'presentation/criterivox_theme.dart';

class SemanticTimelineItem { final String title; final String detail; const SemanticTimelineItem(this.title, this.detail); }
class SemanticRelationship { final String from; final String to; final String label; const SemanticRelationship(this.from, this.to, this.label); }

class CriterivoxSemanticVisuals {
  CriterivoxSemanticVisuals._();
  static Widget status(BuildContext context, {required String label, required String detail, bool active = true}) {
    final t=CriterivoxTheme.of(context);
    return _Panel(child: Row(children:[Container(width:9,height:9,decoration:BoxDecoration(color:active?t.primary:t.mutedText,shape:BoxShape.circle)),const SizedBox(width:9),Expanded(child:Text(label,style:TextStyle(color:t.text,fontWeight:FontWeight.w700,fontSize:11))),Text(detail,style:TextStyle(color:t.mutedText,fontSize:10))]));
  }
  static Widget progress(BuildContext context,{required String label,required int completed,required int total}) {
    final t=CriterivoxTheme.of(context); final value=total==0?0.0:(completed/total).clamp(0.0,1.0);
    return _Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(label,style:TextStyle(color:t.text,fontWeight:FontWeight.w700,fontSize:11))),Text(completed.toString()+' / '+total.toString(),style:TextStyle(color:t.mutedText,fontSize:10))]),const SizedBox(height:8),ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value:value,minHeight:8))]));
  }
  static Widget timeline(BuildContext context,{required String title,required List<SemanticTimelineItem> items}) {
    final t=CriterivoxTheme.of(context);
    return _Panel(
      title: title,
      child: Column(
        children: [
          for (var i=0; i<items.length; i++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(width: 10,height: 10,decoration: BoxDecoration(color: t.primary,shape: BoxShape.circle)),
                      if (i < items.length - 1) Container(width: 2,height: 38,color: t.border),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].title,style: TextStyle(color:t.text,fontWeight:FontWeight.w700,fontSize:11)),
                        const SizedBox(height:2),
                        Text(items[i].detail,style: TextStyle(color:t.mutedText,fontSize:9.5,height:1.35)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  static Widget bars(BuildContext context,{required String title,required Map<String,int> values}) {
    final t=CriterivoxTheme.of(context); final maxValue=values.values.fold<int>(0,(m,v)=>v>m?v:m);
    return _Panel(title:title,child:Column(children:values.entries.map((e){final f=maxValue==0?0.0:e.value/maxValue;return Padding(padding:const EdgeInsets.only(bottom:9),child:Row(children:[SizedBox(width:86,child:Text(e.key,overflow:TextOverflow.ellipsis,style:TextStyle(color:t.mutedText,fontSize:9))),Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(6),child:LinearProgressIndicator(value:f,minHeight:12))),const SizedBox(width:7),SizedBox(width:22,child:Text(e.value.toString(),textAlign:TextAlign.right,style:TextStyle(color:t.text,fontSize:9,fontWeight:FontWeight.w700)))]));}).toList()));
  }
  static Widget table(BuildContext context,{required String title,required List<String> columns,required List<List<String>> rows}) {
    final t=CriterivoxTheme.of(context); return _Panel(title:title,child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(columnSpacing:22,headingTextStyle:TextStyle(color:t.text,fontSize:10,fontWeight:FontWeight.w800),dataTextStyle:TextStyle(color:t.mutedText,fontSize:9.5),columns:columns.map((c)=>DataColumn(label:Text(c))).toList(),rows:rows.map((r)=>DataRow(cells:r.map((v)=>DataCell(Text(v))).toList())).toList()));
  }
  static Widget network(BuildContext context,{required String title,required List<SemanticRelationship> relationships}) {
    final t=CriterivoxTheme.of(context);
    return _Panel(
      title: title,
      child: Column(
        children: relationships.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              _Node(text: _name(r.from), theme: t),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.arrow_forward_rounded, color: t.primary, size: 15),
                    Text(r.label, textAlign: TextAlign.center, style: TextStyle(color:t.mutedText,fontSize:8)),
                  ],
                ),
              ),
              _Node(text: _name(r.to), theme: t),
            ],
          ),
        )).toList(),
      ),
    );
  }
  static Widget evidenceChain(BuildContext context,{String title='Evidence chain'}) => timeline(context,title:title,items:const[SemanticTimelineItem('Source','A retained source or observation enters the evidence boundary.'),SemanticTimelineItem('Claim','A claim is stated from the available source material.'),SemanticTimelineItem('Assessment','The claim is checked against evidence and verification responsibilities.'),SemanticTimelineItem('Conclusion','A bounded conclusion is available for downstream reasoning or planning.')]);
  static Widget decisionStructure(BuildContext context,{String title='Decision structure'}) {
    final t=CriterivoxTheme.of(context); return _Panel(title:title,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[_DecisionRow('Question','What decision is being framed?',t),_DecisionRow('Options','Evidence • Insight • Alternatives',t),_DecisionRow('Trade-offs','Benefits • Constraints • Uncertainty',t),_DecisionRow('Consequences','Inspect downstream responsibility before acting.',t),_DecisionRow('Decision','Human-authorized decision boundary',t)]));
  }
  static Widget cards(BuildContext context,{required String title,required List<MapEntry<String,String>> items}) {
    final t=CriterivoxTheme.of(context); return _Panel(title:title,child:Wrap(spacing:8,runSpacing:8,children:items.map((e)=>SizedBox(width:210,child:Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:t.surfaceStrong.withValues(alpha:.55),borderRadius:BorderRadius.circular(12),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e.key,style:TextStyle(color:t.text,fontWeight:FontWeight.w700,fontSize:10)),const SizedBox(height:4),Text(e.value,style:TextStyle(color:t.mutedText,fontSize:9,height:1.35))])))).toList()));
  }
}
class _Panel extends StatelessWidget { final String? title; final Widget child; const _Panel({this.title,required this.child}); @override Widget build(BuildContext context){final t=CriterivoxTheme.of(context);return Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:t.surface.withValues(alpha:.72),borderRadius:BorderRadius.circular(16),border:Border.all(color:t.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[if(title!=null) ...[Text(title!,style:TextStyle(color:t.text,fontWeight:FontWeight.w800,fontSize:11)),const SizedBox(height:10)],child]));}}
class _Node extends StatelessWidget { final String text; final CriterivoxTheme theme; const _Node({required this.text,required this.theme}); @override Widget build(BuildContext context)=>Container(constraints:const BoxConstraints(minWidth:70,maxWidth:120),padding:const EdgeInsets.symmetric(horizontal:8,vertical:7),decoration:BoxDecoration(color:theme.primary.withValues(alpha:.10),borderRadius:BorderRadius.circular(10),border:Border.all(color:theme.primary.withValues(alpha:.35))),child:Text(text,textAlign:TextAlign.center,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(color:theme.text,fontSize:8.5,fontWeight:FontWeight.w700)));}
class _DecisionRow extends StatelessWidget { final String label,value; final CriterivoxTheme theme; const _DecisionRow(this.label,this.value,this.theme); @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:7),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:82,child:Text(label,style:TextStyle(color:theme.primary,fontWeight:FontWeight.w800,fontSize:9))),Expanded(child:Text(value,style:TextStyle(color:theme.text,fontSize:9.5,height:1.35)))]));}
String _name(String id){try{return CharacterIdentities.resolve(id).displayName;}catch(_){return id;}}