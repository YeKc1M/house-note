import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:house_note/blocs/tutorial/cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:house_note/data/database.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockAppDatabase extends Mock implements AppDatabase {}

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

  group('TutorialCubit', () {
    late MockSharedPreferences mockPrefs;
    late MockAppDatabase mockDb;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      mockDb = MockAppDatabase();
      registerFallbackValue(const TutorialState());
      when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
      when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);
    });

    blocTest<TutorialCubit, TutorialState>(
      'startTutorial sets isActive and timestamp',
      build: () => TutorialCubit(mockPrefs, mockDb),
      act: (cubit) => cubit.startTutorial(),
      expect: () => [
        isA<TutorialState>()
          .having((s) => s.isActive, 'isActive', true)
          .having((s) => s.startTimestamp, 'startTimestamp', isNotNull),
      ],
      verify: (_) {
        verify(() => mockPrefs.setBool('tutorial_was_active', true)).called(1);
        verify(() => mockPrefs.setInt('tutorial_last_step', 0)).called(1);
      },
    );

    blocTest<TutorialCubit, TutorialState>(
      'nextStep advances currentStepIndex',
      build: () => TutorialCubit(mockPrefs, mockDb),
      seed: () => const TutorialState(isActive: true, currentStepIndex: 2),
      act: (cubit) => cubit.nextStep(),
      expect: () => [
        isA<TutorialState>()
          .having((s) => s.currentStepIndex, 'currentStepIndex', 3),
      ],
      verify: (_) {
        verify(() => mockPrefs.setInt('tutorial_last_step', 3)).called(1);
      },
    );

    blocTest<TutorialCubit, TutorialState>(
      'completeTutorial resets state and clears prefs',
      build: () => TutorialCubit(mockPrefs, mockDb),
      seed: () => const TutorialState(isActive: true, currentStepIndex: 5),
      act: (cubit) => cubit.completeTutorial(),
      expect: () => [
        const TutorialState(isActive: false, currentStepIndex: 0),
      ],
      verify: (_) {
        verify(() => mockPrefs.setBool('tutorial_was_active', false)).called(1);
        verify(() => mockPrefs.setInt('tutorial_last_step', 0)).called(1);
      },
    );

    blocTest<TutorialCubit, TutorialState>(
      'exitWithoutCleanup ends tutorial',
      build: () => TutorialCubit(mockPrefs, mockDb),
      seed: () => const TutorialState(isActive: true, currentStepIndex: 3),
      act: (cubit) => cubit.exitWithoutCleanup(),
      expect: () => [
        const TutorialState(isActive: false, currentStepIndex: 0, showExitDialog: false),
      ],
      verify: (_) {
        verify(() => mockPrefs.setBool('tutorial_was_active', false)).called(1);
      },
    );
  });
}
