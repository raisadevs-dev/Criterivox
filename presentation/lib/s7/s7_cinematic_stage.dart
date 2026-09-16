import 'package:flutter/material.dart';
import 'characters/s7_character_cinematics.dart';

class S7CinematicStage extends StatelessWidget {
  final String room;
  final String status;
  const S7CinematicStage({super.key, required this.room, required this.status});
  S7CharacterState _state() => switch (status.toLowerCase()) {
        'running' => S7CharacterState.work,
        'awaiting_human' => S7CharacterState.communicate,
        'completed' => S7CharacterState.complete,
        'waiting_for_information' => S7CharacterState.receive,
        _ => S7CharacterState.idle,
      };
  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (room != 'tarkis')
                  SizedBox(
                      width: 150,
                      height: 190,
                      child: S7CharacterCinematics(
                          character: 'Vivren', state: _state())),
                if (room != 'vivren')
                  SizedBox(
                      width: 150,
                      height: 190,
                      child: S7CharacterCinematics(
                          character: 'Tarkis', state: _state())),
              ]))));
}
