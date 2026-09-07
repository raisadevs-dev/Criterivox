import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Syvax extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final bool busy;
  const Syvax({super.key, required this.onSubmit, this.busy = false});
  @override State<Syvax> createState() => _SyvaxState();
}

class _SyvaxState extends State<Syvax> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  static const suggestions = ['Analyze the supplied data in the provided context.', 'Analyze these student engagement metrics.', 'Analyze the current synthetic dataset.'];
  @override void dispose() { _controller.dispose(); _focusNode.dispose(); super.dispose(); }
  void _submit() { final text = _controller.text.trim(); if (text.isNotEmpty && !widget.busy) widget.onSubmit(text); }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true, label: 'Syvax, human-system dialogue host',
    child: Container(width: 360, padding: const EdgeInsets.all(18), decoration: BoxDecoration(
      color: const Color(0xD90E112B), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0x443A3D72)),
      boxShadow: const [BoxShadow(color: Color(0x331A1E58), blurRadius: 30, spreadRadius: 4)],
    ), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [_SyvaxAvatar(busy: widget.busy), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Syvax', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w600)), SizedBox(height: 2), Text('Human-machine dialogue', style: TextStyle(color: Color(0xFF9DA4C7), fontSize: 11)),
      ])), Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.busy ? const Color(0xFFFFB24A) : const Color(0xFF48E1A1), boxShadow: [BoxShadow(color: (widget.busy ? const Color(0xFFFFB24A) : const Color(0xFF48E1A1)).withOpacity(.55), blurRadius: 9)]))]),
      const SizedBox(height: 16), Text('What would you like to do?', style: TextStyle(color: Colors.white.withOpacity(.92), fontSize: 14, fontWeight: FontWeight.w500)), const SizedBox(height: 10),
      TextField(controller: _controller, focusNode: _focusNode, minLines: 2, maxLines: 4, textInputAction: TextInputAction.done, onSubmitted: (_) => _submit(), style: const TextStyle(color: Colors.white, fontSize: 13), decoration: InputDecoration(
        hintText: 'Describe what you want Criterivox to do…', hintStyle: const TextStyle(color: Color(0xFF6F769D), fontSize: 12), filled: true, fillColor: const Color(0x66191D3A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0x332F3765))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0x332F3765))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF7665FF))), contentPadding: const EdgeInsets.all(14))),
      const SizedBox(height: 10), Wrap(spacing: 6, runSpacing: 6, children: [for (final suggestion in suggestions) ActionChip(
        avatar: const Icon(Icons.auto_awesome, size: 12, color: Color(0xFF9D8CFF)), label: Text(suggestion, style: const TextStyle(fontSize: 9.5, color: Color(0xFFC8CCDF))), backgroundColor: const Color(0x55191D3A), side: const BorderSide(color: Color(0x223A4271)),
        onPressed: widget.busy ? null : () { _controller.text = suggestion; _focusNode.requestFocus(); },
      )]), const SizedBox(height: 12),
      FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6E55F5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: widget.busy ? null : _submit,
        icon: widget.busy ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_upward_rounded, size: 18), label: Text(widget.busy ? 'Working…' : 'Send to Criterivox')),
    ])),
  );
}

class _SyvaxAvatar extends StatelessWidget {
  final bool busy;
  const _SyvaxAvatar({required this.busy});
  @override Widget build(BuildContext context) => SizedBox(
    width: 58,
    height: 58,
    child: AnimatedScale(
      scale: busy ? 1.05 : 1,
      duration: const Duration(milliseconds: 280),
      child: AnimatedRotation(
        turns: busy ? .01 : 0,
        duration: const Duration(milliseconds: 280),
        child: SvgPicture.asset(
          'assets/characters/syvax.svg',
          semanticsLabel: 'Syvax character artwork',
        ),
      ),
    ),
  );
}
