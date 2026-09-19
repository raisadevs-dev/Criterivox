import json
REQUIRED_TRAIN={"id","category","user_input","context","expected_intent","expected_entities","expected_character","expected_capability","expected_route","expected_response_type","expected_outcome","must_not_claim"}
REQUIRED_TEST={"id","input","expected_character","expected_capability","assertions"}
def load_jsonl(path,required):
    records=[]
    for line_no,line in enumerate(path.read_text(encoding="utf-8").splitlines(),1):
        if not line.strip():continue
        obj=json.loads(line); missing=required-set(obj)
        if missing:raise ValueError(f"{path}:{line_no}: missing {sorted(missing)}")
        records.append(obj)
    return records
