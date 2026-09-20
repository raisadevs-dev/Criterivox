import 'package:flutter/material.dart';
import 'app_theme.dart';import 'app_router.dart';
class CriterivoxApp extends StatelessWidget{const CriterivoxApp({super.key});@override Widget build(BuildContext c)=>MaterialApp(title:'Criterivox',debugShowCheckedModeBanner:false,theme:buildCriterivoxTheme(),home:const AppRouter());}
