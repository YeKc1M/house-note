import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state.dart';

export 'state.dart';

const _kLanSyncEnabled = 'lan_sync_enabled';
const _kTutorialSeen = 'tutorial_seen';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(const SettingsState()) {
    _load();
  }

  void _load() {
    final lanSync = _prefs.getBool(_kLanSyncEnabled) ?? false;
    final tutorialSeen = _prefs.getBool(_kTutorialSeen) ?? false;
    emit(SettingsState(lanSyncEnabled: lanSync, tutorialSeen: tutorialSeen));
  }

  void markTutorialSeen() {
    _prefs.setBool(_kTutorialSeen, true);
    emit(state.copyWith(tutorialSeen: true));
  }

  void toggleLanSync(bool enabled) {
    _prefs.setBool(_kLanSyncEnabled, enabled);
    emit(state.copyWith(lanSyncEnabled: enabled));
  }
}
