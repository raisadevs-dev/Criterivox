import 'unified_runtime_response.dart';
class PresentationState {
 final UnifiedRuntimeResponse? unified; final String? message,event,taskId,taskState,characterId; final bool connected;
 const PresentationState({this.unified,this.message,this.event,this.taskId,this.taskState,this.characterId,this.connected=false});
 factory PresentationState.fromJson(Map<String,dynamic> j,{bool connected=true})=>PresentationState(
  unified:UnifiedRuntimeResponse.fromJson(j),message:j['message'] as String?,event:j['event'] as String?,taskId:j['task_id'] as String?,taskState:j['task_state'] as String?,characterId:j['character_id'] as String?,connected:connected);
}