import 'package:flutter/material.dart';
import '../../foundation/scene.dart';
import '../../foundation/spatial_panel.dart';
import '../residence/human_residence_page.dart';

class CollaborationRoom extends StatelessWidget {
  const CollaborationRoom({super.key});
  @override Widget build(BuildContext c)=>Scene(
    eyebrow:'HUMAN RESIDENCE · COLLABORATION',
    title:'Collaboration Room',
    subtitle:'Shared human work uses the same durable journey engine with room-scoped work.',
    children:[
      SpatialPanel(title:'ROLES',child:const Text('House Owner · Resident · Guest')),
      SpatialPanel(title:'CONTEXT MASKING WALL',child:const Text('PUBLIC_TO_ROOM · RESIDENT_ONLY · OWNER_CONFIDENTIAL · GUEST_MASKED. Backend authorization remains authoritative.')),
      SpatialPanel(title:'WORK',child:FilledButton.icon(onPressed:()=>Navigator.of(c).push(MaterialPageRoute(builder:(_)=>const HumanResidencePage(roomId:'collaboration'))),icon:const Icon(Icons.group_work),label:const Text('OPEN COLLABORATIVE WORK'))),
      const SpatialPanel(title:'MULTI-SIGNATORY ACTION GATE',child:Text('Authorization is explicit. The human remains the decision authority.')),
      const SpatialPanel(title:'SHARED RESULTS JOURNAL',child:Text('Outcome recording remains human-owned and provenance-aware.')),
    ],
  );
}
