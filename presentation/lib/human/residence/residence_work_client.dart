import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ResidenceWorkClient {
  final String baseUrl;
  ResidenceWorkClient({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl();
  static String _defaultBaseUrl() {
    final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
    return '\${Uri.base.scheme == 'https' ? 'https' : 'http'}://$host:8017';
  }
  Future<List<Map<String,dynamic>>> list() async {
    final r=await http.get(Uri.parse('$baseUrl/api/residence/work?owner_id=human'));
    _check(r); return List<Map<String,dynamic>>.from(jsonDecode(r.body)['work'] as List);
  }
  Future<Map<String,dynamic>> create(String goal,String language,List<String> requirements,List<String> constraints,String output) async {
    final r=await http.post(Uri.parse('$baseUrl/api/residence/work'),headers:{'content-type':'application/json'},body:jsonEncode({'owner_id':'human','room_id':'private','goal':goal,'language':language,'requirements':requirements,'constraints':constraints,'expected_output':output}));
    _check(r); return Map<String,dynamic>.from(jsonDecode(r.body)['work']);
  }
  Future<Map<String,dynamic>> interpret(String id) async => _call(id,'interpret',{});
  Future<Map<String,dynamic>> confirm(String id,bool confirmed,{String? correction}) async => _call(id,'confirm',{'actor':'human','confirmed':confirmed,'correction':correction});
  Future<Map<String,dynamic>> addMaterial(String id,PlatformFile file) async {
    if(file.bytes==null) throw Exception('Selected file is not readable.');
    return _call(id,'materials',{'filename':file.name,'content_type':'application/octet-stream','content_base64':base64Encode(file.bytes!)});
  }
  Future<Map<String,dynamic>> take(String id)=>_call(id,'take',{'actor':'human'});
  Future<Map<String,dynamic>> pause(String id)=>_call(id,'pause',{'actor':'human'});
  Future<Map<String,dynamic>> resume(String id)=>_call(id,'resume',{'actor':'human'});
  Future<Map<String,dynamic>> challenge(String id,String type,String text)=>_call(id,'challenge',{'actor':'human','challenge_type':type,'text':text});
  Future<Map<String,dynamic>> decide(String id,String optionId,String modification)=>_call(id,'decide',{'actor':'human','option_id':optionId,'modification':modification});
  Future<Map<String,dynamic>> authorize(String id)=>_call(id,'authorize',{'actor':'human'});
  Future<Map<String,dynamic>> _call(String id,String action,Map<String,dynamic> body) async {
    final r=await http.post(Uri.parse('$baseUrl/api/residence/work/$id/$action'),headers:{'content-type':'application/json'},body:jsonEncode(body));
    _check(r); return Map<String,dynamic>.from(jsonDecode(r.body)['work']);
  }
  void _check(http.Response r){if(r.statusCode<200||r.statusCode>=300)throw Exception('Residence API \${r.statusCode}: \${r.body}');}
}
