import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:house_note/app.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/widgets/instance_card.dart';
import 'package:house_note/data/default_template_loader.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

Finder bottomNavItem(String label) {
  return find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.text(label),
  );
}

Finder instanceListFab() {
  return find.byWidgetPredicate(
    (w) => w is FloatingActionButton && w.heroTag == 'instanceListFab',
  );
}

Finder templateListFab() {
  return find.byWidgetPredicate(
    (w) => w is FloatingActionButton && w.heroTag == 'templateListFab',
  );
}

Finder dialogTextField(int index) {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextField),
  ).at(index);
}

Finder dialogOptionTextField() {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.widgetWithText(TextField, '选项'),
  );
}

Finder dialogAddButton() {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.widgetWithText(ElevatedButton, '添加'),
  );
}

Finder dialogDropdown() {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(DropdownButtonFormField<String>),
  );
}

Future<void> addSingleChoiceOption(WidgetTester tester, String option) async {
  await tester.enterText(dialogOptionTextField(), option);
  await tester.pumpAndSettle();
  await tester.tap(dialogAddButton());
  await tester.pumpAndSettle();
}

Future<void> selectDimensionType(WidgetTester tester, String typeLabel) async {
  await tester.tap(dialogDropdown().first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(typeLabel).last);
  await tester.pumpAndSettle();
}

Finder dialogTemplateDropdown() {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(DropdownButtonFormField<String>),
  ).at(1);
}

Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 5)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  throw Exception('Timed out waiting for $finder');
}

Future<void> pumpUntilAbsent(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 5)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (finder.evaluate().isEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  throw Exception('Timed out waiting for $finder to disappear');
}

Finder visibilityToggleForDimension(String dimensionName) {
  final tile = find.widgetWithText(ListTile, dimensionName);
  return find.descendant(
    of: tile,
    matching: find.byIcon(Icons.visibility_off),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E User Stories', () {
    late AppDatabase db;
    late File dbFile;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final tempDir = Directory.systemTemp;
      dbFile = File(p.join(tempDir.path, 'e2e_test_${DateTime.now().millisecondsSinceEpoch}.db'));
      db = AppDatabase.forTesting(NativeDatabase.createInBackground(dbFile));
    });

    tearDown(() async {
      await db.close();
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    });

    testWidgets('Story 1.1 - Create house template and community template with reference',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Navigate to 模板 (Templates) tab
      await tester.tap(bottomNavItem('模板'));
      await tester.pumpAndSettle();
      expect(find.text('模板管理'), findsOneWidget);

      // Create 房子模板
      await tester.tap(templateListFab());
      await tester.pumpAndSettle();
      expect(find.text('新建模板'), findsOneWidget);

      // Enter template name
      await tester.enterText(find.byType(TextField).first, '房子模板');
      await tester.pumpAndSettle();

      // Add dimension: 朝向 (single_choice)
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '朝向');
      await selectDimensionType(tester, '单选');
      await addSingleChoiceOption(tester, '东');
      await addSingleChoiceOption(tester, '南');
      await addSingleChoiceOption(tester, '西');
      await addSingleChoiceOption(tester, '北');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Add dimension: 楼层 (number)
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '楼层');
      await selectDimensionType(tester, '数字');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Add dimension: 户型 (text)
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '户型');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Save template
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      // Verify template was saved in DB
      final templates = await db.select(db.templates).get();
      expect(templates.map((t) => t.name), contains('房子模板'));

      // Rebuild app to force fresh load of template list
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();
      await tester.tap(bottomNavItem('模板'));
      await tester.pumpAndSettle();
      expect(find.text('房子模板'), findsOneWidget);

      // Create 小区模板
      await tester.tap(templateListFab());
      await tester.pumpAndSettle();

      // Enter template name
      await tester.enterText(find.byType(TextField).first, '小区模板');
      await tester.pumpAndSettle();

      // Add dimension: 小区名 (text)
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '小区名');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Add dimension: 位置 (text)
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '位置');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Add dimension: 是否靠近地铁站 (single_choice)
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '是否靠近地铁站');
      await selectDimensionType(tester, '单选');
      await addSingleChoiceOption(tester, '是');
      await addSingleChoiceOption(tester, '否');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Add dimension: 上班通勤 (text)
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '上班通勤');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Add ref_subtemplate: 房子列表 referencing 房子模板
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '房子列表');
      await selectDimensionType(tester, '引用子模板');
      // Wait for templates to load and select 房子模板
      await pumpUntilFound(tester, dialogTemplateDropdown());
      await tester.tap(dialogTemplateDropdown());
      await tester.pumpAndSettle();
      await tester.tap(find.text('房子模板').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Save template
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      // Verify both templates exist in DB
      final allTemplates = await db.select(db.templates).get();
      expect(allTemplates.map((t) => t.name), containsAll(['小区模板', '房子模板']));

      // Rebuild app to force fresh load
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();
      await tester.tap(bottomNavItem('模板'));
      await tester.pumpAndSettle();
      expect(find.text('小区模板'), findsOneWidget);
      expect(find.text('房子模板'), findsOneWidget);
    });

    testWidgets('Story 1.2 - Edit existing template and subtemplate reference',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Pre-create templates directly in DB
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        _dim('d4', '朝向', 'single_choice', '{"options":["东","南","西","北"]}'),
        _dim('d5', '楼层', 'number', '{}'),
        _dim('d6', '户型', 'text', '{}'),
      ]);
      final apartmentTemplateId = await _insertTemplate(db, '公寓模板', [
        _dim('d7', '租金', 'number', '{}'),
      ]);
      final communityTemplateId = await _insertTemplate(db, '小区模板', [
        _dim('d1', '小区名', 'text', '{}'),
        _dim('d2', '位置', 'text', '{}'),
        _dim('d3', '房子列表', 'ref_subtemplate', '{"ref_template_id":"$houseTemplateId"}'),
      ]);

      // Navigate to 模板 tab
      await tester.tap(bottomNavItem('模板'));
      await tester.pumpAndSettle();

      // Tap 小区模板 to edit
      await tester.tap(find.text('小区模板'));
      await tester.pumpAndSettle();

      // Edit 小区名 -> 社区名
      final nameTile = find.widgetWithText(ListTile, '小区名 (text)');
      final nameEditButton = find.descendant(of: nameTile, matching: find.byIcon(Icons.edit));
      await tester.tap(nameEditButton);
      await tester.pumpAndSettle();

      await tester.enterText(dialogTextField(0), '社区名');
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Add a new ref_subtemplate dimension: 公寓列表 referencing 公寓模板
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '公寓列表');
      await selectDimensionType(tester, '引用子模板');
      await pumpUntilFound(tester, dialogTemplateDropdown());
      await tester.tap(dialogTemplateDropdown());
      await tester.pumpAndSettle();
      await tester.tap(find.text('公寓模板').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Save template
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      // Rebuild and verify
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();
      await tester.tap(bottomNavItem('模板'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('小区模板'));
      await tester.pumpAndSettle();
      expect(find.text('社区名 (text)'), findsOneWidget);
      expect(find.text('公寓列表 (ref_subtemplate)'), findsOneWidget);

      // Verify DB has both ref_subtemplate dimensions
      final allDims = await (db.select(db.templateDimensions)
            ..where((td) => td.templateId.equals(communityTemplateId)))
          .get();
      final refDims = allDims.where((d) => d.type == 'ref_subtemplate').toList();
      expect(refDims.length, 2);
      expect(refDims.map((d) => d.name), containsAll(['房子列表', '公寓列表']));
    });

    testWidgets('Story 2.1 + 2.2 - Create top-level and child instances',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Pre-create templates directly in DB for speed
      final templateId = await _insertTemplate(db, '小区模板', [
        _dim('d1', '小区名', 'text', '{}'),
        _dim('d2', '位置', 'text', '{}'),
        _dim('d3', '房子列表', 'ref_subtemplate', '{"ref_template_id":"house_tpl"}'),
      ]);
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        _dim('d4', '朝向', 'single_choice', '{"options":["东","南","西","北"]}'),
        _dim('d5', '楼层', 'number', '{}'),
        _dim('d6', '户型', 'text', '{}'),
      ]);
      // Update ref_subtemplate to point to actual house template ID
      await (db.update(db.templateDimensions)..where((td) => td.id.equals('d3')))
          .write(TemplateDimensionsCompanion(config: Value('{"ref_template_id":"$houseTemplateId"}')));

      // Navigate to 首页 tab
      await tester.tap(bottomNavItem('首页'));
      await tester.pumpAndSettle();

      // Create top-level instance: 华润二十四城
      await tester.tap(instanceListFab());
      await tester.pumpAndSettle();
      await tester.tap(find.text('小区模板'));
      await tester.pumpAndSettle();

      // Enter instance name
      await tester.enterText(find.byType(TextFormField).first, '华润二十四城');
      await tester.pumpAndSettle();

      // Fill dimensions
      await tester.enterText(find.byType(TextFormField).at(1), '成华区双庆路');
      await tester.pumpAndSettle();

      // Save instance
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await pumpUntilFound(tester, find.text('华润二十四城'));

      // Verify instance appears in list
      expect(find.text('华润二十四城'), findsOneWidget);

      // Drill down into the instance
      await tester.tap(find.text('华润二十四城'));
      await tester.pumpAndSettle();
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('华润二十四城'), findsWidgets);

      // Create child instance under 华润二十四城
      await tester.tap(instanceListFab(), warnIfMissed: false);
      await tester.pumpAndSettle();
      if (find.text('选择要新建的子类型').evaluate().isNotEmpty) {
        await tester.tap(find.text('房子模板'));
        await tester.pumpAndSettle();
      }

      // Wait for the editor to fully load dimensions
      await pumpUntilFound(tester, find.text('朝向'));

      // Enter instance name
      await tester.enterText(find.byType(TextFormField).first, '7栋-1203');
      await tester.pumpAndSettle();

      // Fill dimensions: 朝向 = 南
      await tester.tap(find.text('南'));
      await tester.pumpAndSettle();

      // 楼层 = 12
      await tester.enterText(find.byType(TextFormField).last, '12');
      await tester.pumpAndSettle();

      // Save instance
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await pumpUntilFound(tester, find.text('7栋-1203'));

      // Verify child instance appears
      expect(find.text('7栋-1203'), findsOneWidget);

      // Drill down to view instance details
      await tester.tap(find.text('7栋-1203'));
      await tester.pumpAndSettle();
      expect(find.text('7栋-1203'), findsOneWidget);
    });

    testWidgets('Story 2.3 + 2.4 - Custom fields and hide/restore template fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Pre-create template and instance
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        _dim('d4', '朝向', 'single_choice', '{"options":["东","南","西","北"]}'),
        _dim('d5', '楼层', 'number', '{}'),
      ]);
      final instanceId = await _insertInstance(db, houseTemplateId, null, '7栋-1203', {
        'd4': '南',
        'd5': '12',
      });

      // Navigate to 首页 tab
      await tester.tap(bottomNavItem('首页'));
      await tester.pumpAndSettle();

      // Open instance editor
      await tester.tap(find.text('7栋-1203'));
      await tester.pumpAndSettle();

      // Add custom field (single choice: 是/否)
      await tester.tap(find.text('添加自定义字段'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '房东是否好沟通');
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(DropdownButtonFormField<String>)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('单选').last);
      await tester.pumpAndSettle();
      await addSingleChoiceOption(tester, '是');
      await addSingleChoiceOption(tester, '否');
      await tester.tap(find.widgetWithText(TextButton, '添加'));
      await tester.pumpAndSettle();

      // Wait for dialog to close
      await pumpUntilAbsent(tester, find.byType(AlertDialog));

      // Set custom field value to 是
      await tester.tap(find.widgetWithText(ChoiceChip, '是'));
      await tester.pumpAndSettle();

      // Hide dimension: 楼层
      final floorTile = find.widgetWithText(ListTile, '楼层');
      final hideButton = find.descendant(of: floorTile, matching: find.text('隐藏'));
      await tester.tap(hideButton);
      await tester.pumpAndSettle();

      // Save instance
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await pumpUntilFound(tester, find.text('7栋-1203'));

      // Re-open instance to verify custom field is present and 楼层 is hidden
      await tester.tap(find.text('7栋-1203'));
      await tester.pumpAndSettle();
      expect(find.text('房东是否好沟通'), findsOneWidget);
      expect(find.text('楼层'), findsNothing);

      // Restore hidden field
      await tester.tap(find.text('恢复隐藏字段'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('恢复显示'));
      await tester.pumpAndSettle();

      // Save instance
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await pumpUntilFound(tester, find.text('7栋-1203'));

      // Re-open and verify 楼层 is back
      await tester.tap(find.text('7栋-1203'));
      await tester.pumpAndSettle();
      expect(find.text('楼层'), findsOneWidget);
    });

    testWidgets('Story 2.5 - Add custom fields of all types via tag editor',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Pre-create template and instance
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        _dim('d4', '朝向', 'single_choice', '{"options":["东","南","西","北"]}'),
      ]);
      await _insertInstance(db, houseTemplateId, null, '测试房', {'d4': '南'});

      // Navigate to 首页 and open instance editor
      await tester.tap(bottomNavItem('首页'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('测试房'));
      await tester.pumpAndSettle();

      // Add text custom field
      await tester.tap(find.text('添加自定义字段'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '备注');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, '添加'));
      await tester.pumpAndSettle();
      await pumpUntilAbsent(tester, find.byType(AlertDialog));
      expect(find.text('备注'), findsOneWidget);

      // Add number custom field
      await tester.tap(find.text('添加自定义字段'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '押金');
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(DropdownButtonFormField<String>)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('数字').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, '添加'));
      await tester.pumpAndSettle();
      await pumpUntilAbsent(tester, find.byType(AlertDialog));
      expect(find.text('押金'), findsOneWidget);

      // Add single_choice custom field via tag editor
      await tester.tap(find.text('添加自定义字段'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '是否带家具');
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(DropdownButtonFormField<String>)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('单选').last);
      await tester.pumpAndSettle();
      await addSingleChoiceOption(tester, '带家具');
      await addSingleChoiceOption(tester, '不带家具');
      await tester.tap(find.widgetWithText(TextButton, '添加'));
      await tester.pumpAndSettle();
      await pumpUntilAbsent(tester, find.byType(AlertDialog));

      // Verify all custom fields are displayed
      expect(find.text('备注'), findsOneWidget);
      expect(find.text('押金'), findsOneWidget);
      expect(find.text('是否带家具'), findsOneWidget);
      // Verify choice chips for single_choice custom field
      expect(find.text('带家具'), findsWidgets);
      expect(find.text('不带家具'), findsWidgets);

      // Fill values and save
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '备注'), matching: find.byType(TextFormField)),
        '采光很好',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '押金'), matching: find.byType(TextFormField)),
        '2000',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '带家具'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await pumpUntilFound(tester, find.text('测试房'));

      // Re-open and verify values persisted
      await tester.tap(find.text('测试房'));
      await tester.pumpAndSettle();
      expect(find.text('备注'), findsOneWidget);
      expect(find.text('押金'), findsOneWidget);
      expect(find.text('是否带家具'), findsOneWidget);
    });

    testWidgets('Story 3.1 - Browse parent-child instances with breadcrumbs',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      final communityTemplateId = await _insertTemplate(db, '小区模板', [
        _dim('d1', '小区名', 'text', '{}'),
        _dim('d2', '房子列表', 'ref_subtemplate', '{"ref_template_id":"house_tpl"}'),
      ]);
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        _dim('d3', '朝向', 'single_choice', '{"options":["东","南"]}'),
        _dim('d4', '房间列表', 'ref_subtemplate', '{"ref_template_id":"room_tpl"}'),
      ]);
      final roomTemplateId = await _insertTemplate(db, '房间模板', [
        _dim('d5', '面积', 'number', '{}'),
      ]);
      // Fix refs to actual IDs
      await (db.update(db.templateDimensions)..where((td) => td.id.equals('d2')))
          .write(TemplateDimensionsCompanion(config: Value('{"ref_template_id":"$houseTemplateId"}')));
      await (db.update(db.templateDimensions)..where((td) => td.id.equals('d4')))
          .write(TemplateDimensionsCompanion(config: Value('{"ref_template_id":"$roomTemplateId"}')));

      final communityId = await _insertInstance(db, communityTemplateId, null, '华润二十四城', {'d1': '华润二十四城'});
      final houseId = await _insertInstance(db, houseTemplateId, communityId, '7栋-1203', {'d3': '南'});
      await _insertInstance(db, roomTemplateId, houseId, '主卧', {'d5': '20'});

      // Navigate to 首页
      await tester.tap(bottomNavItem('首页'));
      await tester.pumpAndSettle();

      // Top level shows 华润二十四城
      expect(find.text('华润二十四城'), findsOneWidget);
      expect(find.text('全部'), findsOneWidget);

      // Tap to drill down to house level
      await tester.tap(find.text('华润二十四城'));
      await tester.pumpAndSettle();
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('7栋-1203'), findsOneWidget);

      // Tap to drill down to room level
      await tester.tap(find.text('7栋-1203'));
      await tester.pumpAndSettle();
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('主卧'), findsOneWidget);

      // Tap breadcrumb to go back to house level
      await tester.tap(find.text('华润二十四城'));
      await tester.pumpAndSettle();
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('7栋-1203'), findsOneWidget);

      // Tap 全部 to go back to root
      await tester.tap(find.text('全部'));
      await tester.pumpAndSettle();
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('华润二十四城'), findsOneWidget);
    });

    testWidgets('Story 3.2 - Configure thumbnail fields in template editor and verify on instance cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Pre-create templates with dimensions in DB
      final communityTemplateId = await _insertTemplate(db, '小区模板', [
        _dim('d1', '小区名', 'text', '{}'),
        _dim('d2', '位置', 'text', '{}'),
        _dim('d3', '地铁', 'single_choice', '{"options":["是","否"]}'),
      ]);
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        _dim('d4', '朝向', 'single_choice', '{"options":["东","南","西","北"]}'),
        _dim('d5', '楼层', 'number', '{}'),
        _dim('d6', '户型', 'text', '{}'),
      ]);

      // Insert ref_subtemplate on community template
      await db.into(db.templateDimensions).insert(
        TemplateDimensionsCompanion(
          id: const Value('d7'),
          templateId: Value(communityTemplateId),
          name: const Value('房子列表'),
          type: const Value('ref_subtemplate'),
          config: Value('{"ref_template_id":"$houseTemplateId"}'),
          sortOrder: const Value(3),
        ),
        mode: InsertMode.insertOrReplace,
      );

      // Navigate to 模板 tab to configure thumbnails for 小区模板
      await tester.tap(bottomNavItem('模板'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('小区模板'));
      await tester.pumpAndSettle();

      // Enable thumbnail visibility for 位置 and 地铁
      await tester.tap(visibilityToggleForDimension('位置 (text)'));
      await tester.pumpAndSettle();
      await tester.tap(visibilityToggleForDimension('地铁 (single_choice)'));
      await tester.pumpAndSettle();

      // Verify thumbnail preview shows the selected dimensions
      expect(find.text('缩略图显示字段'), findsOneWidget);
      expect(find.text('位置'), findsWidgets);
      expect(find.text('地铁'), findsWidgets);

      // Save template
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      // Configure thumbnails for 房子模板
      await tester.tap(find.text('房子模板'));
      await tester.pumpAndSettle();

      // Enable thumbnail visibility for 朝向, 楼层, 户型
      await tester.tap(visibilityToggleForDimension('朝向 (single_choice)'));
      await tester.pumpAndSettle();
      await tester.tap(visibilityToggleForDimension('楼层 (number)'));
      await tester.pumpAndSettle();
      await tester.tap(visibilityToggleForDimension('户型 (text)'));
      await tester.pumpAndSettle();

      // Save template
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      // Navigate to 首页 and create instances AFTER thumbnail config so stream emits with thumbs
      await tester.tap(bottomNavItem('首页'));
      await tester.pumpAndSettle();

      // Create top-level community instance
      await tester.tap(instanceListFab());
      await tester.pumpAndSettle();
      await tester.tap(find.text('小区模板'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '华润二十四城');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '位置'), matching: find.byType(TextFormField)),
        '成华区双庆路',
      );
      await tester.pumpAndSettle();
      // 地铁 = 是 (choice chip)
      await tester.tap(find.text('是'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      // Wait for and verify thumbnail chips appear on the community instance card
      await pumpUntilFound(tester, find.text('位置: 成华区双庆路'));
      expect(find.text('地铁: 是'), findsOneWidget);

      // Drill down to house level
      await tester.tap(find.text('华润二十四城'));
      await tester.pumpAndSettle();

      // Create child house instance
      await tester.tap(instanceListFab(), warnIfMissed: false);
      await tester.pumpAndSettle();
      if (find.text('选择要新建的子类型').evaluate().isNotEmpty) {
        await tester.tap(find.text('房子模板'));
        await tester.pumpAndSettle();
      }
      await pumpUntilFound(tester, find.text('朝向'));
      await tester.enterText(find.byType(TextFormField).first, '7栋-1203');
      await tester.pumpAndSettle();
      await tester.tap(find.text('南'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '楼层'), matching: find.byType(TextFormField)),
        '12',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '户型'), matching: find.byType(TextFormField)),
        '三室两厅',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      // Verify house card thumbnails
      await pumpUntilFound(tester, find.text('朝向: 南'));
      expect(find.text('楼层: 12'), findsOneWidget);
      expect(find.text('户型: 三室两厅'), findsOneWidget);
    });

    testWidgets('Story 4.1 - Swipe to delete parent instance cascades to children',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Pre-create a 3-level hierarchy directly in DB
      final communityTemplateId = await _insertTemplate(db, '小区模板', [
        _dim('d1', '小区名', 'text', '{}'),
        _dim('d2', '房子列表', 'ref_subtemplate', '{"ref_template_id":"house_tpl"}'),
      ]);
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        _dim('d3', '朝向', 'single_choice', '{"options":["东","南"]}'),
        _dim('d4', '房间列表', 'ref_subtemplate', '{"ref_template_id":"room_tpl"}'),
      ]);
      final roomTemplateId = await _insertTemplate(db, '房间模板', [
        _dim('d5', '面积', 'number', '{}'),
      ]);
      // Fix refs to actual IDs
      await (db.update(db.templateDimensions)..where((td) => td.id.equals('d2')))
          .write(TemplateDimensionsCompanion(config: Value('{"ref_template_id":"$houseTemplateId"}')));
      await (db.update(db.templateDimensions)..where((td) => td.id.equals('d4')))
          .write(TemplateDimensionsCompanion(config: Value('{"ref_template_id":"$roomTemplateId"}')));

      final communityId = await _insertInstance(db, communityTemplateId, null, '华润二十四城', {'d1': '华润二十四城'});
      final houseId = await _insertInstance(db, houseTemplateId, communityId, '7栋-1203', {'d3': '南'});
      await _insertInstance(db, roomTemplateId, houseId, '主卧', {'d5': '20'});

      // Navigate to 首页
      await tester.tap(bottomNavItem('首页'));
      await tester.pumpAndSettle();

      // Verify parent instance is visible
      expect(find.text('华润二十四城'), findsOneWidget);

      // Swipe left on the instance card to trigger delete
      final cardFinder = find.widgetWithText(InstanceCard, '华润二十四城');
      await tester.drag(cardFinder, const Offset(-800, 0));
      await tester.pumpAndSettle();

      // Wait for confirm dialog to appear with descendant count
      await pumpUntilFound(tester, find.text('确认删除'));
      expect(find.textContaining('将同时删除 2 个子实例'), findsOneWidget);

      // Tap delete
      await tester.tap(find.widgetWithText(TextButton, '删除'));
      await tester.pumpAndSettle();

      // Verify SnackBar and card disappearance
      await pumpUntilFound(tester, find.text('实例已删除'));
      await pumpUntilAbsent(tester, find.text('华润二十四城'));

      // Verify all instances are deleted from DB (cascade)
      final allInstances = await db.select(db.instances).get();
      expect(allInstances, isEmpty);
    });

    testWidgets('Story 4.2 - Swipe to delete child instance cascades to grandchildren',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Pre-create a 3-level hierarchy directly in DB
      final communityTemplateId = await _insertTemplate(db, '小区模板', [
        _dim('d1', '小区名', 'text', '{}'),
        _dim('d2', '房子列表', 'ref_subtemplate', '{"ref_template_id":"house_tpl"}'),
      ]);
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        _dim('d3', '朝向', 'single_choice', '{"options":["东","南"]}'),
        _dim('d4', '房间列表', 'ref_subtemplate', '{"ref_template_id":"room_tpl"}'),
      ]);
      final roomTemplateId = await _insertTemplate(db, '房间模板', [
        _dim('d5', '面积', 'number', '{}'),
      ]);
      // Fix refs to actual IDs
      await (db.update(db.templateDimensions)..where((td) => td.id.equals('d2')))
          .write(TemplateDimensionsCompanion(config: Value('{"ref_template_id":"$houseTemplateId"}')));
      await (db.update(db.templateDimensions)..where((td) => td.id.equals('d4')))
          .write(TemplateDimensionsCompanion(config: Value('{"ref_template_id":"$roomTemplateId"}')));

      final communityId = await _insertInstance(db, communityTemplateId, null, '华润二十四城', {'d1': '华润二十四城'});
      final houseId = await _insertInstance(db, houseTemplateId, communityId, '7栋-1203', {'d3': '南'});
      await _insertInstance(db, roomTemplateId, houseId, '主卧', {'d5': '20'});

      // Navigate to 首页
      await tester.tap(bottomNavItem('首页'));
      await tester.pumpAndSettle();

      // Drill down into parent instance
      await tester.tap(find.text('华润二十四城'));
      await tester.pumpAndSettle();

      // Verify child instance is visible in the list
      expect(find.text('7栋-1203'), findsOneWidget);

      // Swipe left on the child instance card to trigger delete
      final cardFinder = find.widgetWithText(InstanceCard, '7栋-1203');
      await tester.drag(cardFinder, const Offset(-800, 0));
      await tester.pumpAndSettle();

      // Wait for confirm dialog to appear with descendant count (1 room)
      await pumpUntilFound(tester, find.text('确认删除'));
      expect(find.textContaining('将同时删除 1 个子实例'), findsOneWidget);

      // Tap delete
      await tester.tap(find.widgetWithText(TextButton, '删除'));
      await tester.pumpAndSettle();

      // Verify SnackBar and card disappearance
      await pumpUntilFound(tester, find.text('实例已删除'));
      await pumpUntilAbsent(tester, find.text('7栋-1203'));

      // Verify parent instance still exists
      final parentInstance = await (db.select(db.instances)..where((i) => i.id.equals(communityId))).getSingleOrNull();
      expect(parentInstance, isNot(equals(null)));
      expect(parentInstance!.name, '华润二十四城');

      // Verify child and grandchild are deleted from DB (cascade)
      final remainingInstances = await db.select(db.instances).get();
      expect(remainingInstances.length, 1);
      expect(remainingInstances.first.id, communityId);
    });

    testWidgets('Story 5.1 - Edit child instance from parent instance editor',
        (WidgetTester tester) async {
      // Seed data
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        TemplateDimensionsCompanion(
          id: const Value('d1'),
          name: const Value('朝向'),
          type: const Value('single_choice'),
          config: const Value('{"options": ["东", "南", "西", "北", "东南"]}'),
        ),
      ]);
      final communityTemplateId = await _insertTemplate(db, '小区模板', [
        TemplateDimensionsCompanion(
          id: const Value('d2'),
          name: const Value('小区名'),
          type: const Value('text'),
          config: const Value('{}'),
        ),
        TemplateDimensionsCompanion(
          id: const Value('d3'),
          name: const Value('房子列表'),
          type: const Value('ref_subtemplate'),
          config: Value('{"ref_template_id": "$houseTemplateId"}'),
        ),
      ]);
      final communityId = await _insertInstance(
        db, communityTemplateId, null, '华润二十四城', {'d2': '华润二十四城'},
      );
      final houseId = await _insertInstance(
        db, houseTemplateId, communityId, '7栋-1203', {'d1': '南'},
      );

      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Tap edit icon on community instance card
      final editButton = find.descendant(
        of: find.widgetWithText(InstanceCard, '华润二十四城'),
        matching: find.byIcon(Icons.edit),
      );
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify child instance card is visible
      expect(find.widgetWithText(InstanceCard, '7栋-1203'), findsOneWidget);

      // Tap child instance card to edit
      await tester.tap(find.widgetWithText(InstanceCard, '7栋-1203'));
      await tester.pumpAndSettle();

      // Change orientation to "东南"
      await tester.tap(find.text('东南'));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Verify back on parent editor and child card still visible
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.widgetWithText(InstanceCard, '7栋-1203'), findsOneWidget);

      // Verify child was updated
      await tester.tap(find.widgetWithText(InstanceCard, '7栋-1203'));
      await tester.pumpAndSettle();
      expect(find.text('东南'), findsOneWidget);
    });

    testWidgets('Story 5.2 - Edit parent fields with child instances visible',
        (WidgetTester tester) async {
      // Seed data
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        TemplateDimensionsCompanion(
          id: const Value('d1'),
          name: const Value('朝向'),
          type: const Value('single_choice'),
          config: const Value('{"options": ["东", "南", "西", "北"]}'),
        ),
      ]);
      final communityTemplateId = await _insertTemplate(db, '小区模板', [
        TemplateDimensionsCompanion(
          id: const Value('d2'),
          name: const Value('小区名'),
          type: const Value('text'),
          config: const Value('{}'),
        ),
        TemplateDimensionsCompanion(
          id: const Value('d3'),
          name: const Value('位置'),
          type: const Value('text'),
          config: const Value('{}'),
        ),
        TemplateDimensionsCompanion(
          id: const Value('d4'),
          name: const Value('房子列表'),
          type: const Value('ref_subtemplate'),
          config: Value('{"ref_template_id": "$houseTemplateId"}'),
        ),
      ]);
      final communityId = await _insertInstance(
        db, communityTemplateId, null, '华润二十四城',
        {'d2': '华润二十四城', 'd3': '成华区双庆路'},
      );
      await _insertInstance(
        db, houseTemplateId, communityId, '7栋-1203', {'d1': '南'},
      );

      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Tap edit icon on community instance card
      final editButton = find.descendant(
        of: find.widgetWithText(InstanceCard, '华润二十四城'),
        matching: find.byIcon(Icons.edit),
      );
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify child instance card is visible
      expect(find.widgetWithText(InstanceCard, '7栋-1203'), findsOneWidget);

      // Edit parent field "位置"
      final locationField = find.widgetWithText(TextFormField, '成华区双庆路');
      await tester.enterText(locationField, '成华区双庆路6号');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Verify back on list page, then re-enter editor
      expect(bottomNavItem('首页'), findsOneWidget);

      await tester.tap(find.descendant(
        of: find.widgetWithText(InstanceCard, '华润二十四城'),
        matching: find.byIcon(Icons.edit),
      ));
      await tester.pumpAndSettle();

      // Verify child card still visible and parent field updated
      expect(find.widgetWithText(InstanceCard, '7栋-1203'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '成华区双庆路6号'), findsOneWidget);
    });

    testWidgets('Default templates are seeded on first launch',
        (WidgetTester tester) async {
      // Fresh DB + loader simulates first app launch
      await DefaultTemplateLoader(db).loadIfNeeded();
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Navigate to 模板 tab
      await tester.tap(bottomNavItem('模板'));
      await tester.pumpAndSettle();

      // Verify all 4 default templates appear
      expect(find.text('小区模板'), findsOneWidget);
      expect(find.text('房子模板'), findsOneWidget);
      expect(find.text('客厅模板'), findsOneWidget);
      expect(find.text('卧室模板'), findsOneWidget);

      // Verify 小区模板 has 房子 ref_subtemplate
      await tester.tap(find.text('小区模板'));
      await tester.pumpAndSettle();
      expect(find.text('房子 (ref_subtemplate)'), findsOneWidget);

      // Go back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify 房子模板 has single_choice dimensions
      await tester.tap(find.text('房子模板'));
      await tester.pumpAndSettle();
      expect(find.text('民水民电 (single_choice)'), findsOneWidget);
      expect(find.text('电梯 (single_choice)'), findsOneWidget);
    });

    testWidgets('Deleted default template is not recreated on restart',
        (WidgetTester tester) async {
      // First launch
      await DefaultTemplateLoader(db).loadIfNeeded();

      // Delete 客厅模板 directly from DB
      final livingRoom = await (db.select(db.templates)
            ..where((t) => t.name.equals('客厅模板')))
          .getSingle();
      await (db.delete(db.templates)
            ..where((t) => t.id.equals(livingRoom.id)))
          .go();

      // Restart app (re-pump)
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Call loader again simulating app restart
      await DefaultTemplateLoader(db).loadIfNeeded();
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Navigate to 模板
      await tester.tap(bottomNavItem('模板'));
      await tester.pumpAndSettle();

      // 客厅模板 should still be gone
      expect(find.text('客厅模板'), findsNothing);
      // Others should still exist
      expect(find.text('小区模板'), findsOneWidget);
      expect(find.text('房子模板'), findsOneWidget);
      expect(find.text('卧室模板'), findsOneWidget);
    });

    testWidgets('Manual restore recreates deleted default template',
        (WidgetTester tester) async {
      await DefaultTemplateLoader(db).loadIfNeeded();

      // Delete 客厅模板
      final livingRoom = await (db.select(db.templates)
            ..where((t) => t.name.equals('客厅模板')))
          .getSingle();
      await (db.delete(db.templates)
            ..where((t) => t.id.equals(livingRoom.id)))
          .go();

      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Go to Settings and restore
      await tester.tap(bottomNavItem('设置'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('恢复默认模板'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Verify snackbar
      expect(find.text('已恢复 1 个模板'), findsOneWidget);

      // Go to templates and verify 客厅模板 is back
      await tester.tap(bottomNavItem('模板'));
      await tester.pumpAndSettle();
      expect(find.text('客厅模板'), findsOneWidget);
    });

    testWidgets('Full instance creation flow with default templates',
        (WidgetTester tester) async {
      await DefaultTemplateLoader(db).loadIfNeeded();
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Navigate to 首页
      await tester.tap(bottomNavItem('首页'));
      await tester.pumpAndSettle();

      // Create top-level community instance
      await tester.tap(instanceListFab());
      await tester.pumpAndSettle();
      await tester.tap(find.text('小区模板'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '华润二十四城');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '地址'), matching: find.byType(TextFormField)),
        '成华区双庆路',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '建成年份'), matching: find.byType(TextFormField)),
        '2015',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await pumpUntilFound(tester, find.text('华润二十四城'));

      // Drill down to house level
      await tester.tap(find.text('华润二十四城'));
      await tester.pumpAndSettle();

      // Create child house instance
      await tester.tap(instanceListFab(), warnIfMissed: false);
      await tester.pumpAndSettle();
      if (find.text('选择要新建的子类型').evaluate().isNotEmpty) {
        await tester.tap(find.text('房子模板'));
        await tester.pumpAndSettle();
      }
      await pumpUntilFound(tester, find.text('房租'));

      await tester.enterText(find.byType(TextFormField).first, '7栋-1203');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '房租'), matching: find.byType(TextFormField)),
        '3500',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '户型'), matching: find.byType(TextFormField)),
        '三室一厅',
      );
      await tester.pumpAndSettle();
      // Select 是 for 民水民电
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(ListTile, '民水民电'),
          matching: find.widgetWithText(ChoiceChip, '是'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await pumpUntilFound(tester, find.text('7栋-1203'));

      // Drill down to room level
      await tester.tap(find.text('7栋-1203'));
      await tester.pumpAndSettle();

      // Create 客厅 instance
      await tester.tap(instanceListFab(), warnIfMissed: false);
      await tester.pumpAndSettle();
      try {
        await pumpUntilFound(tester, find.text('选择要新建的子类型'), timeout: const Duration(seconds: 5));
        await tester.tap(find.text('客厅模板'));
        await tester.pumpAndSettle();
      } catch (_) {
        // Single subtemplate, no dialog
      }
      await pumpUntilFound(tester, find.text('电视状态'));
      await tester.enterText(find.byType(TextFormField).first, '客厅');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '电视状态'), matching: find.byType(TextFormField)),
        '完好',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await pumpUntilFound(tester, find.text('客厅'));

      // Create 卧室 instance (sibling of 客厅)
      final fabWidget = instanceListFab().evaluate().first.widget as FloatingActionButton;
      fabWidget.onPressed!();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      try {
        await pumpUntilFound(tester, find.text('选择要新建的子类型'), timeout: const Duration(seconds: 5));
        await tester.tap(find.text('卧室模板'));
        await tester.pumpAndSettle();
      } catch (_) {
        // Single subtemplate, no dialog
      }
      await pumpUntilFound(tester, find.text('床垫状态'));
      await tester.enterText(find.byType(TextFormField).first, '主卧');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.widgetWithText(ListTile, '床垫状态'), matching: find.byType(TextFormField)),
        '新床垫',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await pumpUntilFound(tester, find.text('主卧'));

      // Verify breadcrumb
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('华润二十四城'), findsOneWidget);
      expect(find.text('7栋-1203'), findsOneWidget);
      expect(find.text('客厅'), findsOneWidget);
      expect(find.text('主卧'), findsOneWidget);
    });

    testWidgets('Story: First-time user sees tutorial prompt and can skip',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Verify welcome dialog appears
      expect(find.text('欢迎使用 House Note'), findsOneWidget);
      expect(find.text('这是您第一次使用。是否查看快速入门教程？'), findsOneWidget);

      // Tap 查看教程
      await tester.tap(find.text('查看教程'));
      await tester.pumpAndSettle();

      // Verify TutorialScreen opens
      expect(find.text('快速入门'), findsOneWidget);
      expect(find.text('欢迎来到 House Note'), findsOneWidget);

      // Swipe through all pages
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.text('下一页'));
        await tester.pumpAndSettle();
      }

      // On last page, tap 完成
      expect(find.text('开始记录吧'), findsOneWidget);
      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();

      // Should be back on home screen
      expect(find.text('首页'), findsNWidgets(2));

      // Rebuild app to simulate restart
      await tester.pumpWidget(HouseNoteApp(database: db, prefs: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      // Dialog should NOT appear again
      expect(find.text('欢迎使用 House Note'), findsNothing);
    });
  });
}

TemplateDimensionsCompanion _dim(
  String id,
  String name,
  String type,
  String config,
) {
  return TemplateDimensionsCompanion(
    id: Value(id),
    templateId: const Value(''),
    name: Value(name),
    type: Value(type),
    config: Value(config),
    sortOrder: const Value(0),
  );
}

Future<String> _insertTemplate(AppDatabase db, String name, List<TemplateDimensionsCompanion> dims) async {
  final id = 'tpl_${name.hashCode}';
  await db.into(db.templates).insert(
    TemplatesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: const Value(1),
      updatedAt: const Value(1),
    ),
    mode: InsertMode.insertOrReplace,
  );
  for (var i = 0; i < dims.length; i++) {
    final d = dims[i];
    await db.into(db.templateDimensions).insert(
      TemplateDimensionsCompanion(
        id: d.id,
        templateId: Value(id),
        name: d.name,
        type: d.type,
        config: d.config,
        sortOrder: Value(i),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
  return id;
}

Future<String> _insertInstance(
  AppDatabase db,
  String templateId,
  String? parentId,
  String name,
  Map<String, String> values,
) async {
  final id = 'inst_${name.hashCode}_$templateId';
  await db.into(db.instances).insert(
    InstancesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      parentInstanceId: Value(parentId),
      name: Value(name),
      createdAt: const Value(1),
      updatedAt: const Value(1),
    ),
    mode: InsertMode.insertOrReplace,
  );
  for (final e in values.entries) {
    await db.into(db.instanceValues).insert(
      InstanceValuesCompanion(
        id: Value('${e.key}_$id'),
        instanceId: Value(id),
        dimensionId: Value(e.key),
        value: Value(e.value),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
  return id;
}
