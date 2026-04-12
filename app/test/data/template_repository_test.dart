import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/tables.dart';
import 'package:house_note/data/template_repository.dart';

void main() {
  late AppDatabase db;
  late TemplateRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TemplateRepository(db);
  });

  tearDown(() async => db.close());

  group('insertTemplate', () {
    test('inserts template with dimensions', () async {
      final template = TemplatesCompanion.insert(
        id: 't1',
        name: '房子模板',
        createdAt: 0,
        updatedAt: 0,
      );
      final dimensions = [
        TemplateDimensionsCompanion.insert(
          id: 'd1',
          templateId: 't1',
          name: '朝向',
          type: 'single_choice',
          config: '{"options":["东","南","西","北"]}',
          sortOrder: 0,
        ),
      ];
      await repo.insertTemplate(template, dimensions);
      final result = await repo.getTemplateById('t1');
      expect(result, isNotNull);
      expect(result!.template.name, '房子模板');
      expect(result.dimensions.length, 1);
      expect(result.dimensions.first.name, '朝向');
    });
  });

  group('watchAllTemplates', () {
    test('emits list after insert', () async {
      await db.into(db.templates).insert(TemplatesCompanion.insert(
        id: 't1',
        name: '测试模板',
        createdAt: 1,
        updatedAt: 1,
      ));
      expectLater(
        repo.watchAllTemplates(),
        emits(predicate<List<Template>>((list) => list.length == 1 && list.first.name == '测试模板')),
      );
    });
  });
}
