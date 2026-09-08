import 'package:flutter/material.dart';

import 'character/character_frame.dart';
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

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 820;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            narrow ? 14 : 28,
            24,
            narrow ? 14 : 28,
            36,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _hero(t, narrow),
              const SizedBox(height: 22),
              _minds(t, narrow),
              const SizedBox(height: 22),
              _workflow(t, narrow),
              const SizedBox(height: 22),
              _capabilities(t),
              const SizedBox(height: 22),
              _start(t, narrow),
            ],
          ),
        );
      },
    );
  }

  Widget _hero(CriterivoxTheme t, bool narrow) {
    return Container(
      padding: EdgeInsets.all(narrow ? 20 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [t.surfaceStrong, t.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: t.border),
        boxShadow: [
          BoxShadow(color: t.primary.withValues(alpha: .12), blurRadius: 38),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _motion,
            builder: (_, __) {
              final frame = (_motion.value * 6).floor() % 6;
              final syvax = _heroCharacter(
                t,
                name: 'SYVAX',
                role: 'INSIGHT SPECIALIST',
                accent: const Color(0xFF55B8FF),
                asset: 'assets/characters/syvax.svg',
                frame: frame,
              );
              final dharen = _heroCharacter(
                t,
                name: 'DHAREN',
                role: 'INSIGHT GUIDE',
                accent: const Color(0xFFFFC777),
                asset: 'assets/characters/dharen.svg',
                frame: (frame + 1) % 6,
              );
              return narrow
                  ? Column(children: [syvax, const SizedBox(height: 12), dharen])
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: syvax),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Text(
                            '×',
                            style: TextStyle(
                              color: t.mutedText,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        Expanded(child: dharen),
                      ],
                    );
            },
          ),
          const SizedBox(height: 18),
          Text(
            'TWO MINDS. ONE MISSION.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.text,
              fontSize: narrow ? 22 : 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Criterivox turns data, context and questions into understandable analysis and evidence-backed action.',
            textAlign: TextAlign.center,
            style: TextStyle(color: t.mutedText, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _heroCharacter(
    CriterivoxTheme t, {
    required String name,
    required String role,
    required Color accent,
    required String asset,
    required int frame,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 260, maxHeight: 330),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: t.page.withValues(alpha: .72),
        border: Border.all(color: accent.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          Expanded(
            child: CharacterFrame(
              asset: asset,
              index: frame,
              width: 180,
              height: 264,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: t.text,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          Text(
            role,
            style: TextStyle(color: accent, fontSize: 10, letterSpacing: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _minds(CriterivoxTheme t, bool narrow) {
    final syvax = _mindCard(
      t,
      'SYVAX',
      'The question and routing specialist',
      const Color(0xFF55B8FF),
      'Finds patterns in complexity, connects data and context, and helps turn an intention into the right path through Criterivox.',
      ['Analytical', 'Curious', 'Thoughtful', 'Supportive'],
      'Direct chat • Routing • Context intake',
    );
    final dharen = _mindCard(
      t,
      'DHAREN',
      'The insight guide',
      const Color(0xFFFFC777),
      'Receives the task, works through the supplied data and context, communicates findings, and brings the result back into the shared task.',
      ['Calm', 'Focused', 'Empathetic', 'Action-oriented'],
      'Analysis • Findings • Evidence • Task lifecycle',
    );
    return _section(
      t,
      'MEET THE MINDS',
      'They are functional interaction entities, not decorative mascots.',
      narrow,
      [narrow ? syvax : Expanded(child: syvax), narrow ? dharen : Expanded(child: dharen)],
    );
  }

  Widget _mindCard(
    CriterivoxTheme t,
    String name,
    String title,
    Color accent,
    String description,
    List<String> traits,
    String capabilities,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: .28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(color: accent, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
          Text(title, style: TextStyle(color: t.text, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(color: t.mutedText, height: 1.55, fontSize: 12.5)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final trait in traits)
                Chip(
                  label: Text(trait, style: TextStyle(color: t.text, fontSize: 10)),
                  backgroundColor: accent.withValues(alpha: .10),
                  side: BorderSide(color: accent.withValues(alpha: .25)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(capabilities, style: TextStyle(color: t.mutedText, fontSize: 10.5)),
        ],
      ),
    );
  }

  Widget _workflow(CriterivoxTheme t, bool narrow) {
    final steps = [
      ('01', 'QUESTION', 'You bring a question, task, data and context.'),
      ('02', 'SYVAX', 'Intent is received, clarified and routed.'),
      ('03', 'DHAREN', 'The shared analysis task moves through its lifecycle.'),
      ('04', 'EVIDENCE', 'Observations, findings and evidence return to the task.'),
      ('05', 'NEXT STEP', 'Workspace and Chat stay connected to the same task.'),
    ];
    return _section(
      t,
      'HOW CRITERIVOX WORKS',
      'The experience is a living flow, not a collection of disconnected screens.',
      narrow,
      [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final s in steps)
              SizedBox(
                width: narrow ? double.infinity : 185,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: t.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$1, style: TextStyle(color: t.primary, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 7),
                      Text(s.$2, style: TextStyle(color: t.text, fontWeight: FontWeight.w700, fontSize: 11)),
                      const SizedBox(height: 6),
                      Text(s.$3, style: TextStyle(color: t.mutedText, fontSize: 10.5, height: 1.4)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _capabilities(CriterivoxTheme t) {
    final cards = [
      ('ANALYZE', 'Available now', 'Run a synthetic/local analysis from Workspace or through the character entry flow.'),
      ('WORKSPACE', 'Available now', 'See task lifecycle, observations, findings, evidence, activity and Dharen state.'),
      ('CHARACTER CHAT', 'Available now', 'Choose Syvax or Dharen and continue with the current shared task context.'),
      ('REFERENCES', 'Available now', 'Attach file references to conversation context and carry them with the task.'),
      ('COMPARE / EXPLORE / PLAN', 'Future', 'Reserved capability slots remain visible without pretending unfinished work exists.'),
      ('INSIGHTS / EXPLAIN', 'Future', 'Planned capability expansion after the current foundation is complete.'),
    ];
    return _section(
      t,
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
          itemBuilder: (_, i) {
            final c = cards[i];
            final future = c.$2 == 'Future';
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: future ? t.border : t.primary.withValues(alpha: .28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(c.$1, style: TextStyle(color: t.text, fontWeight: FontWeight.w700, fontSize: 11))),
                    Text(c.$2, style: TextStyle(color: future ? t.mutedText : t.success, fontSize: 9, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 8),
                  Text(c.$3, style: TextStyle(color: t.mutedText, fontSize: 10.5, height: 1.35)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _start(CriterivoxTheme t, bool narrow) {
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
      decoration: BoxDecoration(color: t.surfaceStrong, borderRadius: BorderRadius.circular(22), border: Border.all(color: t.border)),
      child: narrow
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Ready to work with them?', style: TextStyle(color: t.text, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Go straight to Workspace or choose a character.', style: TextStyle(color: t.mutedText, fontSize: 11)),
              const SizedBox(height: 14),
              actions,
            ])
          : Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ready to work with them?', style: TextStyle(color: t.text, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Go straight to Workspace or Character Chat.', style: TextStyle(color: t.mutedText, fontSize: 11)),
              ])),
              actions,
            ]),
    );
  }

  Widget _section(CriterivoxTheme t, String title, String subtitle, bool narrow, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: t.text, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: t.mutedText, fontSize: 10.5)),
        const SizedBox(height: 12),
        if (children.length == 1) ...children else if (narrow) Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children) else Row(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ],
    );
  }
}
