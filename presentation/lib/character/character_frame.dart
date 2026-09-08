import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Maps semantic character states to the current six-frame SVG sheet.
/// Individual state files can replace the sheet later without changing callers.
class CharacterVisualAssets {
  CharacterVisualAssets._();

  static const Map<String, String> sheets = {
    'dharen': 'assets/characters/dharen.svg',
    'syvax': 'assets/characters/syvax.svg',
  };

  static const Map<String, List<String>> states = {
    'dharen': [
      'assets/characters/dharen/idle.svg',
      'assets/characters/dharen/receive.svg',
      'assets/characters/dharen/work.svg',
      'assets/characters/dharen/communicate.svg',
      'assets/characters/dharen/handoff.svg',
      'assets/characters/dharen/complete.svg',
    ],
    'syvax': [
      'assets/characters/syvax/idle.svg',
      'assets/characters/syvax/receive.svg',
      'assets/characters/syvax/work.svg',
      'assets/characters/syvax/communicate.svg',
      'assets/characters/syvax/handoff.svg',
      'assets/characters/syvax/complete.svg',
    ],
  };

  static String sheetFor(String characterId) =>
      sheets[characterId.toLowerCase()] ?? sheets['dharen']!;

  static String stateFor(String characterId, int index) {
    final assets = states[characterId.toLowerCase()] ?? states['dharen']!;
    return assets[index.clamp(0, assets.length - 1).toInt()];
  }
}

class CharacterFrame extends StatelessWidget {
  final String asset;
  final int index;
  final double width;
  final double height;
  final String? fallbackAsset;
  final String? stateAsset;

  const CharacterFrame({
    super.key,
    required this.asset,
    required this.index,
    this.width = 64,
    this.height = 94,
    this.fallbackAsset,
    this.stateAsset,
  });

  @override
  Widget build(BuildContext context) {
    final source = stateAsset ?? asset;
    if (stateAsset != null) {
      return SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SvgPicture.asset(
            source,
            width: width,
            height: height,
            fit: BoxFit.cover,
            semanticsLabel: 'Character animation frame',
            errorBuilder: (context, error, stackTrace) => CharacterFrame(
              asset: asset,
              index: index,
              width: width,
              height: height,
              fallbackAsset: fallbackAsset,
            ),
          ),
        ),
      );
    }

    final safeIndex = index.clamp(0, 5).toInt();
    final column = safeIndex % 3;
    final row = safeIndex ~/ 3;
    final scale = width / 64;

    Widget image(String source, {bool fallback = false}) => SvgPicture.asset(
          source,
          width: 192,
          height: 188,
          fit: BoxFit.fill,
          semanticsLabel: fallback ? 'Character idle fallback frame' : 'Character animation frame',
          errorBuilder: (context, error, stackTrace) {
            if (!fallback && fallbackAsset != null && fallbackAsset != source) {
              return image(fallbackAsset!, fallback: true);
            }
            return const Center(child: Icon(Icons.person_outline_rounded));
          },
        );

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Transform.translate(
          offset: Offset(-column * width, -row * height),
          child: Transform.scale(
            alignment: Alignment.topLeft,
            scale: scale,
            child: image(asset),
          ),
        ),
      ),
    );
  }
}
