import 'package:flutter/material.dart';

@immutable
class CriterivoxVisualTokens extends ThemeExtension<CriterivoxVisualTokens> {
  final double space1, space2, space3, space4, radiusSmall, radiusMedium, radiusLarge;
  final double borderWidth, glassOpacity;
  final TextStyle worldTitle, homeTitle, roomTitle, sectionTitle, artifactTitle, metadata;

  const CriterivoxVisualTokens({
    this.space1 = 4, this.space2 = 8, this.space3 = 12, this.space4 = 20,
    this.radiusSmall = 10, this.radiusMedium = 16, this.radiusLarge = 24,
    this.borderWidth = 1, this.glassOpacity = .72,
    this.worldTitle = const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    this.homeTitle = const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    this.roomTitle = const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    this.sectionTitle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    this.artifactTitle = const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    this.metadata = const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
  });

  static CriterivoxVisualTokens of(BuildContext context) =>
      Theme.of(context).extension<CriterivoxVisualTokens>() ?? const CriterivoxVisualTokens();

  @override
  CriterivoxVisualTokens copyWith({
    double? space1, double? space2, double? space3, double? space4,
    double? radiusSmall, double? radiusMedium, double? radiusLarge,
    double? borderWidth, double? glassOpacity,
    TextStyle? worldTitle, TextStyle? homeTitle, TextStyle? roomTitle,
    TextStyle? sectionTitle, TextStyle? artifactTitle, TextStyle? metadata,
  }) => CriterivoxVisualTokens(
    space1: space1 ?? this.space1, space2: space2 ?? this.space2,
    space3: space3 ?? this.space3, space4: space4 ?? this.space4,
    radiusSmall: radiusSmall ?? this.radiusSmall, radiusMedium: radiusMedium ?? this.radiusMedium,
    radiusLarge: radiusLarge ?? this.radiusLarge, borderWidth: borderWidth ?? this.borderWidth,
    glassOpacity: glassOpacity ?? this.glassOpacity,
    worldTitle: worldTitle ?? this.worldTitle, homeTitle: homeTitle ?? this.homeTitle,
    roomTitle: roomTitle ?? this.roomTitle, sectionTitle: sectionTitle ?? this.sectionTitle,
    artifactTitle: artifactTitle ?? this.artifactTitle, metadata: metadata ?? this.metadata,
  );

  @override
  CriterivoxVisualTokens lerp(ThemeExtension<CriterivoxVisualTokens>? other, double t) =>
      other is! CriterivoxVisualTokens ? this : CriterivoxVisualTokens(
        space1: space1, space2: space2, space3: space3, space4: space4,
        radiusSmall: radiusSmall, radiusMedium: radiusMedium, radiusLarge: radiusLarge,
        borderWidth: borderWidth, glassOpacity: glassOpacity,
        worldTitle: TextStyle.lerp(worldTitle, other.worldTitle, t)!,
        homeTitle: TextStyle.lerp(homeTitle, other.homeTitle, t)!,
        roomTitle: TextStyle.lerp(roomTitle, other.roomTitle, t)!,
        sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t)!,
        artifactTitle: TextStyle.lerp(artifactTitle, other.artifactTitle, t)!,
        metadata: TextStyle.lerp(metadata, other.metadata, t)!,
      );
}