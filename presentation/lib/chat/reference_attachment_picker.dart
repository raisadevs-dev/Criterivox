import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ChatReference {
  final String label;
  final String kind;
  final int sizeBytes;
  final String? path;
  final String? contentBase64;

  const ChatReference({
    required this.label,
    required this.kind,
    required this.sizeBytes,
    this.path,
    this.contentBase64,
  });

  Map<String, dynamic> toPayload() => {
        'name': label,
        'kind': kind,
        'size_bytes': sizeBytes,
        if (contentBase64 != null) 'content_base64': contentBase64,
      };
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
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const [
        'pdf', 'csv', 'json', 'txt', 'md', 'doc', 'docx',
        'png', 'jpg', 'jpeg', 'webp', 'xlsx',
      ],
    );
    if (result == null || result.files.isEmpty) return;

    final additions = <ChatReference>[];
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      if (bytes.length > 4 * 1024 * 1024) continue;
      final item = ChatReference(
        label: file.name,
        kind: _kindFor(file.extension),
        sizeBytes: bytes.length,
        path: file.path,
        contentBase64: base64Encode(bytes),
      );
      if (!references.any((existing) => existing.label == item.label) &&
          !additions.any((existing) => existing.label == item.label)) {
        additions.add(item);
      }
    }

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
      case 'link':
        return Icons.link_rounded;
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
