from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / 'presentation/lib/main.dart'
PUBSPEC = ROOT / 'presentation/pubspec.yaml'

main = MAIN.read_text(encoding='utf-8')

# Normalize artifacts from earlier repeated patch application before applying
# the integration once. This keeps the automation safe to rerun.
while "import 'chat/reference_attachment_picker.dart';\nimport 'chat/reference_attachment_picker.dart';\n" in main:
    main = main.replace(
        "import 'chat/reference_attachment_picker.dart';\nimport 'chat/reference_attachment_picker.dart';\n",
        "import 'chat/reference_attachment_picker.dart';\n",
        1,
    )
while "  List<ChatReference> chatReferences = const [];\n  List<ChatReference> chatReferences = const [];\n" in main:
    main = main.replace(
        "  List<ChatReference> chatReferences = const [];\n  List<ChatReference> chatReferences = const [];\n",
        "  List<ChatReference> chatReferences = const [];\n",
        1,
    )

if "import 'chat/reference_attachment_picker.dart';\n" not in main:
    main = main.replace(
        "import 'package:flutter/material.dart';\n",
        "import 'package:flutter/material.dart';\nimport 'chat/reference_attachment_picker.dart';\n",
        1,
    )

if "  List<ChatReference> chatReferences = const [];\n" not in main:
    main = main.replace(
        "  final chatController = TextEditingController();\n",
        "  final chatController = TextEditingController();\n  List<ChatReference> chatReferences = const [];\n",
        1,
    )

if "references: chatReferences.map((reference) => reference.toPayload()).toList(growable: false)," not in main:
    main = main.replace(
        "      context: {'description': contextController.text.trim(), 'origin': 'Dharen Inbox'},\n    );\n",
        "      context: {'description': contextController.text.trim(), 'origin': 'Dharen Inbox'},\n      references: chatReferences.map((reference) => reference.toPayload()).toList(growable: false),\n    );\n    setState(() => chatReferences = const []);\n",
        1,
    )

old_followup = """    chatController.clear();
    runtime.sendChat(taskId: id, message: message);
"""
new_followup = """    chatController.clear();
    runtime.sendChat(
      taskId: id,
      message: message,
      references: chatReferences.map((reference) => reference.toPayload()).toList(growable: false),
    );
    setState(() => chatReferences = const []);
"""
if old_followup in main:
    main = main.replace(old_followup, new_followup, 1)

picker = """        ReferenceAttachmentPicker(
          references: chatReferences,
          onChanged: (next) => setState(() => chatReferences = next),
          onAddLink: () async {
            final link = await showReferenceLinkDialog(context);
            if (link != null) setState(() => chatReferences = [...chatReferences, link]);
          },
        ),
        const SizedBox(height: 9),
"""
# Collapse repeated picker blocks, then ensure one picker exists before the chat field.
while main.count(picker) > 1:
    main = main.replace(picker + picker, picker, 1)

if picker not in main:
    anchor = "        Row(children: [\n          Expanded(child: TextField(\n            controller: chatController,"
    main = main.replace(anchor, picker + anchor, 1)

MAIN.write_text(main, encoding='utf-8')

pubspec = PUBSPEC.read_text(encoding='utf-8')
if '  file_picker:' not in pubspec:
    pubspec = pubspec.replace(
        '  cupertino_icons: ^1.0.8\n',
        '  cupertino_icons: ^1.0.8\n  file_picker: ^10.3.3\n',
        1,
    )
PUBSPEC.write_text(pubspec, encoding='utf-8')
