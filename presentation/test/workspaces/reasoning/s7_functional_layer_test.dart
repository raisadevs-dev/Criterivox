import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/s7/s7_functional_layer.dart';

void main() {
  test('Vivren and Tarkis retain distinct state-machine semantics', () {
    final vivren = S7CharacterStateResolver.resolve('vivren', {
      'state': 'flagging',
    });
    final tarkis = S7CharacterStateResolver.resolve('tarkis', {
      'state': 'branching',
    });

    expect(vivren['state_machine'], 'VivrenCriticalInspectionStateMachine');
    expect(vivren['behavior'], contains('critical'));
    expect(tarkis['state_machine'], 'TarkisHypothesisExplorationStateMachine');
    expect(tarkis['behavior'], contains('alternative'));
    expect(vivren['state'], 'flagging');
    expect(tarkis['state'], 'branching');
  });

  test('visualization factory maps room semantics without losing source identity', () {
    final artifact = {
      'artifact_id': 'artifact-42',
      'kind': 'contradiction',
      'title': 'Measurement conflict',
      'content': {'left': 'A', 'right': 'B'},
    };

    final vivren = S7VisualizationFactory.fromArtifact(artifact, 'vivren');
    final tarkis = S7VisualizationFactory.fromArtifact({
      ...artifact,
      'kind': 'hypothesis',
    }, 'tarkis');

    expect(vivren.title, 'Contradiction Graph');
    expect(vivren.artifactId, 'artifact-42');
    expect(tarkis.title, 'Hypothesis Tree');
    expect(tarkis.artifactId, 'artifact-42');
  });
}
