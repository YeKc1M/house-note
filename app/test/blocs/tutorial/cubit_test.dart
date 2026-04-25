import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/tutorial/state.dart';

void main() {
  test('TutorialState has correct defaults', () {
    const state = TutorialState();
    expect(state.isActive, false);
    expect(state.currentStepIndex, 0);
    expect(state.startTimestamp, isNull);
    expect(state.showExitDialog, false);
    expect(state.createdTemplateIds, isEmpty);
    expect(state.createdInstanceIds, isEmpty);
  });

  test('TutorialState copyWith works', () {
    const state = TutorialState();
    final newState = state.copyWith(isActive: true, currentStepIndex: 3);
    expect(newState.isActive, true);
    expect(newState.currentStepIndex, 3);
    expect(newState.startTimestamp, isNull);
  });
}
