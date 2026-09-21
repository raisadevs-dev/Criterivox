import 'package:flutter/material.dart';

import '../foundation/room_page.dart';
import '../foundation/spatial_panel.dart';
import '../runtime/capability_status.dart';

class HomeShell extends StatelessWidget {
	final String title, residents;
	final List<String> rooms;

	const HomeShell({
		super.key,
		required this.title,
		required this.residents,
		required this.rooms,
	});

	@override
	Widget build(BuildContext c) {
		final List<Widget> roomChips = rooms.map<Widget>((room) {
			return ActionChip(
				label: Text(room),
				onPressed: () => Navigator.of(c).push(
					MaterialPageRoute(
						builder: (_) => RoomPage(
							title: room,
							description: 'Semantic inspection space for this responsibility domain.',
							capability: CapabilityStatus.notConnected,
						),
					),
				),
			);
		}).toList();

		return Scaffold(
			appBar: AppBar(title: Text(title)),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						const Text('A Home is a responsibility domain. Multiple residents share it.'),
						SpatialPanel(title: 'RESIDENTS', child: Text(residents)),
						SpatialPanel(
							title: 'ROOMS',
							child: Wrap(spacing: 8, runSpacing: 8, children: roomChips),
						),
						const SpatialPanel(
							title: 'HOME STATE',
							child: Text('NOT_CONNECTED · authoritative home read model required'),
						),
						const SpatialPanel(
							title: 'ACTIVITY',
							child: Text('NOT_CONNECTED · no fabricated activity'),
						),
						const SpatialPanel(
							title: 'ARTIFACTS',
							child: Text('NOT_CONNECTED · authoritative artifacts only'),
						),
						const SpatialPanel(
							title: 'TRACE',
							child: Text('NOT_CONNECTED · real runtime spans/events only'),
						),
					],
				),
			),
		);
	}
}