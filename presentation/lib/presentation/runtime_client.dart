import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'foundation_residency_store.dart';
import 'presentation_state.dart';
class CharacterRuntimeClient {
 static const backendPort=String.fromEnvironment('CRITERIVOX_BACKEND_PORT',defaultValue:'8000');
 static const _retryDelay=Duration(milliseconds:900); static const _maxPending=40;
 WebSocketChannel? _channel; Timer? _retryTimer; bool _disposed=false; bool _connecting=false;
 final List<Map<String,dynamic>> _pending=[]; final FoundationResidencyStore _foundations=FoundationResidencyStore();
 final _states=StreamController<PresentationState>.broadcast(); final _errors=StreamController<String>.broadcast();
 Stream<PresentationState> get states=>_states.stream; Stream<String> get errors=>_errors.stream;
 Uri get endpoint{final scheme=Uri.base.scheme=='https'?'wss':'ws';final host=Uri.base.host.isEmpty?'127.0.0.1':Uri.base.host;return Uri.parse('$scheme://$host:$backendPort/runtime/characters');}
 Future<PresentationState?> restoreState()async{final local=await _foundations.all();if(local.isEmpty)return null;final value=local.last['_presentation_state'];if(value is! Map)return null;try{return PresentationState.fromJson(jsonEncode(value));}catch(_){return null;}}
 Future<void> connect()async{if(_disposed||_connecting||_channel!=null)return;_connecting=true;_retryTimer?.cancel();try{final restored=await restoreState();if(restored!=null&&!_disposed)_states.add(restored);final channel=WebSocketChannel.connect(endpoint);_channel=channel;await channel.ready;if(_disposed){await channel.sink.close();return;}_flushPending(channel);channel.stream.listen(_handleMessage,onError:(_)=>_connectionLost(),onDone:_connectionLost,cancelOnError:false);}catch(_){_channel=null;_scheduleReconnect();}finally{_connecting=false;}}
 void _flushPending(WebSocketChannel channel){while(_pending.isNotEmpty&&identical(_channel,channel)){channel.sink.add(jsonEncode(_pending.removeAt(0)));}}
 void _connectionLost(){_channel=null;if(!_disposed)_scheduleReconnect();} void _scheduleReconnect(){if(_disposed||_retryTimer?.isActive==true)return;_retryTimer=Timer(_retryDelay,connect);}
 Future<void> _persistFoundation(Map<String,dynamic> foundation,{required int revision})async{await _foundations.put(foundation,revision:revision);}
 void requestApplication({required String intent,required String task,String? taskId,required Map<String,dynamic> data,required Map<String,dynamic> context,required String source,List<String> references=const []}){_send({'contract_version':1,'intent':intent,'task':task,if(taskId!=null)'task_id':taskId,'data':data,'context':context,'source':source,'references':references});}
 void requestAnalysis({required Map<String,dynamic> data,required Map<String,dynamic> context,required String task})=>requestApplication(intent:'analyze',task:task,data:data,context:context,source:'legacy-s2');
 void sendChat({String? taskId,required String message,String targetCharacter='syvax',Map<String,dynamic> data=const {},Map<String,dynamic> context=const {},List<Map<String,dynamic>> references=const []}){_send({'type':'chat_message','target_character':targetCharacter,if(taskId!=null)'task_id':taskId,'message':message,'data':data,'context':context,'references':references});}
 void ingestData({required List<Map<String,dynamic>> sources,Map<String,dynamic> suppliedContext=const {},List<String> recentTaskIds=const [],List<String> promptHistory=const []}){_send({'type':'data_intake','sources':sources,'supplied_context':suppliedContext,'recent_task_ids':recentTaskIds,'prompt_history':promptHistory});}
 void ingestFolder({required String folderPath,Map<String,dynamic> suppliedContext=const {},List<String> recentTaskIds=const [],List<String> promptHistory=const []}){_send({'type':'data_folder','folder_path':folderPath,'supplied_context':suppliedContext,'recent_task_ids':recentTaskIds,'prompt_history':promptHistory});}
 void dataAction({required String foundationId,required String action,List<String> candidateIds=const [],String recipient='dharen',Map<String,dynamic> values=const {}}){_send({'type':'data_action','foundation_id':foundationId,'action':action,'candidate_ids':candidateIds,'recipient':recipient,'values':values});}
 void _send(Map<String,dynamic> payload){final channel=_channel;if(channel==null){if(_pending.length<_maxPending)_pending.add(Map<String,dynamic>.from(payload));else _errors.add('Runtime queue is full; the oldest unsent action was preserved and this action was rejected.');_scheduleReconnect();return;}try{channel.sink.add(jsonEncode(payload));}catch(_){_channel=null;if(_pending.length<_maxPending)_pending.add(Map<String,dynamic>.from(payload));_scheduleReconnect();}}
 void _handleMessage(dynamic message){try{final raw=jsonDecode(message.toString());if(raw is Map&&raw['foundation_payload'] is Map){final foundation=Map<String,dynamic>.from(raw['foundation_payload']);final revision=((foundation['_runtime_revision'] as num?)?.toInt()??0)+1;foundation['_runtime_revision']=revision;foundation['_presentation_state']=raw;_persistFoundation(foundation,revision:revision);}final state=PresentationState.fromJson(message.toString());_states.add(state);}on FormatException catch(error){_errors.add('Rejected runtime state: ${error.message}');}catch(_){_errors.add('Rejected runtime state.');}}
 Future<void> recoverFoundation(String foundationId)async{final foundation=await _foundations.get(foundationId);if(foundation==null)return;_send({'type':'foundation_sync','foundation_id':foundationId,'foundation':foundation,'revision':((foundation['_runtime_revision'] as num?)?.toInt()??1)});}
 Future<List<Map<String,dynamic>>> localFoundations()async=>_foundations.all();
 Future<void> disconnect()async{_retryTimer?.cancel();_retryTimer=null;final channel=_channel;_channel=null;if(channel!=null)await channel.sink.close();}
 Future<void> dispose()async{_disposed=true;await disconnect();await _states.close();await _errors.close();}
}
