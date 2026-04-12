import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/settings/cubit.dart';

void main() {
  blocTest<SettingsCubit, SettingsState>(
    'toggles lan sync',
    build: SettingsCubit.new,
    act: (cubit) => cubit.toggleLanSync(true),
    expect: () => [const SettingsState(lanSyncEnabled: true)],
  );
}
