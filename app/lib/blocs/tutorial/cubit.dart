import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database.dart';
import '../../utils/tutorial_steps.dart';
import 'state.dart';

export 'state.dart';

const _kTutorialActive = 'tutorial_was_active';
const _kTutorialLastStep = 'tutorial_last_step';

class TutorialCubit extends Cubit<TutorialState> {
  final SharedPreferences _prefs;
  final AppDatabase _db;

  TutorialCubit(this._prefs, this._db) : super(const TutorialState());

  void startTutorial() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    emit(TutorialState(
      isActive: true,
      currentStepIndex: 0,
      startTimestamp: timestamp,
    ));
    _prefs.setBool(_kTutorialActive, true);
    _prefs.setInt(_kTutorialLastStep, 0);
  }

  void nextStep() {
    final nextIndex = state.currentStepIndex + 1;
    if (nextIndex >= tutorialSteps.length) {
      completeTutorial();
      return;
    }
    emit(state.copyWith(currentStepIndex: nextIndex));
    _prefs.setInt(_kTutorialLastStep, nextIndex);
  }

  void goToStep(int index) {
    emit(state.copyWith(currentStepIndex: index));
    _prefs.setInt(_kTutorialLastStep, index);
  }

  void showExitDialog() {
    emit(state.copyWith(showExitDialog: true));
  }

  void hideExitDialog() {
    emit(state.copyWith(showExitDialog: false));
  }

  void completeTutorial() {
    _reset();
  }

  void exitWithoutCleanup() {
    _reset();
  }

  Future<void> exitAndCleanup() async {
    final timestamp = state.startTimestamp;
    if (timestamp != null) {
      await _db.customStatement(
        'DELETE FROM templates WHERE created_at >= ?',
        [timestamp],
      );
      await _db.customStatement(
        'DELETE FROM instances WHERE created_at >= ?',
        [timestamp],
      );
    }
    _reset();
  }

  void _reset() {
    emit(const TutorialState());
    _prefs.setBool(_kTutorialActive, false);
    _prefs.setInt(_kTutorialLastStep, 0);
  }
}
