import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 's8_environment.dart';
import 's8_presentation_state.dart';

/// Functional S8 room selector. The bureau has exactly four specialist rooms;
/// Home is the hub and is not counted as a fifth specialist room.
class S8FourRoomBureau extends StatefulWidget {
  final S8Room initialRoom;
  final Widget Function(BuildContext context, S8Room room)? roomContent;

  const S8FourRoomBureau({super.key, this.initialRoom = S8Room.home, this.roomContent});

  @override
  State<S8FourRoomBureau> createState() => _S8FourRoomBureauState();
}

class _S8FourRoomBureauState extends State<S8FourRoomBureau> {
  late S8Room _room;

  static const rooms = <S8Room>[
    S8Room.home,
    S8Room.medrus,
    S8Room.epistre,
    S8Room.veridat,
    S8Room.presentation,
  ];

  @override
  void initState() {
    super.initState();
    _room = widget.initialRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _RoomRail(selected: _room, onSelected: (room) => setState(() => _room = room)),
      const SizedBox(height: 12),
      Expanded(
        child: AnimatedSwitcher(
          duration: 350.ms,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          child: S8RoomEnvironment(
            key: ValueKey(_room),
            room: _room,
            child: widget.roomContent?.call(context, _room) ?? _DefaultRoomContent(room: _room),
          ),
        ),
      ),
    ]);
  }
}

class _RoomRail extends StatelessWidget {
  final S8Room selected;
  final ValueChanged<S8Room> onSelected;
  const _RoomRail({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _S8FourRoomBureauState.rooms.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final room = _S8FourRoomBureauState.rooms[index];
          final selectedRoom = room == selected;
          final meta = _roomMeta(room);
          return Semantics(
            button: true,
            selected: selectedRoom,
            label: '${meta.name}: ${meta.role}',
            child: InkWell(
              onTap: () => onSelected(room),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: 220.ms,
                width: 188,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedRoom ? meta.accent.withValues(alpha: .14) : const Color(0xAA0B1722),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selectedRoom ? meta.accent : Colors.white.withValues(alpha: .10)),
                  boxShadow: selectedRoom ? [BoxShadow(color: meta.accent.withValues(alpha: .14), blurRadius: 18)] : const [],
                ),
                child: Row(children: [
                  Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: meta.accent.withValues(alpha: .12), border: Border.all(color: meta.accent.withValues(alpha: .55))), child: Icon(meta.icon, color: meta.accent, size: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(meta.name, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .7)),
                    const SizedBox(height: 2),
                    Text(meta.role, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.white60)),
                  ])),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DefaultRoomContent extends StatelessWidget {
  final S8Room room;
  const _DefaultRoomContent({required this.room});

  @override
  Widget build(BuildContext context) {
    final meta = _roomMeta(room);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(meta.icon, color: meta.accent),
        const SizedBox(width: 10),
        Text(meta.name.toUpperCase(), style: TextStyle(color: meta.accent, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ]),
      const SizedBox(height: 8),
      Text(meta.description, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      const Spacer(),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final capability in meta.capabilities)
          Chip(avatar: Icon(meta.icon, size: 14, color: meta.accent), label: Text(capability)),
      ]),
    ]);
  }
}

class _RoomMeta {
  final String name;
  final String role;
  final String description;
  final List<String> capabilities;
  final IconData icon;
  final Color accent;
  const _RoomMeta(this.name, this.role, this.description, this.capabilities, this.icon, this.accent);
}

_RoomMeta _roomMeta(S8Room room) => switch (room) {
  S8Room.home => const _RoomMeta('S8 Home', 'Intelligence Environment', 'The hub coordinates access to the four specialist rooms without becoming another specialist computation room.', ['Observe bureau', 'Follow activity', 'Open specialist room'], Icons.hub, Color(0xFF4CB8FF)),
  S8Room.medrus => const _RoomMeta('Medrus', 'Evidence & Memory', 'Evidence intake, retention, source context and temporal memory.', ['Evidence', 'Sources', 'Memory', 'Temporal context'], Icons.inventory_2_outlined, Color(0xFF2CCCF5)),
  S8Room.epistre => const _RoomMeta('Epistre', 'Provenance & Explanation', 'Lineage, attribution and human-readable explanation of the recorded research path.', ['Provenance', 'Lineage', 'Explanation', 'Attribution'], Icons.account_tree_outlined, Color(0xFFB98BFF)),
  S8Room.veridat => const _RoomMeta('Veridat', 'Verification & Truth Boundary', 'Verification state, conflicts, integrity signals and explicit uncertainty boundaries.', ['Verify', 'Conflicts', 'Integrity', 'Uncertainty'], Icons.verified_outlined, Color(0xFF38E0A8)),
  S8Room.presentation => const _RoomMeta('Presentation', 'Flow & Collaboration', 'The human-facing coordination room for inspecting results and moving through the research flow.', ['Inspect', 'Trace', 'Challenge', 'Review'], Icons.dashboard_customize_outlined, Color(0xFFFFC857)),
};
