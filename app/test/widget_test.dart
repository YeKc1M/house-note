import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/app.dart';
import 'package:house_note/data/database.dart';
import 'package:drift/native.dart';

void main() {
  testWidgets('App launches and shows three tabs', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());

    await tester.pumpWidget(HouseNoteApp(database: db));
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsNWidgets(2));
    expect(find.text('模板'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);

    await tester.tap(find.text('模板'));
    await tester.pumpAndSettle();
    expect(find.text('模板管理'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });
}
