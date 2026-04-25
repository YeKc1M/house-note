import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database.dart';
import 'state.dart';

export 'state.dart';

class TutorialCubit extends Cubit<TutorialState> {
  final SharedPreferences _prefs;
  final AppDatabase _db;

  TutorialCubit(this._prefs, this._db) : super(const TutorialState());

  void startTutorial() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    emit(state.copyWith(
      isActive: true,
      currentStepIndex: 0,
      startTimestamp: timestamp,
      showExitDialog: false,
      createdTemplateIds: {},
      createdInstanceIds: {},
    ));
    _prefs.setBool('tutorial_was_active', true);
    _prefs.setInt('tutorial_last_step', 0);
  }

  void nextStep() {
    final nextIndex = state.currentStepIndex + 1;
    emit(state.copyWith(currentStepIndex: nextIndex));
    _prefs.setInt('tutorial_last_step', nextIndex);
  }

  void goToStep(int index) {
    emit(state.copyWith(currentStepIndex: index));
    _prefs.setInt('tutorial_last_step', index);
  }

  void showExitDialog() {
    emit(state.copyWith(showExitDialog: true));
  }

  void hideExitDialog() {
    emit(state.copyWith(showExitDialog: false));
  }

  void completeTutorial() {
    emit(const TutorialState());
    _prefs.setBool('tutorial_was_active', false);
    _prefs.setInt('tutorial_last_step', 0);
  }

  void exitWithoutCleanup() {
    emit(const TutorialState(showExitDialog: false));
    _prefs.setBool('tutorial_was_active', false);
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
    emit(const TutorialState(showExitDialog: false));
    _prefs.setBool('tutorial_was_active', false);
  }

  void recordTemplateId(String id) {
    final ids = {...state.createdTemplateIds, id};
    emit(state.copyWith(createdTemplateIds: ids));
  }

  void recordInstanceId(String id) {
    final ids = {...state.createdInstanceIds, id};
    emit(state.copyWith(createdInstanceIds: ids));
  }
}
