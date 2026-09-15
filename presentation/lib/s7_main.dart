import 'package:flutter/material.dart';
import 's7/reasoning_research_bureau_page.dart';

void main() => runApp(const S7App());

class S7App extends StatelessWidget {
  const S7App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Criterivox — Reasoning Research Bureau',
        theme: ThemeData.dark(useMaterial3: true),
        home: const ReasoningResearchBureauPage(),
      );
}
