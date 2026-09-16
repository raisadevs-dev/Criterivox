import 'package:flutter/material.dart';

import 's7_conversation_engine.dart';

class S7NlpDebateArena extends StatefulWidget {
  const S7NlpDebateArena({super.key});

  @override
  State<S7NlpDebateArena> createState() => _S7NlpDebateArenaState();
}

class _S7NlpDebateArenaState extends State<S7NlpDebateArena> {
  final TextEditingController controller = TextEditingController();
  final S7ConversationEngine engine = S7ConversationEngine();
  final List<_NlpMessage> messages = <_NlpMessage>[
    const _NlpMessage(
      'VIVREN',
      'Critical inspection is ready. Ask about evidence, contradictions, context, provenance, or reasoning integrity.',
    ),
    const _NlpMessage(
      'TARKIS',
      'Hypothesis exploration is ready. Ask for alternatives, branches, scenarios, comparisons, or tests.',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit(String text) {
    final String clean = text.trim();
    if (clean.isEmpty) {
      return;
    }

    final S7ConversationAction action = engine.process(clean);
    final String intentName = action.intent.name;

    setState(() {
      messages.add(
        _NlpMessage(
          'HUMAN',
          clean,
          intent: intentName,
          confidence: action.confidence,
        ),
      );

      final String actor = action.actor.toUpperCase();
      messages.add(
        _NlpMessage(
          actor,
          action.message,
          intent: intentName,
          confidence: action.confidence,
          target: action.target,
          clarification: action.requiresClarification,
        ),
      );
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(18),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 820,
          maxHeight: 700,
        ),
        decoration: BoxDecoration(
          color: const Color(0xff111526).withValues(alpha: .98),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: Colors.white.withValues(alpha: .12),
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 17, 12, 12),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.forum_rounded,
                    color: Color(0xffb59cff),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'DEBATE ARENA',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'LOCAL NLP • NO ONLINE LLM • CONVERSATION STATE',
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.0,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              color: Colors.white10,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _Bubble(message: messages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: <String>[
                        'challenge this',
                        'show evidence',
                        'find alternatives',
                        'compare hypotheses',
                        'why?',
                      ].map((String text) {
                        return ActionChip(
                          label: Text(
                            text,
                            style: const TextStyle(fontSize: 9),
                          ),
                          onPressed: () {
                            submit(text);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 4,
                          onSubmitted: submit,
                          decoration: const InputDecoration(
                            hintText:
                                'Challenge, compare, request context, or redirect...',
                            prefixIcon: Icon(Icons.psychology_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          submit(controller.text);
                        },
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NlpMessage {
  const _NlpMessage(
    this.actor,
    this.text, {
    this.intent,
    this.confidence,
    this.target,
    this.clarification = false,
  });

  final String actor;
  final String text;
  final String? intent;
  final double? confidence;
  final String? target;
  final bool clarification;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final _NlpMessage message;

  @override
  Widget build(BuildContext context) {
    final Color accent = message.actor == 'VIVREN'
        ? const Color(0xffb59cff)
        : message.actor == 'TARKIS'
            ? const Color(0xffffb463)
            : Colors.white;

    final List<String> metadataParts = <String>[
      if (message.intent != null) message.intent!.toUpperCase(),
      if (message.target != null) 'TARGET: ${message.target}',
      if (message.confidence != null)
        '${(message.confidence! * 100).round()}% LOCAL',
      if (message.clarification) 'CLARIFICATION REQUIRED',
    ];
    final String metadata = metadataParts.join(' • ');

    return Align(
      alignment: message.actor == 'HUMAN'
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.sizeOf(context).width * .72,
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .055),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: accent.withValues(alpha: .16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.actor,
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
            if (metadata.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  metadata,
                  style: TextStyle(
                    fontSize: 7,
                    letterSpacing: .8,
                    color: accent.withValues(alpha: .5),
                  ),
                ),
              ),
            const SizedBox(height: 5),
            Text(
              message.text,
              style: const TextStyle(
                fontSize: 11,
                height: 1.45,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
