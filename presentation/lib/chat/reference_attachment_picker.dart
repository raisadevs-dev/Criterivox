import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ChatReference {
  final String label;
  final String kind;
  final int sizeBytes;
  final String? path;

  const ChatReference({
    required this.label,
    required this.kind,
    required this.sizeBytes,
    this.path,
  });

  String get wireValue => 'file:$label|kind=$kind|bytes=$sizeBytes';
}

class ReferenceAttachmentPicker extends StatelessWidget {
  final List<ChatReference> references;
  final ValueChanged<List<ChatReference>> onChanged;
  final VoidCallback? onAddLink;

  const ReferenceAttachmentPicker({
    super.key,
    required this.references,
    required this.onChanged,
    this.onAddLink,
  });

  Future<void> _pickFiles() async {
    final files = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const [
        'pdf', 'csv', 'json', 'txt', 'md', 'doc', 'docx',
        'png', 'jpg', 'jpeg', 'webp', 'xlsx',
      ],
    );
    if (files.isEmpty) return;

    final additions = files
        .map((file) => ChatReference(
              label: file.name,
              kind: _kindFor(file.extension),
              sizeBytes: file.size,
              path: file.path,
            ))
        .where((item) => !references.any((existing) => existing.label == item.label))
        .toList(growable: false);

    if (additions.isNotEmpty) onChanged([...references, ...additions]);
  }

  String _kindFor(String? extension) {
    switch ((extension ?? '').toLowerCase()) {
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
      case 'md':
        return 'document';
      case 'csv':
      case 'xlsx':
      case 'json':
        return 'dataset';
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'webp':
        return 'image';
      default:
        return 'file';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.attach_file_rounded, size: 17),
          label: const Text('Add reference'),
        ),
        if (onAddLink != null)
          OutlinedButton.icon(
            onPressed: onAddLink,
            icon: const Icon(Icons.link_rounded, size: 17),
            label: const Text('Add link'),
          ),
        for (final reference in references)
          InputChip(
            avatar: Icon(_iconFor(reference.kind), size: 16),
            label: Text(reference.label, overflow: TextOverflow.ellipsis),
            onDeleted: () => onChanged(
              references.where((item) => item != reference).toList(growable: false),
            ),
          ),
      ],
    );
  }

  IconData _iconFor(String kind) {
    switch (kind) {
      case 'document':
        return Icons.description_outlined;
      case 'dataset':
        return Icons.table_chart_outlined;
      case 'image':
        return Icons.image_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

Future<ChatReference?> showReferenceLinkDialog(BuildContext context) async {
  final controller = TextEditingController();
  final value = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add reference link'),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.url,
        decoration: const InputDecoration(
          hintText: 'https://…',
          labelText: 'Reference URL',
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Add')),
      ],
    ),
  );
  controller.dispose();
  if (value == null || value.isEmpty) return null;
  return ChatReference(label: value, kind: 'link', sizeBytes: 0);
}
