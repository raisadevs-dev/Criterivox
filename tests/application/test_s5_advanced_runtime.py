from criterivox.application.s5_advanced_runtime import EvaluationGate,FoundationSynchronizer,KaelenPipeline,ProvenanceLedger,SchemaDriftHealer,SemanticTagger,SyntheticDataEngine

def test_provenance_rewind_round_trip():
 l=ProvenanceLedger();a=l.append('DF-X','A',{'v':1});b=l.append('DF-X','B',{'v':2});assert l.rewind('DF-X',a.revision).snapshot=={'v':1};assert b.parent_revision==a.revision

def test_sync_rejects_stale_and_accepts_duplicate():
 s=FoundationSynchronizer();e=s.prepare('DF-X',1,{'x':1});assert s.accept(e)['accepted'];assert s.accept(e)['duplicate'];stale=s.prepare('DF-X',0,{'x':0});assert s.accept(stale)['reason']=='stale_revision'

def test_kaelen_pipeline_is_executable():
 r=KaelenPipeline().execute([{'a':1},{'a':2}]);assert r['status']=='ready';assert r['rows']==2

def test_schema_healer_maps_aliases():
 r=SchemaDriftHealer().patch([{'old':1}],['old'],['new'],{'old':'new'});assert r['patched_rows']==[{'new':1}]

def test_synthetic_never_reuses_string_values():
 r=SyntheticDataEngine().preview([{'name':'private'}],17);assert r['rows'][0]['name']!='private'

def test_semantic_readability():
 r=SemanticTagger().tag([{'id':1,'date':'2026'}],{'required_fields':['id','date']});assert r['agent_readability_score']==1.0

def test_evaluation_gate():
 r=EvaluationGate().evaluate({'quality':.9,'stability':.9},[{'role':'test'}]);assert r['passed']
