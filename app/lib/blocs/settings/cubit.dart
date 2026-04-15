import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

export 'state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void toggleLanSync(bool enabled) {
    emit(state.copyWith(lanSyncEnabled: enabled));
  }
}
