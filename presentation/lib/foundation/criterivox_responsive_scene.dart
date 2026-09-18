import 'package:flutter/material.dart';

enum CriterivoxViewport { mobile, tablet, desktop, wide }

@immutable
class CriterivoxResponsive {
  final double width;
  const CriterivoxResponsive(this.width);

  CriterivoxViewport get viewport =>
      width < 600 ? CriterivoxViewport.mobile :
      width < 900 ? CriterivoxViewport.tablet :
      width < 1280 ? CriterivoxViewport.desktop : CriterivoxViewport.wide;

  bool get isCompact => viewport == CriterivoxViewport.mobile;
  bool get isTablet => viewport == CriterivoxViewport.tablet;
  bool get isDesktop => viewport == CriterivoxViewport.desktop || viewport == Criteriviewport.wide;

  int get informationColumns => isCompact ? 1 : isTablet ? 1 : width < 1500 ? 2 : 3;
  EdgeInsets get scenePadding => EdgeInsets.all(isCompact ? 12 : isTablet ? 16 : 24);

  double characterScale(double base) {
    if (isCompact) return base * .72;
    if (isTablet) return base * .86;
    if (width >= 1800) return base * 1.08;
    return base;
  }

  double panelMaxWidth(double fallback) =>
      isCompact ? width - 24 : fallback.clamp(260, width - 48).toDouble();
}

class CriterivoxResponsiveScene extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const CriterivoxResponsiveScene({super.key, required this.child, this.maxWidth = 1600});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final r = CriterivoxResponsive(constraints.maxWidth);
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(padding: r.scenePadding, child: child),
        ),
      );
    },
  );
}