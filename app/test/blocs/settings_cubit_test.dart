import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/settings/cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences prefs;

  setUp(() {
    prefs = MockSharedPreferences();
  });

  group('SettingsCubit', () {
    test('loads persisted values on creation', () {
      when(() => prefs.getBool('lan_sync_enabled')).thenReturn(true);
      when(() => prefs.getBool('tutorial_seen')).thenReturn(true);
      final cubit = SettingsCubit(prefs);
      expect(
        cubit.state,
        const SettingsState(lanSyncEnabled: true, tutorialSeen: true),
      );
    });

    test('defaults to false when no persisted values', () {
      when(() => prefs.getBool(any())).thenReturn(null);
      final cubit = SettingsCubit(prefs);
      expect(cubit.state, const SettingsState());
    });

    blocTest<SettingsCubit, SettingsState>(
      'toggles lan sync and persists',
      setUp: () {
        when(() => prefs.getBool(any())).thenReturn(null);
        when(() => prefs.setBool(any(), any())).thenAnswer((_) async => true);
      },
      build: () => SettingsCubit(prefs),
      act: (cubit) => cubit.toggleLanSync(true),
      expect: () => [
        const SettingsState(lanSyncEnabled: true),
      ],
      verify: (_) {
        verify(() => prefs.setBool('lan_sync_enabled', true)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'marks tutorial seen and persists',
      setUp: () {
        when(() => prefs.getBool(any())).thenReturn(null);
        when(() => prefs.setBool(any(), any())).thenAnswer((_) async => true);
      },
      build: () => SettingsCubit(prefs),
      act: (cubit) => cubit.markTutorialSeen(),
      expect: () => [
        const SettingsState(tutorialSeen: true),
      ],
      verify: (_) {
        verify(() => prefs.setBool('tutorial_seen', true)).called(1);
      },
    );
  });
}
