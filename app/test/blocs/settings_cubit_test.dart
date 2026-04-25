import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/settings/state.dart';

void main() {
  group('SettingsState', () {
    test('defaults tutorialSeen to false', () {
      const state = SettingsState();
      expect(state.tutorialSeen, false);
    });

    test('copyWith updates tutorialSeen', () {
      const state = SettingsState();
      final updated = state.copyWith(tutorialSeen: true);
      expect(updated.tutorialSeen, true);
      expect(updated.lanSyncEnabled, false);
    });
  });
}
