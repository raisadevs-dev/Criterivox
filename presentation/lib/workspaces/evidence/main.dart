import 'package:flutter/material.dart';

import 's8_evidence_bureau_page.dart';

/// Standalone S8 launcher target. This deliberately does not import or boot
/// the main Criterivox shell.
void main() {
  runApp(const S8StandaloneApp());
}

class S8StandaloneApp extends StatelessWidget {
  const S8StandaloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Criterivox S8 Evidence Research Bureau',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const S8EvidenceBureauPage(),
    );
  }
}
