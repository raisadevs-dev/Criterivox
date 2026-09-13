import 'dart:async';
import 'package:flutter/material.dart';
import 'interaction/bloom.dart';
import 'interaction/syvax.dart';
import 'presentation/presentation_state.dart';
import 'presentation/criterivox_theme.dart';

class BloomPage extends StatefulWidget {
  final PresentationState? state;
  final ValueChanged<BloomSuboption> onSub;
  final ValueChanged<String> onSyvax;
  final ValueChanged<BloomCapability>? onCapability;
  final VoidCallback onStewardship;
  final VoidCallback onHandoff;
  final VoidCallback onOpenAnalysis;
  final bool busy;
  const BloomPage(
      {super.key,
      required this.state,
      required this.onSub,
      required this.onSyvax,
      this.onCapability,
      required this.onStewardship,
      required this.onHandoff,
      required this.onOpenAnalysis,
      required this.busy});
  @override
  State<BloomPage> createState() => _BloomPageState();
}

class _BloomPageState extends State<BloomPage> {
  BloomCapability? selected;
  Timer? _idleTimer;
  bool _doorwayVisible = false;
  String? _doorwayTaskId;
  @override
  void initState() {
    super.initState();
    _scheduleDoorway();
  }

  @override
  void didUpdateWidget(covariant BloomPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state?.taskId != widget.state?.taskId ||
        oldWidget.state?.taskState != widget.state?.taskState)
      _scheduleDoorway();
  }

  void _scheduleDoorway() {
    _idleTimer?.cancel();
    if (mounted)
      setState(() {
        _doorwayVisible = false;
        _doorwayTaskId = null;
      });
    final s = widget.state;
    if (s?.taskId == null || s?.taskState != 'ANALYZING') return;
    final taskId = s!.taskId!;
    _idleTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      setState(() {
        _doorwayVisible = true;
        _doorwayTaskId = taskId;
      });
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 1100;
      return SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16 : 22),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _HeroHeader(state: widget.state, selected: selected),
            if (_doorwayVisible && _doorwayTaskId != null) ...[
              const SizedBox(height: 12),
              _ProactiveDoorway(
                  taskId: _doorwayTaskId!, onOpen: widget.onOpenAnalysis)
            ],
            const SizedBox(height: 14),
            if (compact)
              Column(children: [
                _BloomCard(
                    state: widget.state,
                    selected: selected,
                    onCapability: _select,
                    onSub: _handleSub,
                    height: 560),
                const SizedBox(height: 14),
                Syvax(onSubmit: widget.onSyvax, busy: widget.busy),
                const SizedBox(height: 14),
                _ActivityPanel(state: widget.state)
              ])
            else
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: _BloomCard(
                        state: widget.state,
                        selected: selected,
                        onCapability: _select,
                        onSub: _handleSub,
                        height: 600)),
                const SizedBox(width: 16),
                SizedBox(
                    width: 320,
                    child: Column(children: [
                      Syvax(onSubmit: widget.onSyvax, busy: widget.busy),
                      const SizedBox(height: 14),
                      _ActivityPanel(state: widget.state)
                    ]))
              ]),
            const SizedBox(height: 14),
            _Lifecycle(state: widget.state),
            const SizedBox(height: 10),
            Text(
                'Criterivox stays alive through state, motion, handoff, and context. The visual layer reflects the system instead of inventing it.',
                style:
                    TextStyle(color: t.mutedText, fontSize: 10.5, height: 1.45))
          ]));
    });
  }

  void _select(BloomCapability value) {
    setState(() => selected = selected == value ? null : value);
    widget.onCapability?.call(value);
  }

  void _handleSub(BloomSuboption value) {
    if (value == BloomSuboption.stewardshipHome) {
      widget.onStewardship();
      return;
    }
    widget.onSub(value);
  }
}

class _ProactiveDoorway extends StatelessWidget {
  final String taskId;
  final VoidCallback onOpen;
  const _ProactiveDoorway({required this.taskId, required this.onOpen});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: t.surfaceStrong,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.primary.withValues(alpha: .45))),
        child: Row(children: [
          Icon(Icons.door_front_door_rounded, color: t.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Dharen is working',
                    style: TextStyle(
                        color: t.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 11)),
                const SizedBox(height: 3),
                Text(
                    'Analysis task $taskId is active. The analysis workspace is ready when you need to inspect it.',
                    style: TextStyle(
                        color: t.mutedText, fontSize: 9.5, height: 1.35))
              ])),
          TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_rounded, size: 15),
              label: const Text('Open'))
        ]));
  }
}

class _HeroHeader extends StatelessWidget {
  final PresentationState? state;
  final BloomCapability? selected;
  const _HeroHeader({required this.state, required this.selected});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final selectedText = selected == null
        ? 'Choose a capability, then choose how you want to work with it.'
        : '${Bloom.labels[selected!]} selected. Choose the relevant path.';
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Living Interaction',
            style: TextStyle(
                color: t.text, fontSize: 23, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(selectedText, style: TextStyle(color: t.mutedText, fontSize: 11.5))
      ])),
      if (state?.taskId != null)
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: t.surfaceStrong,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.border)),
            child: Text('TASK ${state!.taskId}',
                style: TextStyle(
                    color: t.mutedText,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)))
    ]);
  }
}

class _BloomCard extends StatelessWidget {
  final PresentationState? state;
  final BloomCapability? selected;
  final ValueChanged<BloomCapability> onCapability;
  final ValueChanged<BloomSuboption> onSub;
  final double height;
  const _BloomCard(
      {required this.state,
      required this.selected,
      required this.onCapability,
      required this.onSub,
      required this.height});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Container(
        height: height,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: t.surface.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.border)),
        child: Column(children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                  color: t.surfaceStrong,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.border)),
              child: Row(children: [
                Icon(Icons.auto_awesome_rounded, color: t.primary, size: 18),
                const SizedBox(width: 9),
                Expanded(
                    child: Text(
                        'Choose a capability and follow its contextual path.',
                        style: TextStyle(color: t.mutedText, fontSize: 10.5))),
                Icon(Icons.open_in_full_rounded, color: t.mutedText, size: 16)
              ])),
          const SizedBox(height: 8),
          Expanded(
              child: Center(
                  child: Bloom(
                      onSelected: onCapability,
                      selected: selected,
                      onSuboption: onSub)))
        ]));
  }
}

class _ActivityPanel extends StatelessWidget {
  final PresentationState? state;
  const _ActivityPanel({required this.state});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final items = <String>[
      if (state?.message != null) state!.message!,
      ...?state?.activity.take(3),
      'Analysis workspace is available from the same task.',
      'Syvax can route a request to Dharen.'
    ];
    return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text('Recent Activity',
                    style: TextStyle(
                        color: t.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700))),
            Text(state?.error == null ? 'LIVE' : 'WARNING',
                style: TextStyle(
                    color: state?.error == null ? t.success : t.warning,
                    fontSize: 9,
                    fontWeight: FontWeight.w800))
          ]),
          const SizedBox(height: 14),
          for (final item in items.take(6))
            Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 6, color: t.primary),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(item,
                              style: TextStyle(
                                  color: t.mutedText,
                                  fontSize: 10.5,
                                  height: 1.4)))
                    ]))
        ]));
  }
}

class _Lifecycle extends StatelessWidget {
  final PresentationState? state;
  const _Lifecycle({required this.state});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final active = state?.taskState ?? 'READY';
    final stages = [
      'CREATED',
      'RECEIVED',
      'VALIDATING',
      'PROCESSING',
      'ANALYZING',
      'RESULT_READY',
      'COMPLETED'
    ];
    final activeIndex = stages.indexOf(active.toUpperCase());
    return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TASK LIFECYCLE',
              style: TextStyle(
                  color: t.mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1)),
          const SizedBox(height: 18),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                for (var i = 0; i < stages.length; i++)
                  Row(children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i <= activeIndex
                                  ? t.primary.withValues(alpha: .15)
                                  : t.surfaceStrong,
                              border: Border.all(
                                  color:
                                      i <= activeIndex ? t.primary : t.border)),
                          child: Icon(
                              i == 6
                                  ? Icons.check_rounded
                                  : Icons.auto_awesome_rounded,
                              size: 14,
                              color:
                                  i <= activeIndex ? t.primary : t.mutedText)),
                      const SizedBox(height: 6),
                      Text(stages[i].replaceAll('_', ' '),
                          style: TextStyle(
                              color: i == activeIndex ? t.text : t.mutedText,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600))
                    ]),
                    if (i < stages.length - 1)
                      Container(
                          width: 42,
                          height: 1,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 15),
                          color: t.border)
                  ])
              ])),
          const SizedBox(height: 10),
          Text('Current state: $active',
              style: TextStyle(color: t.mutedText, fontSize: 10))
        ]));
  }
}
