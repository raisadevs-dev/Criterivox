import 'package:flutter/material.dart';
import 'chat/reference_attachment_picker.dart';
import 'chat/reference_attachment_picker.dart';
import 'character/character_presentation.dart';
import 'interaction/bloom.dart';
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';

void main() => runApp(const CriterivoxApp());

class CriterivoxApp extends StatelessWidget {
  const CriterivoxApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Criterivox',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF050712),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8067FF),
            brightness: Brightness.dark,
          ),
        ),
        home: const CriterivoxScreen(),
      );
}

class CriterivoxScreen extends StatefulWidget {
  const CriterivoxScreen({super.key});
  @override
  State<CriterivoxScreen> createState() => _CriterivoxScreenState();
}

class _CriterivoxScreenState extends State<CriterivoxScreen> {
  final runtime = CharacterRuntimeClient();
  final taskController = TextEditingController(text: 'Analyze the supplied information in its current context.');
  final dataController = TextEditingController(text: 'Local sample dataset for structural analysis');
  final contextController = TextEditingController(text: 'Synthetic local research data');
  final chatController = TextEditingController();
  List<ChatReference> chatReferences = const [];
  List<ChatReference> chatReferences = const [];
  PresentationState? state;
  BloomCapability? selected;
  String surface = 'bloom';
  String? error;
  bool chooser = false;
  bool busy = false;
  bool notification = false;

  @override
  void initState() {
    super.initState();
    runtime.states.listen((next) {
      if (!mounted) return;
      final completed = next.taskState == 'COMPLETED' && state?.taskState != 'COMPLETED';
      setState(() {
        state = next;
        busy = false;
        error = next.error;
        if (completed) notification = true;
      });
    });
    runtime.errors.listen((message) {
      if (!mounted) return;
      setState(() { error = message; busy = false; });
    });
    runtime.connect();
  }

  @override
  void dispose() {
    runtime.dispose();
    taskController.dispose();
    dataController.dispose();
    contextController.dispose();
    chatController.dispose();
    super.dispose();
  }

  void chooseBloom(BloomCapability capability) {
    if (capability != BloomCapability.analyze) return;
    setState(() { selected = capability; chooser = true; surface = 'bloom'; });
  }

  void openWorkspace() => setState(() { surface = 'workspace'; chooser = false; });
  void openChat() => setState(() { surface = 'chat'; chooser = false; });

  void startWorkspaceTask() {
    final task = taskController.text.trim();
    if (task.isEmpty) {
      setState(() => error = 'A task description is required.');
      return;
    }
    setState(() { busy = true; error = null; surface = 'workspace'; chooser = false; notification = false; });
    runtime.requestApplication(
      intent: 'analyze',
      task: task,
      data: {'dataset': dataController.text.trim(), 'records': 3},
      context: {'description': contextController.text.trim(), 'origin': 'Analysis Workspace'},
      source: 'workspace',
    );
  }

  void startChatTask() {
    final message = chatController.text.trim();
    if (message.isEmpty) return;
    setState(() { busy = true; error = null; surface = 'chat'; notification = false; });
    chatController.clear();
    runtime.sendChat(
      message: message,
      data: {'dataset': dataController.text.trim(), 'records': 3},
      context: {'description': contextController.text.trim(), 'origin': 'Dharen Inbox'},
      references: chatReferences.map((reference) => reference.toPayload()).toList(growable: false),
    );
    setState(() => chatReferences = const []);
  }

  void sendFollowup() {
    final id = state?.taskId;
    final message = chatController.text.trim();
    if (id == null || message.isEmpty) return;
    chatController.clear();
    runtime.sendChat(
      taskId: id,
      message: message,
      references: chatReferences.map((reference) => reference.toPayload()).toList(growable: false),
    );
    setState(() => chatReferences = const []);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          const Positioned.fill(child: _Backdrop()),
          SafeArea(
            child: Column(children: [
              const _Header(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                    child: _body(constraints.maxWidth < 980),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      );

  Widget _body(bool compact) {
    if (surface == 'bloom') {
      return Column(children: [
        const _Title('Capability Gateway', 'Choose a capability. Analyze is the active S4 experience.'),
        _Panel(child: SizedBox(height: 610, child: Bloom(selected: selected, onSelected: chooseBloom))),
        if (chooser) _EntryChooser(openWorkspace: openWorkspace, openChat: openChat),
      ]);
    }

    return Column(children: [
      _WorkspaceHeader(surface: surface, taskId: state?.taskId, taskState: state?.taskState, onBack: () => setState(() => surface = 'bloom'), onWorkspace: openWorkspace, onChat: openChat),
      if (error != null) _ErrorBanner(error!),
      if (notification) _CompletionNotification(onOpen: openWorkspace),
      if (compact) ...[
        _PrimaryPanel(), const SizedBox(height: 14), _DharenInbox(), const SizedBox(height: 14), _WorkspaceData(),
      ] else Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 7, child: _PrimaryPanel()),
        const SizedBox(width: 14),
        Expanded(flex: 3, child: _DharenInbox()),
      ]),
      const SizedBox(height: 14),
      _ActivityAndResults(),
    ]);
  }

  Widget _PrimaryPanel() => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.analytics_outlined, color: Color(0xFF8E7BFF)),
          const SizedBox(width: 9),
          const Text('Analysis Workspace', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (state?.taskId != null) Text(state!.taskId!, style: const TextStyle(color: Color(0xFF888FAE), fontSize: 11)),
        ]),
        const SizedBox(height: 14),
        _DharenHome(),
        const SizedBox(height: 16),
        if (state?.taskId == null) _TaskComposer() else _LiveTask(),
      ]));

  Widget _DharenHome() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0x5E12162E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x2D4C428C)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: 245,
            child: state == null ? const _DharenPlaceholder() : CharacterPresentation(state: state!),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Dharen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            const Text('Structural Context', style: TextStyle(color: Color(0xFF969DB8), fontSize: 11)),
            const SizedBox(height: 14),
            _StatusPill(state?.characterState ?? 'IDLE'),
            const SizedBox(height: 12),
            Text(state?.message ?? 'Dharen is ready to receive an analysis task.', style: const TextStyle(color: Color(0xFFC2C7D9), fontSize: 12, height: 1.45)),
            if (state?.taskState != null) ...[
              const SizedBox(height: 12),
              Text('Authoritative task state: ${state!.taskState}', style: const TextStyle(color: Color(0xFF9E91FF), fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ])),
        ]),
      );

  Widget _TaskComposer() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Start an analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        const Text('The information below becomes the shared Analysis Task used by Workspace and Dharen Inbox.', style: TextStyle(color: Color(0xFFA5ABC2), fontSize: 12)),
        const SizedBox(height: 18),
        _Field('Task', taskController, 2),
        const SizedBox(height: 12),
        _Field('Data', dataController, 1),
        const SizedBox(height: 12),
        _Field('Context', contextController, 1),
        const SizedBox(height: 16),
        Row(children: [
          const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF63D7C1)),
          const SizedBox(width: 7),
          const Expanded(child: Text('Local synthetic data. No external intelligence is claimed by this S4 flow.', style: TextStyle(color: Color(0xFF9CA4BD), fontSize: 11))),
          FilledButton.icon(onPressed: busy ? null : startWorkspaceTask, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Start Analysis')),
        ]),
      ]);

  Widget _LiveTask() {
    final s = state!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _StatusPill(s.taskState ?? 'UNKNOWN'),
        const SizedBox(width: 10),
        Expanded(child: Text(s.task ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 16),
      _Lifecycle(s.taskState ?? 'CREATED'),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _Metric('Data fields', '${s.taskDataFields ?? 0}')),
        Expanded(child: _Metric('Context fields', '${s.taskContextFields ?? 0}')),
        Expanded(child: _Metric('Observations', '${s.observations.length}')),
        Expanded(child: _Metric('Findings', '${s.findings.length}')),
      ]),
    ]);
  }

  Widget _WorkspaceData() => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Data & Context', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _InfoLine(Icons.storage_outlined, 'Data', state?.taskDataFields == null ? 'Awaiting task' : '${state!.taskDataFields} top-level fields recorded'),
        _InfoLine(Icons.account_tree_outlined, 'Context', state?.taskContextFields == null ? 'Awaiting task' : '${state!.taskContextFields} contextual fields recorded'),
        _InfoLine(Icons.link_rounded, 'Source', state?.taskSource ?? 'Not started'),
      ]));

  Widget _DharenInbox() => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.forum_outlined, color: Color(0xFF9B86FF)),
          const SizedBox(width: 8),
          const Text('Dharen Inbox', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          _StatusPill(state?.taskState ?? 'IDLE'),
        ]),
        const SizedBox(height: 12),
        if (state == null || state!.taskId == null)
          const _EmptyInbox()
        else ...[
          _ChatBubble(state!.message ?? 'Dharen is ready.'),
          if (state!.taskState == 'COMPLETED') ...[
            const SizedBox(height: 9),
            const _ChatBubble('The analysis is complete. The result is available in the workspace.'),
          ],
        ],
        const SizedBox(height: 12),
        ReferenceAttachmentPicker(
          references: chatReferences,
          onChanged: (next) => setState(() => chatReferences = next),
          onAddLink: () async {
            final link = await showReferenceLinkDialog(context);
            if (link != null) setState(() => chatReferences = [...chatReferences, link]);
          },
        ),
        const SizedBox(height: 9),
        ReferenceAttachmentPicker(
          references: chatReferences,
          onChanged: (next) => setState(() => chatReferences = next),
          onAddLink: () async {
            final link = await showReferenceLinkDialog(context);
            if (link != null) setState(() => chatReferences = [...chatReferences, link]);
          },
        ),
        const SizedBox(height: 9),
        Row(children: [
          Expanded(child: TextField(
            controller: chatController,
            minLines: 1,
            maxLines: 3,
            onSubmitted: (_) => state?.taskId == null ? startChatTask() : sendFollowup(),
            decoration: InputDecoration(
              hintText: state?.taskId == null ? 'Start a task with Dharen…' : 'Ask Dharen about this task…',
              filled: true,
              fillColor: const Color(0x6610142E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          )),
          const SizedBox(width: 7),
          IconButton.filled(onPressed: state?.taskId == null ? startChatTask : sendFollowup, icon: const Icon(Icons.arrow_upward_rounded)),
        ]),
      ]));

  Widget _ActivityAndResults() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recent Observations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (state == null || state!.observations.isEmpty)
            const Text('Observations will appear here when the task produces them.', style: TextStyle(color: Color(0xFF8E95AE), fontSize: 12))
          else for (final item in state!.observations) _Observation('${item['text'] ?? ''}', '${item['significance'] ?? 'observed'}'),
        ]))),
        const SizedBox(width: 14),
        Expanded(child: _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Findings & Evidence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (state == null || state!.findings.isEmpty)
            const Text('Findings will appear here after analysis.', style: TextStyle(color: Color(0xFF8E95AE), fontSize: 12))
          else for (final item in state!.findings) _Finding('${item['statement'] ?? ''}'),
          if (state?.evidence.isNotEmpty == true) ...[
            const Divider(height: 24),
            const Text('Evidence', style: TextStyle(fontWeight: FontWeight.w600)),
            for (final item in state!.evidence) _Observation('${item['label'] ?? ''}: ${item['detail'] ?? ''}', '${item['source'] ?? 'source'}'),
          ],
        ]))),
        const SizedBox(width: 14),
        Expanded(child: _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (state == null || state!.activity.isEmpty)
            const Text('Task activity will be recorded here.', style: TextStyle(color: Color(0xFF8E95AE), fontSize: 12))
          else for (final item in state!.activity.reversed.take(8)) Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.circle, size: 5, color: Color(0xFF8C75FF)), const SizedBox(width: 8), Expanded(child: Text(item, style: const TextStyle(color: Color(0xFFB9BED2), fontSize: 11, height: 1.4))),
          ])),
        ]))),
      ]);
}

class _EntryChooser extends StatelessWidget {
  final VoidCallback openWorkspace;
  final VoidCallback openChat;
  const _EntryChooser({required this.openWorkspace, required this.openChat});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 14), child: _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Analyze', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
    const SizedBox(height: 5),
    const Text('Two entry points. One analysis task. One Dharen.', style: TextStyle(color: Color(0xFFAAB0C8))),
    const SizedBox(height: 18),
    Row(children: [
      Expanded(child: _ActionCard(Icons.grid_view_rounded, 'Open Analysis Workspace', 'Work visually with task, context, observations, findings, and Dharen.', openWorkspace)),
      const SizedBox(width: 12),
      Expanded(child: _ActionCard(Icons.chat_bubble_outline_rounded, 'Chat with Dharen', 'Give Dharen the analysis request directly through his inbox.', openChat)),
    ]),
  ])));
}

class _WorkspaceHeader extends StatelessWidget {
  final String surface;
  final String? taskId;
  final String? taskState;
  final VoidCallback onBack;
  final VoidCallback onWorkspace;
  final VoidCallback onChat;
  const _WorkspaceHeader({required this.surface, required this.taskId, required this.taskState, required this.onBack, required this.onWorkspace, required this.onChat});
  @override
  Widget build(BuildContext context) => Row(children: [
    IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)),
    const SizedBox(width: 4),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Analysis Workspace', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      Text(taskId == null ? 'Dharen’s Home • New analysis' : 'Dharen’s Home • Task $taskId', style: const TextStyle(color: Color(0xFF9BA2BF), fontSize: 12)),
    ])),
    _StatusPill(taskState ?? 'NO TASK'),
    const SizedBox(width: 10),
    OutlinedButton.icon(onPressed: surface == 'chat' ? onWorkspace : onChat, icon: Icon(surface == 'chat' ? Icons.grid_view_rounded : Icons.chat_bubble_outline_rounded, size: 16), label: Text(surface == 'chat' ? 'Open Workspace' : 'Chat with Dharen')),
  ]);
}

class _Title extends StatelessWidget {
  final String title, subtitle;
  const _Title(this.title, this.subtitle);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(4, 6, 4, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Color(0xFF949BB7), fontSize: 12))]));
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xB50B0F23), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0x23384470)), boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 20)]), child: child);
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title, text; final VoidCallback onTap;
  const _ActionCard(this.icon, this.title, this.text, this.onTap);
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0x66121631), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0x334A3D90))), child: Row(children: [Container(width: 43, height: 43, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x302E2469)), child: Icon(icon, color: const Color(0xFFAA98FF))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(text, style: const TextStyle(color: Color(0xFF9DA4BE), fontSize: 11, height: 1.35))])), const Icon(Icons.arrow_forward_rounded, color: Color(0xFF8C78FF))])));
}

class _Field extends StatelessWidget {
  final String label; final TextEditingController controller; final int maxLines;
  const _Field(this.label, this.controller, this.maxLines);
  @override Widget build(BuildContext context) => TextField(controller: controller, maxLines: maxLines, decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0x55121730), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x223E4778))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x223E4778))));
}

class _Metric extends StatelessWidget {
  final String label, value;
  const _Metric(this.label, this.value);
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(right: 7), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0x55121730), borderRadius: BorderRadius.circular(11)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Color(0xFF8F97B0), fontSize: 10))]));
}

class _InfoLine extends StatelessWidget {
  final IconData icon; final String label, value;
  const _InfoLine(this.icon, this.label, this.value);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 11), child: Row(children: [Icon(icon, size: 17, color: const Color(0xFF8273D7)), const SizedBox(width: 9), Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9BA2BB))), const Spacer(), Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Color(0xFFD1D4E2))))]));
}

class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill(this.text);
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0x1A806BFF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x354D4291))), child: Text(text, style: const TextStyle(fontSize: 9, letterSpacing: .8, fontWeight: FontWeight.w700, color: Color(0xFFB8ABFF))));
}

class _Lifecycle extends StatelessWidget {
  final String state;
  const _Lifecycle(this.state);
  @override Widget build(BuildContext context) {
    const states = ['CREATED', 'RECEIVED', 'VALIDATING', 'PROCESSING', 'ANALYZING', 'RESULT_READY', 'COMPLETED'];
    final index = states.indexOf(state);
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (var i = 0; i < states.length; i++) ...[
      Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: i <= index ? const Color(0xFF8C75FF) : const Color(0xFF303550))),
      if (i < states.length - 1) Container(width: 35, height: 1, color: i < index ? const Color(0xFF6C5AB9) : const Color(0xFF252A43)),
    ]]));
  }
}

class _Observation extends StatelessWidget {
  final String text, tag;
  const _Observation(this.text, this.tag);
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0x55121630), borderRadius: BorderRadius.circular(10)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.radio_button_checked_rounded, size: 14, color: Color(0xFF5BCBC2)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(text, style: const TextStyle(color: Color(0xFFC5CADB), fontSize: 11, height: 1.35)), const SizedBox(height: 4), Text(tag.toUpperCase(), style: const TextStyle(color: Color(0xFF777F9F), fontSize: 8, letterSpacing: .7))]))]));
}

class _Finding extends StatelessWidget {
  final String text;
  const _Finding(this.text);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 11), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.insights_outlined, size: 16, color: Color(0xFF9B84FF)), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: Color(0xFFC8CCDC), fontSize: 11, height: 1.45)))]));
}

class _ChatBubble extends StatelessWidget {
  final String text;
  const _ChatBubble(this.text);
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0x50161B34), borderRadius: BorderRadius.circular(12)), child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFFC7CBDC), height: 1.4)));
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 22), alignment: Alignment.center, child: const Column(children: [Icon(Icons.forum_outlined, color: Color(0xFF555C7C), size: 30), SizedBox(height: 8), Text('Dharen is ready.', style: TextStyle(color: Color(0xFFA6ACC3, fontWeight: FontWeight.w600)), SizedBox(height: 3), Text('Start here or create a task in the workspace.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF777F9A, fontSize: 10))]));
}

class _DharenPlaceholder extends StatelessWidget {
  const _DharenPlaceholder();
  @override Widget build(BuildContext context) => Container(height: 260, alignment: Alignment.center, child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_outline_rounded, size: 55, color: Color(0xFF6757A8)), SizedBox(height: 8), Text('Dharen • IDLE', style: TextStyle(color: Color(0xFF9EA5BF, fontWeight: FontWeight.w600))]));
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  const _ErrorBanner(this.text);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 12), child: Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0x331E1425), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x663F2B54))), child: Row(children: [const Icon(Icons.warning_amber_rounded, size: 17, color: Color(0xFFFFB4A8)), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: Color(0xFFFFC1B8), fontSize: 11)))])));
}

class _CompletionNotification extends StatelessWidget {
  final VoidCallback onOpen;
  const _CompletionNotification({required this.onOpen});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 12), child: _Panel(child: Row(children: [const Icon(Icons.check_circle_rounded, color: Color(0xFF55D6B5)), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Analysis completed', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 3), Text('The authoritative task reached COMPLETED. Results are available in the workspace.', style: TextStyle(color: Color(0xFF969DB6), fontSize: 11))])), TextButton(onPressed: onOpen, child: const Text('Open Workspace'))])));
}

class _Header extends StatelessWidget {
  const _Header();
  @override Widget build(BuildContext context) => Container(height: 64, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: const BoxDecoration(color: Color(0xCC060918), border: Border(bottom: BorderSide(color: Color(0x22313A63)))), child: Row(children: [const Icon(Icons.hub_rounded, color: Color(0xFF8B76FF), size: 29), const SizedBox(width: 10), const Text('CRITERIVOX', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: 1.1)), const Spacer(), const Icon(Icons.notifications_none_rounded, color: Color(0xFFBFC4D8)), const SizedBox(width: 18), const CircleAvatar(radius: 17, backgroundColor: Color(0xFF292D4C), child: Icon(Icons.person_rounded, size: 18)), const SizedBox(width: 8), const Text('Researcher', style: TextStyle(fontSize: 11, color: Color(0xFFB8BDD0)))]);
}

class _Backdrop extends StatelessWidget { const _Backdrop(); @override Widget build(BuildContext context) => CustomPaint(painter: _BackdropPainter()); }
class _BackdropPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = const RadialGradient(center: Alignment(0, -.15), radius: 1.15, colors: [Color(0xFF171A42), Color(0xFF090C20), Color(0xFF040610)], stops: [0, .5, 1]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
    final glow = Paint()..color = const Color(0x121C4BFF)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(Offset(size.width * .5, size.height * .42), size.width * .16, glow);
  }
  @override bool shouldRepaint(covariant _BackdropPainter oldDelegate) => false;
}
