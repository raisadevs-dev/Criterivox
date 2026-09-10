import 'package:flutter/material.dart';

import 'character/character_runtime.dart';
import 'presentation/criterivox_theme.dart';

class AppIntroductionPage extends StatefulWidget {
  final VoidCallback onOpenWorkspace;
  final VoidCallback onOpenChat;

  const AppIntroductionPage({
    super.key,
    required this.onOpenWorkspace,
    required this.onOpenChat,
  });

  @override
  State<AppIntroductionPage> createState() => _AppIntroductionPageState();
}

class _AppIntroductionPageState extends State<AppIntroductionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  static const _states = <String>[
    'IDLE',
    'RECEIVE',
    'WORK',
    'COMMUNICATE',
    'HANDOFF',
    'COMPLETE',
    'WARNING',
  ];

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 820;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(narrow ? 14 : 28, 24, narrow ? 14 : 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _hero(theme, narrow),
              const SizedBox(height: 22),
              _minds(theme, narrow),
              const SizedBox(height: 22),
              _workflow(theme, narrow),
              const SizedBox(height: 22),
              _capabilities(theme),
              const SizedBox(height: 22),
              _start(theme, narrow),
            ],
          ),
        );
      },
    );
  }

  Widget _hero(CriterivoxTheme theme, bool narrow) {
    return Container(
      padding: EdgeInsets.all(narrow ? 20 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [theme.surfaceStrong, theme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _motion,
            builder: (_, __) {
              final state = _states[(_motion.value * _states.length).floor() % _states.length];
              final syvax = _heroCharacter(theme, 'syvax', 'SYVAX', 'DIALOGUE + ROUTING', state);
              final dharen = _heroCharacter(theme, 'dharen', 'DHAREN', 'CONTEXT ARCHITECTURE', _states[(_states.indexOf(state) + 1) % _states.length]);
              return narrow
                  ? Column(children: [syvax, const SizedBox(height: 12), dharen])
                  : Row(
                      children: [
                        Expanded(child: syvax),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Text('×', style: TextStyle(color: theme.mutedText, fontSize: 24)),
                        ),
                        Expanded(child: dharen),
                      ],
                    );
            },
          ),
          const SizedBox(height: 18),
          Text(
            'ONE SYSTEM. MANY MINDS.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.text,
              fontSize: narrow ? 22 : 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Criterivox turns data, context and questions into understandable analysis and evidence-backed action.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.mutedText, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _heroCharacter(
    CriterivoxTheme theme,
    String characterId,
    String name,
    String role,
    String state,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 260, maxHeight: 330),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.page.withValues(alpha: .72),
        border: Border.all(color: theme.primary.withValues(alpha: .25)),
      ),
      child: Column(
        children: [
          Expanded(
            child: CharacterRuntimeView(
              characterId: characterId,
              state: state,
              width: 180,
              height: 264,
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: TextStyle(color: theme.text, fontWeight: FontWeight.w800, letterSpacing: 2)),
          Text(role, style: TextStyle(color: theme.primary, fontSize: 10, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _minds(CriterivoxTheme theme, bool narrow) {
    final cards = [
      _mindCard(theme, 'SYVAX', 'Dialogue + routing', 'Receives intent, clarifies direction and routes work through the shared runtime.'),
      _mindCard(theme, 'DHAREN', 'Context architecture', 'Structures context, preserves uncertainty and returns contextual work to the task.'),
    ];
    return _section(theme, 'MEET THE MINDS', 'They are functional interaction entities, not decorative mascots.', narrow, cards);
  }

  Widget _mindCard(CriterivoxTheme theme, String name, String role, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(color: theme.primary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
          Text(role, style: TextStyle(color: theme.text, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(color: theme.mutedText, height: 1.55, fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _workflow(CriterivoxTheme theme, bool narrow) {
    const steps = [
      ('01', 'QUESTION', 'You bring a question, task, data and context.'),
      ('02', 'ROUTING', 'Intent is received, clarified and routed.'),
      ('03', 'CONTEXT', 'The shared context record is structured.'),
      ('04', 'EVIDENCE', 'Observations, findings and evidence return to the task.'),
      ('05', 'NEXT STEP', 'Workspace and Character Chat stay connected.'),
    ];
    return _section(
      theme,
      'HOW CRITERIVOX WORKS',
      'The experience is a living flow, not a collection of disconnected screens.',
      narrow,
      [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final step in steps)
              SizedBox(
                width: narrow ? double.infinity : 185,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.$1, style: TextStyle(color: theme.primary, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 7),
                      Text(step.$2, style: TextStyle(color: theme.text, fontWeight: FontWeight.w700, fontSize: 11)),
                      const SizedBox(height: 6),
                      Text(step.$3, style: TextStyle(color: theme.mutedText, fontSize: 10.5, height: 1.4)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _capabilities(CriterivoxTheme theme) {
    const cards = [
      ('ANALYZE', 'Available now', 'Run a synthetic/local analysis from Workspace or through Character Chat.'),
      ('CONTEXT', 'Available now', 'Inspect the context record, uncertainty, baseline status and lineage.'),
      ('CHARACTER CHAT', 'Available now', 'Choose any S6 chat member and keep an independent conversation.'),
      ('PROVENANCE', 'Available now', 'Trace the current foundation-to-context lineage.'),
      ('COMPARE / EXPLORE / PLAN', 'Future', 'Reserved capability slots remain visible without pretending unfinished work exists.'),
      ('INSIGHTS / EXPLAIN', 'Future', 'Planned capability expansion after the current foundation is complete.'),
    ];
    return _section(
      theme,
      'WHAT YOU CAN DO',
      'This introduction describes the implemented surface honestly.',
      false,
      [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            mainAxisExtent: 122,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (_, index) {
            final card = cards[index];
            final future = card.$2 == 'Future';
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: future ? theme.border : theme.primary.withValues(alpha: .28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(card.$1, style: TextStyle(color: theme.text, fontWeight: FontWeight.w700, fontSize: 11))),
                    Text(card.$2, style: TextStyle(color: future ? theme.mutedText : theme.success, fontSize: 9, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 8),
                  Text(card.$3, style: TextStyle(color: theme.mutedText, fontSize: 10.5, height: 1.35)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _start(CriterivoxTheme theme, bool narrow) {
    final actions = narrow
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            FilledButton.icon(onPressed: widget.onOpenWorkspace, icon: const Icon(Icons.dashboard_customize_rounded), label: const Text('Open Workspace')),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: widget.onOpenChat, icon: const Icon(Icons.forum_rounded), label: const Text('Open Character Chat')),
          ])
        : Row(children: [
            FilledButton.icon(onPressed: widget.onOpenWorkspace, icon: const Icon(Icons.dashboard_customize_rounded), label: const Text('Open Workspace')),
            const SizedBox(width: 10),
            OutlinedButton.icon(onPressed: widget.onOpenChat, icon: const Icon(Icons.forum_rounded), label: const Text('Open Chat')),
          ]);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.surfaceStrong, borderRadius: BorderRadius.circular(22), border: Border.all(color: theme.border)),
      child: narrow
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Ready to work with them?', style: TextStyle(color: theme.text, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Go straight to Workspace or choose a character.', style: TextStyle(color: theme.mutedText, fontSize: 11)),
              const SizedBox(height: 14),
              actions,
            ])
          : Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ready to work with them?', style: TextStyle(color: theme.text, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Go straight to Workspace or Character Chat.', style: TextStyle(color: theme.mutedText, fontSize: 11)),
              ])),
              actions,
            ]),
    );
  }

  Widget _section(CriterivoxTheme theme, String title, String subtitle, bool narrow, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: theme.text, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: theme.mutedText, fontSize: 10.5)),
        const SizedBox(height: 12),
        if (children.length == 1)
          ...children
        else if (narrow)
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children)
        else
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final child in children) Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: child))]),
      ],
    );
  }
}
