import 'dart:convert';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';

class FoundationResidencyStore {
  static const _dbName='criterivox_foundation_residency';
  static const _store='foundations';
  Database? _db;
  Future<Database> _open() async {
    if(_db!=null)return _db!;
    _db=await idbFactoryBrowser.open(_dbName,version:1,onUpgradeNeeded:(event){
      final db=event.database;
      if(!db.objectStoreNames.contains(_store))db.createObjectStore(_store);
    });
    return _db!;
  }
  Future<void> put(Map<String,dynamic> foundation,{required int revision})async{
    final db=await _open();final id='${foundation['foundation_id']}';
    final envelope={'schema_version':1,'foundation_id':id,'revision':revision,'updated_at':DateTime.now().toUtc().toIso8601String(),'foundation':jsonDecode(jsonEncode(foundation))};
    final tx=db.transaction(_store,idbModeReadWrite);await tx.objectStore(_store).put(envelope,id);await tx.completed;
  }
  Future<Map<String,dynamic>?> get(String id)async{
    final db=await _open();final tx=db.transaction(_store,idbModeReadOnly);final value=await tx.objectStore(_store).getObject(id);await tx.completed;
    if(value is! Map)return null;final f=value['foundation'];return f is Map?Map<String,dynamic>.from(f):null;
  }
  Future<List<Map<String,dynamic>>> all()async{
    final db=await _open();final tx=db.transaction(_store,idbModeReadOnly);final values=await tx.objectStore(_store).getAll();await tx.completed;
    return values.whereType<Map>().map((v){final f=v['foundation'];return f is Map?Map<String,dynamic>.from(f):<String,dynamic>{};}).where((v)=>v.isNotEmpty).toList(growable:false);
  }
  Future<void> remove(String id)async{final db=await _open();final tx=db.transaction(_store,idbModeReadWrite);await tx.objectStore(_store).delete(id);await tx.completed;}
}
