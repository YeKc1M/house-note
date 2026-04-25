import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/screens/tutorial_screen.dart';

void main() {
  group('TutorialScreen', () {
    testWidgets('displays first page with welcome text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TutorialScreen()));
      await tester.pumpAndSettle();

      expect(find.text('快速入门'), findsOneWidget);
      expect(find.text('欢迎来到 House Note'), findsOneWidget);
      expect(find.text('跳过'), findsOneWidget);
    });

    testWidgets('navigates through all pages with next button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TutorialScreen()));
      await tester.pumpAndSettle();

      expect(find.text('欢迎来到 House Note'), findsOneWidget);
      expect(find.text('下一页'), findsOneWidget);

      // Page 2
      await tester.tap(find.text('下一页'));
      await tester.pumpAndSettle();
      expect(find.text('第一步：创建模板'), findsOneWidget);

      // Page 3
      await tester.tap(find.text('下一页'));
      await tester.pumpAndSettle();
      expect(find.text('第二步：建立层级关系'), findsOneWidget);

      // Page 4
      await tester.tap(find.text('下一页'));
      await tester.pumpAndSettle();
      expect(find.text('第三步：设置卡片缩略图'), findsOneWidget);

      // Page 5
      await tester.tap(find.text('下一页'));
      await tester.pumpAndSettle();
      expect(find.text('第四步：录入看房记录'), findsOneWidget);

      // Page 6
      await tester.tap(find.text('下一页'));
      await tester.pumpAndSettle();
      expect(find.text('删除与管理'), findsOneWidget);

      // Page 7 (last)
      await tester.tap(find.text('下一页'));
      await tester.pumpAndSettle();
      expect(find.text('开始记录吧'), findsOneWidget);
      expect(find.text('完成'), findsOneWidget);
      expect(find.text('下一页'), findsNothing);
    });

    testWidgets('skip button pops screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TutorialScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('跳过'));
      await tester.pumpAndSettle();

      expect(find.byType(TutorialScreen), findsNothing);
    });

    testWidgets('finish button on last page pops screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TutorialScreen()));
      await tester.pumpAndSettle();

      // Navigate to last page
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.text('下一页'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();

      expect(find.byType(TutorialScreen), findsNothing);
    });

    testWidgets('page indicator dots update', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TutorialScreen()));
      await tester.pumpAndSettle();

      // 7 dots should exist
      final dots = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(dots, findsNWidgets(7));

      // Tap next
      await tester.tap(find.text('下一页'));
      await tester.pumpAndSettle();

      // Still 7 dots
      expect(dots, findsNWidgets(7));
    });
  });
}
