import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/tutorial/cubit.dart';
import 'package:house_note/blocs/tutorial/state.dart';
import 'package:house_note/widgets/tutorial_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:house_note/data/database.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  setUpAll(() {
    registerFallbackValue('');
  });

  testWidgets('TutorialOverlay shows nothing when inactive', (tester) async {
    final prefs = MockSharedPreferences();
    final db = MockAppDatabase();
    final cubit = TutorialCubit(prefs, db);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const TutorialOverlay(
            child: Scaffold(body: Text('App Content')),
          ),
        ),
      ),
    );

    expect(find.text('App Content'), findsOneWidget);
    expect(find.text('退出教程'), findsNothing);
  });

  testWidgets('TutorialOverlay shows spotlight and exit button when active', (tester) async {
    final prefs = MockSharedPreferences();
    final db = MockAppDatabase();
    when(() => prefs.setBool(any(), any())).thenAnswer((_) async => true);
    when(() => prefs.setInt(any(), any())).thenAnswer((_) async => true);
    final cubit = TutorialCubit(prefs, db);
    cubit.startTutorial();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const TutorialOverlay(
            child: Scaffold(body: Center(child: Text('App Content'))),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('退出教程'), findsOneWidget);
  });
}
