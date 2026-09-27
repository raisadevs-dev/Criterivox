from criterivox.Kaelen.streaming import StreamDAG, StreamIngestor


def test_stream_ingestion_tracks_checkpoint_and_rejects_replay():
    ingestor = StreamIngestor()
    events = list(ingestor.ingest([
        {"_sequence": 1, "value": "a"},
        {"_sequence": 1, "value": "replay"},
        {"_sequence": 2, "value": "b"},
    ]))
    assert [event.sequence for event in events] == [1, 2]
    assert ingestor.checkpoint.sequence == 2
    assert ingestor.checkpoint.accepted == 2
    assert ingestor.checkpoint.rejected == 1


def test_stream_dag_produces_inspectable_event_results():
    result = StreamDAG().execute([
        {"_sequence": 1, "value": 10},
        {"_sequence": 2, "value": 11},
    ])
    assert result["status"] == "ready"
    assert len(result["events"]) == 2
    assert result["checkpoint"]["sequence"] == 2
