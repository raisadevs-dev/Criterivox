import 'package:flutter/material.dart';
import 's7/reasoning_research_bureau_page.dart';
import 's7/s7_cinematic_stage.dart';

void main()=>runApp(const S7App());
class S7App extends StatelessWidget{const S7App({super.key});@override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Criterivox — Reasoning Research Bureau',theme:ThemeData.dark(useMaterial3:true),home:const _S7Surface());}
class _S7Surface extends StatefulWidget{const _S7Surface();@override State<_S7Surface> createState()=>_S7SurfaceState();}
class _S7SurfaceState extends State<_S7Surface>{String room='collaboration';@override Widget build(BuildContext context)=>Stack(children:[const ReasoningResearchBureauPage(),S7CinematicStage(room:room,status:'idle')]);}
