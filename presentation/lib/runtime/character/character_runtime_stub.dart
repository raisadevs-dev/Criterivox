import 'package:flutter/material.dart';

class CharacterRuntimeView extends StatelessWidget {
  final String characterId;
  final String state;
  final bool reducedMotion;
  final double width;
  final double height;

  const CharacterRuntimeView(
      {super.key,
      required this.characterId,
      required this.state,
      this.reducedMotion = false,
      this.width = 180,
      this.height = 240});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: Semantics(
        container: true,
        label: '$characterId skeletal runtime',
        value: state,
        child: Center(
          child: Text(
            'Skeletal character runtime\nWeb presentation required',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.hintColor, fontSize: 11),
          ),
        ),
      ),
    );
  }
}
