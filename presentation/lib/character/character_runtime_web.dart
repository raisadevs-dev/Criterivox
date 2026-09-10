import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class CharacterRuntimeView extends StatefulWidget {
  final String characterId;
  final String state;
  final bool reducedMotion;
  final double width;
  final double height;

  const CharacterRuntimeView({
    super.key,
    required this.characterId,
    required this.state,
    this.reducedMotion = false,
    this.width = 180,
    this.height = 240,
  });

  @override
  State<CharacterRuntimeView> createState() => _CharacterRuntimeViewState();
}

class _CharacterRuntimeViewState extends State<CharacterRuntimeView> {
  late final String _viewType;
  web.HTMLIFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    _viewType = 'criterivox-character-${widget.characterId.toLowerCase()}';
    _registerFactory();
  }

  void _registerFactory() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final iframe = web.createIFrameElement()
            ..src = _sourceUrl()
            ..title = '${widget.characterId} character runtime'
            ..style.border = '0'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.display = 'block';
          _iframe = iframe;
          return iframe;
        },
      );
    } catch (_) {
      // A factory is registered once per character. Rebuilds reuse it.
    }
  }

  String _sourceUrl() {
    final query = <String, String>{
      'character': widget.characterId.toLowerCase(),
      'state': widget.state.toUpperCase(),
      'reducedMotion': widget.reducedMotion.toString(),
    };
    final encoded = query.entries
        .map((entry) => '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');
    return 'character_runtime.html?$encoded';
  }

  @override
  void didUpdateWidget(covariant CharacterRuntimeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_iframe == null) return;
    final message = jsonEncode({
      'type': 'criterivox-character-state',
      'state': widget.state.toUpperCase(),
      'reducedMotion': widget.reducedMotion,
    });
    _iframe!.contentWindow?.postMessage(message.toJS, '*'.toJS);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Semantics(
        container: true,
        label: '${widget.characterId} character',
        value: widget.state.toUpperCase(),
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}
