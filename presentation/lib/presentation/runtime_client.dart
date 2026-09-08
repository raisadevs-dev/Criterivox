import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'presentation_state.dart';

class CharacterRuntimeClient {
  static const backendPort=String.fromEnvironment('CRITERIVOX_BACKEND_PORT',defaultValue:'8000');
  static const _retryDelay=Duration(milliseconds:900);
  WebSocketChannel? _channel; Timer? _retryTimer; bool _disposed=false; bool _connecting=false;
  final _states=StreamController<PresentationState>.broadcast(); final _errors=StreamController<String>.broadcast();
  Stream<PresentationState> get states=>_states.stream; Stream<String> get errors=>_errors.stream;
  Uri get endpoint{final scheme=Uri.base.scheme=='https'?'wss':'ws';final host=Uri.base.host.isEmpty?'127.0.0.1':Uri.base.host;return Uri.parse('$scheme://$host:$backendPort/runtime/characters');}
  Future<void> connect() async{if(_disposed||_connecting||_channel!=null)return;_connecting=true;_retryTimer?.cancel();try{final channel=WebSocketChannel.connect(endpoint);_channel=channel;await channel.ready;if(_disposed){await channel.sink.close();return;}channel.stream.listen(_handleMessage,onError:(_)=>_connectionLost(),onDone:_connectionLost,cancelOnError:false);}catch(_){_channel=null;_scheduleReconnect();}finally{_connecting=false;}}
  void _connectionLost(){_channel=null;if(!_disposed)_scheduleReconnect();}
  void _scheduleReconnect(){if(_disposed||_retryTimer?.isActive==true)return;_retryTimer=Timer(_retryDelay,connect);}
  void requestApplication({required String intent,required String task,String? taskId,required Map<String,dynamic> data,required Map<String,dynamic> context,required String source,List<String> references=const []}){_send({'contract_version':1,'intent':intent,'task':task,if(taskId!=null)'task_id':taskId,'data':data,'context':context,'source':source,'references':references});}
  void requestAnalysis({required Map<String,dynamic> data,required Map<String,dynamic> context,required String task})=>requestApplication(intent:'analyze',task:task,data:data,context:context,source:'legacy-s2');
  void sendChat({String? taskId,required String message,String targetCharacter='syvax',Map<String,dynamic> data=const {},Map<String,dynamic> context=const {},List<Map<String,dynamic>> references=const []}){_send({'type':'chat_message','target_character':targetCharacter,if(taskId!=null)'task_id':taskId,'message':message,'data':data,'context':context,'references':references});}
  void ingestData({required List<Map<String,dynamic>> sources,Map<String,dynamic> suppliedContext=const {}}){_send({'type':'data_intake','sources':sources,'supplied_context':suppliedContext});}
  void dataAction({required String foundationId,required String action,List<String> candidateIds=const [],String recipient='dharen'}){_send({'type':'data_action','foundation_id':foundationId,'action':action,'candidate_ids':candidateIds,'recipient':recipient});}
  void _send(Map<String,dynamic> payload){final channel=_channel;if(channel==null){_scheduleReconnect();_errors.add('Python runtime is reconnecting.');return;}channel.sink.add(jsonEncode(payload));}
  void _handleMessage(dynamic message){try{_states.add(PresentationState.fromJson(message.toString()));}on FormatException catch(error){_errors.add('Rejected runtime state: ${error.message}');}catch(_){_errors.add('Rejected runtime state.');}}
  Future<void> disconnect()async{_retryTimer?.cancel();_retryTimer=null;final channel=_channel;_channel=null;if(channel!=null)await channel.sink.close();}
  Future<void> dispose()async{_disposed=true;await disconnect();await _states.close();await _errors.close();}
}
