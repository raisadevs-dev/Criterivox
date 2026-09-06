from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / 'presentation/lib/main.dart'
PUBSPEC = ROOT / 'presentation/pubspec.yaml'

main = MAIN.read_text(encoding='utf-8')
main = main.replace(
    "import 'package:flutter/material.dart';\n",
    "import 'package:flutter/material.dart';\nimport 'chat/reference_attachment_picker.dart';\n",
    1,
)
main = main.replace(
    "  final chatController = TextEditingController();\n",
    "  final chatController = TextEditingController();\n  List<ChatReference> chatReferences = const [];\n",
    1,
)
main = main.replace(
    "      context: {'description': contextController.text.trim(), 'origin': 'Dharen Inbox'},\n    );\n",
    "      context: {'description': contextController.text.trim(), 'origin': 'Dharen Inbox'},\n      references: chatReferences.map((reference) => reference.toPayload()).toList(growable: false),\n    );\n    setState(() => chatReferences = const []);\n",
    1,
)
old = """        Row(children: [
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
        ]),"""
new = """        ReferenceAttachmentPicker(
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
        ]),"""
if old not in main:
    raise SystemExit('Expected Dharen Inbox chat input block was not found')
main = main.replace(old, new, 1)
MAIN.write_text(main, encoding='utf-8')

pubspec = PUBSPEC.read_text(encoding='utf-8')
if '  file_picker:' not in pubspec:
    pubspec = pubspec.replace(
        '  cupertino_icons: ^1.0.8\n',
        '  cupertino_icons: ^1.0.8\n  file_picker: ^10.3.3\n',
        1,
    )
PUBSPEC.write_text(pubspec, encoding='utf-8')
