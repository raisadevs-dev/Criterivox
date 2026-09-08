import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders one state from a supplied six-frame character sheet.
/// Frame order: IDLE, RECEIVE, WORK, COMMUNICATE, HANDOFF, COMPLETE.
class CharacterFrame extends StatelessWidget {
  final String asset;
  final int index;
  final double width;
  final double height;
  final String? fallbackAsset;

  const CharacterFrame({
    super.key,
    required this.asset,
    required this.index,
    this.width = 64,
    this.height = 94,
    this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    final safeIndex = index.clamp(0, 5).toInt();
    final column = safeIndex % 3;
    final row = safeIndex ~/ 3;
    final scale = width / 64;

    Widget image(String source, {bool fallback = false}) => SvgPicture.asset(
          source,
          width: 192,
          height: 188,
          fit: BoxFit.fill,
          semanticsLabel: fallback
              ? 'Character idle fallback frame'
              : 'Character animation frame',
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
