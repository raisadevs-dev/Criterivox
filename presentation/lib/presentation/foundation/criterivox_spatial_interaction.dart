import 'package:flutter/material.dart';

class CriterivoxSpatialAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticHint;
  const CriterivoxSpatialAction({super.key, required this.label, required this.child, this.onPressed, this.semanticHint});
  @override Widget build(BuildContext context) => Semantics(
    button: onPressed != null, label: label, hint: semanticHint,
    child: FocusableActionDetector(
      mouseCursor: onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: InkWell(onTap: onPressed, child: child),
    ),
  );
}

class CriterivoxSpatialFocus extends StatelessWidget {
  final String label;
  final Widget child;
  const CriterivoxSpatialFocus({super.key, required this.label, required this.child});
  @override Widget build(BuildContext context) => Focus(
    child: Semantics(container: true, label: label, child: child),
  );
}