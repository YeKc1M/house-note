import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state.dart';

export 'state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(const SettingsState()) {
    _load();
  }

  void _load() {
    final lanSync = _prefs.getBool('lan_sync_enabled') ?? false;
    final tutorialSeen = _prefs.getBool('tutorial_seen') ?? false;
    emit(SettingsState(lanSyncEnabled: lanSync, tutorialSeen: tutorialSeen));
  }

  void markTutorialSeen() {
    _prefs.setBool('tutorial_seen', true);
    emit(state.copyWith(tutorialSeen: true));
  }

  void toggleLanSync(bool enabled) {
    _prefs.setBool('lan_sync_enabled', enabled);
    emit(state.copyWith(lanSyncEnabled: enabled));
  }
}
