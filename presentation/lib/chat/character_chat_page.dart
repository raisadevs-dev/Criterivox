import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../character/session_character_animation.dart';
import '../presentation/criterivox_theme.dart';
import '../presentation/presentation_state.dart';

class CharacterChatPage extends StatefulWidget {
  final PresentationState? state;
  final bool busy;
  final Map<String, dynamic>? operationState;
  final String selectedAgent;
  final ValueChanged<String> onSelectAgent;

  final void Function(
    String message,
    String agent,
    List<Map<String, dynamic>> references,
  ) onSend;

  final VoidCallback onOpenTask;

  const CharacterChatPage({
    super.key,
    required this.state,
    required this.busy,
    this.operationState,
    required this.selectedAgent,
    required this.onSelectAgent,
    required this.onSend,
    required this.onOpenTask,
  });

  @override
  State<CharacterChatPage> createState() =>
      _CharacterChatPageState();
}

class _ChatMessage {
  final String sender;
  final String text;

  const _ChatMessage({
    required this.sender,
    required this.text,
  });
}

class _CharacterInfo {
  final String id;
  final String name;
  final String role;

  const _CharacterInfo(
    this.id,
    this.name,
    this.role,
  );
}

class _CharacterChatPageState
    extends State<CharacterChatPage> {
  final input = TextEditingController();

  final Map<String, List<_ChatMessage>>
      conversations = {};

  final Map<String, List<Map<String, dynamic>>>
      references = {};

  String? lastRuntimeSignature;

  static const registryAsset =
      'assets/character_chat/character_registry.json';

  static List<_CharacterInfo>? _registry;

  static const fallbackPrompts = <String>[
    'What can you do?',
    'What is your current state?',
    'Show the evidence.',
    'What is uncertain?',
  ];

  static const prompts = {
    'syvax': [
      'Clarify this task.',
      'Route this work.',
      'Summarize the current intent.',
    ],
    'dharen': [
      'Build the current context.',
      'Show missing context.',
      'Explain the current structure.',
    ],
    'anuka': [
      'What changed?',
      'Find a context mismatch.',
      'Re-check the current requirement.',
    ],
    'sandre': [
      'Inspect the data foundation.',
      'Show provenance gaps.',
      'Check data readiness.',
    ],
    'kaelen': [
      'Prepare a controlled experiment.',
      'Inspect scratchpad work.',
      'Record the current build state.',
    ],
    'vivren': [
      'Challenge this interpretation.',
      'Find ambiguity.',
      'Separate evidence from assumption.',
    ],
    'tarkis': [
      'Form a hypothesis.',
      'List supporting evidence.',
      'Identify what would falsify it.',
    ],
  };

  static Future<List<_CharacterInfo>>
      loadRegistry() async {
    final raw = await rootBundle.loadString(
      registryAsset,
    );

    final data =
        jsonDecode(raw) as Map<String, dynamic>;

    final characters =
        data['characters'];

    if (characters is! List) {
      return const [];
    }

    return characters
        .whereType<Map>()
        .map((entry) {
          final x =
              Map<String, dynamic>.from(entry);

          return _CharacterInfo(
            x['id'] as String,
            x['display_name'] as String,
            x['role'] as String,
          );
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();

    _loadRegistry();
    _recordRuntimeMessage(widget.state);
  }

  Future<void> _loadRegistry() async {
    try {
      final items = await loadRegistry();

      if (!mounted) {
        return;
      }

      setState(() {
        _registry = items;

        for (final member in items) {
          conversations.putIfAbsent(
            member.id,
            () => [],
          );

          references.putIfAbsent(
            member.id,
            () => [],
          );
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load character registry: $error',
          ),
        ),
      );
    }
  }

  List<_CharacterInfo> get members =>
      _registry ?? const [];

  @override
  void didUpdateWidget(
    covariant CharacterChatPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.state != oldWidget.state) {
      _recordRuntimeMessage(widget.state);
    }
  }

  void _recordRuntimeMessage(
    PresentationState? s,
  ) {
    if (s == null ||
        s.event != 'CHARACTER_CHAT_RESPONSE') {
      return;
    }

    final message = s.message?.trim();
    final target = s.agentId.toLowerCase();

    if (message == null ||
        message.isEmpty ||
        !conversations.containsKey(target)) {
      return;
    }

    final sig =
        '${s.taskId}|$target|$message|${s.taskUpdatedAt}';

    if (lastRuntimeSignature == sig) {
      return;
    }

    lastRuntimeSignature = sig;

    if (mounted) {
      setState(() {
        conversations[target]!.add(
          _ChatMessage(
            sender: target,
            text: message,
          ),
        );
      });
    }
  }

  List<_ChatMessage> get activeMessages =>
      conversations[widget.selectedAgent] ?? [];

  List<Map<String, dynamic>>
      get activeReferences =>
          references[widget.selectedAgent] ?? [];

  void _send() {
    final text = input.text.trim();

    if (text.isEmpty || widget.busy) {
      return;
    }

    setState(() {
      conversations
          .putIfAbsent(
            widget.selectedAgent,
            () => [],
          )
          .add(
            _ChatMessage(
              sender: 'user',
              text: text,
            ),
          );

      input.clear();
    });

    widget.onSend(
      text,
      widget.selectedAgent,
      List<Map<String, dynamic>>.from(
        activeReferences,
      ),
    );
  }

  void _sendChoice(String text) {
    if (widget.busy) {
      return;
    }

    setState(() {
      conversations
          .putIfAbsent(
            widget.selectedAgent,
            () => [],
          )
          .add(
            _ChatMessage(
              sender: 'user',
              text: text,
            ),
          );
    });

    widget.onSend(
      text,
      widget.selectedAgent,
      List<Map<String, dynamic>>.from(
        activeReferences,
      ),
    );
  }

  Future<void> _attach() async {
    final result =
        await FilePicker.platform.pickFiles(
      withData: true,
    );

    if (result == null ||
        result.files.isEmpty) {
      return;
    }

    final file = result.files.single;

    if (file.bytes == null) {
      _error(
        'The selected file could not be read in the browser.',
      );
      return;
    }

    if (file.bytes!.length > 4 * 1024 * 1024) {
      _error(
        'Reference files are limited to 4 MB each.',
      );
      return;
    }

    setState(() {
      references
          .putIfAbsent(
            widget.selectedAgent,
            () => [],
          )
          .add({
            'name': file.name,
            'kind': 'reference',
            'size_bytes': file.bytes!.length,
            'content_base64':
                base64Encode(file.bytes!),
          });
    });
  }

  void _error(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow =
            constraints.maxWidth < 900;

        return Container(
          color: CriterivoxTheme.of(context).page,
          child: Row(
            children: [
              if (!narrow)
                SizedBox(
                  width: 255,
                  child: _CharacterPicker(
                    selected:
                        widget.selectedAgent,
                    onSelect:
                        widget.onSelectAgent,
                  ),
                ),
              Expanded(
                child: _Conversation(
                  state: widget.state,
                  busy: widget.busy,
                  target: widget.selectedAgent,
                  messages: activeMessages,
                  references: activeReferences,
                  input: input,
                  operationState:
                      widget.operationState,
                  onSend: _send,
                  onChoice: _sendChoice,
                  onAttach: _attach,
                  onOpenTask:
                      widget.onOpenTask,
                  onSelectAgent:
                      widget.onSelectAgent,
                  showPicker: narrow,
                ),
              ),
              if (!narrow)
                SizedBox(
                  width: 290,
                  child: _ContextPanel(
                    state: widget.state,
                    target:
                        widget.selectedAgent,
                    onOpenTask:
                        widget.onOpenTask,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CharacterPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _CharacterPicker({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final registry =
        _CharacterChatPageState._registry ??
            const <_CharacterInfo>[];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: t.border,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              24,
              18,
              16,
            ),
            child: Text(
              'CHARACTER NETWORK',
              style: TextStyle(
                color: t.mutedText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: registry.length,
              itemBuilder: (context, index) {
                final member = registry[index];

                return ListTile(
                  onTap: () =>
                      onSelect(member.id),
                  selected:
                      selected == member.id,
                  leading:
                      SessionCharacterAnimationView(
                    characterId: member.id,
                    state:
                        selected == member.id
                            ? 'COMMUNICATE'
                            : 'IDLE',
                    width: 48,
                    height: 56,
                  ),
                  title: Text(
                    member.name,
                    style: TextStyle(
                      color: t.text,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    member.role,
                    style: TextStyle(
                      color: t.mutedText,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Each character has an independent conversation '
              'history. Task, context, evidence and runtime state '
              'remain shared.',
              style: TextStyle(
                color: t.mutedText,
                fontSize: 10,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Conversation extends StatelessWidget {
  final PresentationState? state;
  final bool busy;
  final String target;
  final List<_ChatMessage> messages;
  final List<Map<String, dynamic>> references;
  final TextEditingController input;
  final Map<String, dynamic>? operationState;

  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onOpenTask;

  final ValueChanged<String> onSelectAgent;
  final ValueChanged<String> onChoice;

  final bool showPicker;

  const _Conversation({
    required this.state,
    required this.busy,
    required this.target,
    required this.messages,
    required this.references,
    required this.input,
    required this.operationState,
    required this.onSend,
    required this.onChoice,
    required this.onAttach,
    required this.onOpenTask,
    required this.onSelectAgent,
    required this.showPicker,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    final registry =
        _CharacterChatPageState._registry ??
            const <_CharacterInfo>[];

    final member = registry.cast<_CharacterInfo?>().firstWhere(
          (x) => x?.id == target,
          orElse: () => null,
        ) ??
        _CharacterInfo(
          target,
          target,
          'Character workspace',
        );

    final runtimeState =
        state?.agentId.toLowerCase() == target
            ? (state?.characterState ?? 'IDLE')
            : 'IDLE';

    final promptList =
        _CharacterChatPageState.prompts[target] ??
            _CharacterChatPageState
                .fallbackPrompts;

    return Column(
      children: [
        Container(
          height: 86,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: t.border,
              ),
            ),
          ),
          child: Row(
            children: [
              SessionCharacterAnimationView(
                characterId: target,
                state: runtimeState,
                width: 60,
                height: 68,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chat with ${member.name}',
                      style: TextStyle(
                        color: t.text,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    Text(
                      member.role,
                      style: TextStyle(
                        color: t.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (showPicker)
                PopupMenuButton<String>(
                  onSelected: onSelectAgent,
                  itemBuilder: (_) => [
                    for (final member in registry)
                      PopupMenuItem(
                        value: member.id,
                        child: Text(
                          '${member.name} · ${member.role}',
                        ),
                      ),
                  ],
                ),
              if (busy)
                SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: t.primary,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding:
                const EdgeInsets.all(24),
            children: [
              _Welcome(member: member),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final prompt
                      in promptList)
                    ActionChip(
                      label: Text(prompt),
                      onPressed: busy
                          ? null
                          : () =>
                              onChoice(prompt),
                    ),
                ],
              ),
              if (operationState != null) ...[
                const SizedBox(height: 12),
                _OperationCard(
                  state: operationState!,
                ),
              ],
              const SizedBox(height: 14),
              for (final message in messages)
                _MessageBubble(
                  message: message,
                  displayName:
                      member.name,
                ),
              if (state?.agentId
                          .toLowerCase() ==
                      target &&
                  state?.event ==
                      'HANDOFF_PROPOSED')
                _HandoffChoices(
                  busy: busy,
                  onHandoff: () => onChoice(
                    'Hand over this task to Dharen.',
                  ),
                  onContinue: () => onChoice(
                    'I will continue the task here.',
                  ),
                ),
              if (state?.agentId
                          .toLowerCase() ==
                      target &&
                  state?.taskId != null)
                _TaskCard(
                  state: state!,
                  onOpen: onOpenTask,
                ),
            ],
          ),
        ),
        _Composer(
          input: input,
          references: references,
          busy: busy,
          name: member.name,
          onSend: onSend,
          onAttach: onAttach,
        ),
      ],
    );
  }
}

class _Welcome extends StatelessWidget {
  final _CharacterInfo member;

  const _Welcome({
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    return Container(
      margin:
          const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.surfaceStrong,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: t.border,
        ),
      ),
      child: Text(
        '${member.name} workspace\n\n'
        'This conversation belongs only to '
        '${member.name}. Shared task and context '
        'state remains outside the conversation buffer.',
        style: TextStyle(
          color: t.text,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final String displayName;

  const _MessageBubble({
    required this.message,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final isUser =
        message.sender == 'user';

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 680,
        ),
        margin:
            const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? t.primary.withValues(alpha: .14)
              : t.surfaceStrong,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: isUser
                ? t.primary
                    .withValues(alpha: .35)
                : t.border,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Text(
                displayName,
                style: TextStyle(
                  color: t.primary,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: t.text,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController input;
  final List<Map<String, dynamic>>
      references;
  final bool busy;
  final String name;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const _Composer({
    required this.input,
    required this.references,
    required this.busy,
    required this.name,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        18,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CriterivoxTheme.of(context)
                .border,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Attach reference',
            onPressed:
                busy ? null : onAttach,
            icon: const Icon(
              Icons.attach_file_rounded,
            ),
          ),
          Expanded(
            child: TextField(
              controller: input,
              minLines: 1,
              maxLines: 5,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Message $name…',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed:
                busy ? null : onSend,
            icon: const Icon(
              Icons.arrow_upward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _HandoffChoices
    extends StatelessWidget {
  final bool busy;
  final VoidCallback onHandoff;
  final VoidCallback onContinue;

  const _HandoffChoices({
    required this.busy,
    required this.onHandoff,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        OutlinedButton(
          onPressed:
              busy ? null : onHandoff,
          child: const Text(
            'Hand over to Dharen',
          ),
        ),
        FilledButton(
          onPressed:
              busy ? null : onContinue,
          child: const Text(
            'Continue here',
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final PresentationState state;
  final VoidCallback onOpen;

  const _TaskCard({
    required this.state,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onOpen,
      child: Text(
        '${state.taskId} • '
        '${state.taskState ?? 'ACTIVE'}',
      ),
    );
  }
}

class _OperationCard
    extends StatelessWidget {
  final Map<String, dynamic> state;

  const _OperationCard({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    final command = state['command'] is Map
        ? Map<String, dynamic>.from(
            state['command'] as Map,
          )
        : <String, dynamic>{};

    final authorization =
        state['authorization'] is Map
            ? Map<String, dynamic>.from(
                state['authorization'] as Map,
              )
            : null;

    final action = state['action'] is Map
        ? Map<String, dynamic>.from(
            state['action'] as Map,
          )
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surfaceStrong,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: t.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'OPERATION STATE',
            style: TextStyle(
              color: t.primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intent: '
            '${command['intent']?.toString() ?? 'n/a'}',
          ),
          Text(
            'Capability: '
            '${command['requested_capability']?.toString() ?? 'not resolved'}',
          ),
          Text(
            'Responsible: '
            '${command['responsible_character']?.toString() ?? 'not assigned'}',
          ),
          Text(
            'Authorization: '
            '${authorization?['authorization_state']?.toString() ?? command['authorization_state']?.toString() ?? 'n/a'}',
          ),
          Text(
            'Action: '
            '${action?['status']?.toString() ?? 'not prepared'}',
          ),
          Text(
            'Classification: '
            '${state['classification']?.toString() ?? command['status']?.toString() ?? 'RECORDED_FACT'}',
          ),
        ],
      ),
    );
  }
}

class _ContextPanel
    extends StatelessWidget {
  final PresentationState? state;
  final String target;
  final VoidCallback onOpenTask;

  const _ContextPanel({
    required this.state,
    required this.target,
    required this.onOpenTask,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    final registry =
        _CharacterChatPageState._registry ??
            const <_CharacterInfo>[];

    final member =
        registry.cast<_CharacterInfo?>().firstWhere(
              (x) => x?.id == target,
              orElse: () => null,
            ) ??
            _CharacterInfo(
              target,
              target,
              'Character workspace',
            );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: t.border,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE CONTEXT',
            style: TextStyle(
              color: t.mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SessionCharacterAnimationView(
            characterId: target,
            state:
                state?.agentId.toLowerCase() ==
                        target
                    ? (state?.characterState ??
                        'IDLE')
                    : 'IDLE',
            width: 120,
            height: 140,
          ),
          Text(
            member.name,
            style: TextStyle(
              color: t.text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            member.role,
            style: TextStyle(
              color: t.mutedText,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Task: ${state?.taskId ?? 'None'}',
          ),
          Text(
            'State: ${state?.taskState ?? 'IDLE'}',
          ),
          Text(
            'Context: ${state?.contextId ?? 'Not built'}',
          ),
          Text(
            'Evidence: '
            '${state?.evidence.length ?? 0} items',
          ),
          const Spacer(),
          if (state?.taskId != null)
            FilledButton(
              onPressed: onOpenTask,
              child: const Text(
                'Open current task',
              ),
            ),
        ],
      ),
    );
  }
}