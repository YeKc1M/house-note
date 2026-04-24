import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/default_template_loader.dart';
import 'package:house_note/data/template_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TemplateRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = TemplateRepository(db);
  });

  tearDown(() async => db.close());

  group('loadIfNeeded', () {
    test('inserts all default templates on first call', () async {
      final loader = DefaultTemplateLoader(db);
      await loader.loadIfNeeded();

      final templates = await repo.watchAllTemplates().first;
      expect(templates.map((t) => t.name), containsAll([
        '小区模板',
        '房子模板',
        '客厅模板',
        '卧室模板',
      ]));

      // Verify 小区模板 has 房子 ref_subtemplate
      final community = await repo.getTemplateById(
        templates.firstWhere((t) => t.name == '小区模板').id,
      );
      final houseRef = community!.dimensions.firstWhere((d) => d.name == '房子');
      expect(houseRef.type, 'ref_subtemplate');
      final config = jsonDecode(houseRef.config) as Map<String, dynamic>;
      final houseTemplate = templates.firstWhere((t) => t.name == '房子模板');
      expect(config['ref_template_id'], houseTemplate.id);

      // Verify 房子模板 has single_choice with options
      final house = await repo.getTemplateById(houseTemplate.id);
      final minDian = house!.dimensions.firstWhere((d) => d.name == '民水民电');
      expect(minDian.type, 'single_choice');
      final minDianConfig = jsonDecode(minDian.config) as Map<String, dynamic>;
      expect(minDianConfig['options'], ['是', '否']);

      // Verify flag is set
      final settings = await (db.select(db.appSettings)
            ..where((s) => s.key.equals('default_templates_initialized')))
          .getSingleOrNull();
      expect(settings, isNotNull);
      expect(settings!.value, 'true');
    });

    test('is idempotent on second call', () async {
      final loader = DefaultTemplateLoader(db);
      await loader.loadIfNeeded();
      final firstCount = (await repo.watchAllTemplates().first).length;

      await loader.loadIfNeeded();
      final secondCount = (await repo.watchAllTemplates().first).length;

      expect(secondCount, firstCount);
    });
  });

  group('restoreDefaults', () {
    test('recreates only missing templates', () async {
      final loader = DefaultTemplateLoader(db);
      await loader.loadIfNeeded();

      // Delete 客厅模板
      final livingRoom = await (db.select(db.templates)
            ..where((t) => t.name.equals('客厅模板')))
          .getSingle();
      await (db.delete(db.templates)
            ..where((t) => t.id.equals(livingRoom.id)))
          .go();

      final beforeRestore = (await repo.watchAllTemplates().first).length;
      expect(beforeRestore, 3);

      final restored = await loader.restoreDefaults();
      expect(restored, 1);

      final afterRestore = await repo.watchAllTemplates().first;
      expect(afterRestore.length, 4);
      expect(afterRestore.map((t) => t.name), contains('客厅模板'));
    });

    test('returns 0 when all templates exist', () async {
      final loader = DefaultTemplateLoader(db);
      await loader.loadIfNeeded();

      final restored = await loader.restoreDefaults();
      expect(restored, 0);
    });
  });
}
