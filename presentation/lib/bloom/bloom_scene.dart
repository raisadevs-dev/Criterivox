import 'package:flutter/material.dart';
import '../foundation/spatial_panel.dart';
import '../quarters/quarter_registry.dart';

class BloomScene extends StatelessWidget
{
  const BloomScene({super.key});
  @override Widget build(BuildContext c)=>SpatialPanel
  (
    title:'BLOOM NEXUS',
    child:Wrap
    (spacing:10,runSpacing:10,children:QuarterRegistry.all.map
      ((q)=>SizedBox
      (width:260,child:Card(child:ListTile(leading:const Icon(Icons.hub_outlined),title:Text(q.title),subtitle:Text(q.description),
    onTap:()=>Navigator.of(c).push(MaterialPageRoute(builder:(_)=>q.page)))))).toList()
    
    )
    );
  }
