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

  const CharacterRuntimeView({super.key,required this.characterId,required this.state,this.reducedMotion=false,this.width=180,this.height=240});

  @override
  State<CharacterRuntimeView> createState()=>_CharacterRuntimeViewState();
}

class _CharacterRuntimeViewState extends State<CharacterRuntimeView> {
  late final String viewType;
  web.HTMLIFrameElement? iframe;

  @override
  void initState(){
    super.initState();
    viewType='criterivox-character-${widget.characterId.toLowerCase()}';
    _registerFactory();
  }

  void _registerFactory(){
    try {
      ui_web.platformViewRegistry.registerViewFactory(viewType,(int viewId,{Object? params}){
        final config=params is Map?params:const <String,Object?>{};
        final character=(config['character']??widget.characterId).toString();
        final state=(config['state']??widget.state).toString().toUpperCase();
        final reducedMotion=config['reducedMotion']==true;
        return web.createIFrameElement()
          ..src=_sourceUrl(character,state,reducedMotion)
          ..title='$character character runtime'
          ..style.border='0'
          ..style.width='100%'
          ..style.height='100%'
          ..style.display='block';
      });
    } catch (_) {
      // A factory is registered once per character. Later instances reuse it.
    }
  }

  String _sourceUrl(String character,String state,bool reducedMotion){
    final query=<String,String>{'character':character.toLowerCase(),'state':state,'reducedMotion':reducedMotion.toString()};
    final encoded=query.entries.map((entry)=>'${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}').join('&');
    return 'character_runtime.html?$encoded';
  }

  void _onPlatformViewCreated(int viewId){
    final view=ui_web.platformViewRegistry.getViewById(viewId);
    if(view is web.HTMLIFrameElement){
      iframe=view;
      _sendState();
    }
  }

  void _sendState(){
    final frame=iframe;
    if(frame==null)return;
    final message=jsonEncode({'type':'criterivox-character-state','state':widget.state.toUpperCase(),'reducedMotion':widget.reducedMotion});
    frame.contentWindow?.postMessage(message.toJS,'*'.toJS);
  }

  @override
  void didUpdateWidget(covariant CharacterRuntimeView oldWidget){
    super.didUpdateWidget(oldWidget);
    if(oldWidget.state!=widget.state||oldWidget.reducedMotion!=widget.reducedMotion)_sendState();
  }

  @override
  Widget build(BuildContext context)=>SizedBox(
    width:widget.width,
    height:widget.height,
    child:Semantics(
      container:true,
      label:'${widget.characterId} character',
      value:widget.state.toUpperCase(),
      child:HtmlElementView(
        viewType:viewType,
        creationParams:<String,Object?>{'character':widget.characterId,'state':widget.state,'reducedMotion':widget.reducedMotion},
        onPlatformViewCreated:_onPlatformViewCreated,
      ),
    ),
  );
}
