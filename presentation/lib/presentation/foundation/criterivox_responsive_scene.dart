import 'package:flutter/material.dart';

enum CriterivoxViewport {
  mobile,
  tablet,
  desktop,
  wide,
}

@immutable
class CriterivoxResponsive {
  final double width;

  const CriterivoxResponsive(this.width);

  CriterivoxViewport get viewport {
    if (width < 600) {
      return CriterivoxViewport.mobile;
    }

    if (width < 900) {
      return CriterivoxViewport.tablet;
    }

    if (width < 1280) {
      return CriterivoxViewport.desktop;
    }

    return CriterivoxViewport.wide;
  }

  bool get isCompact =>
      viewport == CriterivoxViewport.mobile;

  bool get isTablet =>
      viewport == CriterivoxViewport.tablet;

  bool get isDesktop =>
      viewport == CriterivoxViewport.desktop ||
      viewport == CriterivoxViewport.wide;

  int get informationColumns {
    if (isCompact) {
      return 1;
    }

    if (isTablet) {
      return 1;
    }

    return width < 1500 ? 2 : 3;
  }

  EdgeInsets get scenePadding {
    if (isCompact) {
      return const EdgeInsets.all(12);
    }

    if (isTablet) {
      return const EdgeInsets.all(16);
    }

    return const EdgeInsets.all(24);
  }

  double characterScale(double base) {
    if (isCompact) {
      return base * .72;
    }

    if (isTablet) {
      return base * .86;
    }

    if (width >= 1800) {
      return base * 1.08;
    }

    return base;
  }

  double panelMaxWidth(double fallback) {
    if (isCompact) {
      final available = width - 24;

      if (available <= 0) {
        return 0;
      }

      return available;
    }

    final available = width - 48;

    if (available <= 0) {
      return 0;
    }

    if (available < 260) {
      return available;
    }

    return fallback.clamp(260.0, available).toDouble();
  }
}

class CriterivoxResponsiveScene extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CriterivoxResponsiveScene({
    super.key,
    required this.child,
    this.maxWidth = 1600,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = CriterivoxResponsive(
          constraints.maxWidth,
        );

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: Padding(
              padding: responsive.scenePadding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}