import 'package:flutter/material.dart';

import 's7_environment_page.dart';

/// Canonical entry point for the S7 Reasoning Research Bureau.
///
/// Initial analytical input belongs to Human Residence. This compatibility
/// surface therefore accepts only an already-created S7 session and delegates
/// the actual room to the canonical environment page.
class ReasoningResearchBureauPage extends StatelessWidget {
  final String? sessionId;

  const ReasoningResearchBureauPage({super.key, this.sessionId});

  @override
  Widget build(BuildContext context) {
    return S7EnvironmentPage(sessionId: sessionId);
  }
}
