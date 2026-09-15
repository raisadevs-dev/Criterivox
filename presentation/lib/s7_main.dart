import 'package:flutter/material.dart';
import 's7/s7_bureau_environment.dart';

void main() => runApp(const S7App());

class S7App extends StatelessWidget {
  const S7App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Criterivox — Reasoning Research Bureau',
        theme: ThemeData.dark(useMaterial3: true),
        home: const S7BureauEnvironment(),
      );
}
