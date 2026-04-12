import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/template_repository.dart';

void main() {
  late AppDatabase db;
  late TemplateRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
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
        emits(predicate<List<Template>>(
            (list) => list.length == 1 && list.first.name == '测试模板')),
      );
    });
  });

  group('updateTemplate', () {
    test('updates template and replaces dimensions', () async {
      await repo.insertTemplate(
        TemplatesCompanion.insert(
          id: 't1',
          name: 'Original',
          createdAt: 0,
          updatedAt: 0,
        ),
        [
          TemplateDimensionsCompanion.insert(
            id: 'd1',
            templateId: 't1',
            name: 'Old Dim',
            type: 'text',
            config: '{}',
            sortOrder: 0,
          ),
        ],
      );

      await repo.updateTemplate(
        TemplatesCompanion.insert(
          id: 't1',
          name: 'Updated',
          createdAt: 0,
          updatedAt: 1,
        ),
        [
          TemplateDimensionsCompanion.insert(
            id: 'd2',
            templateId: 't1',
            name: 'New Dim',
            type: 'number',
            config: '{}',
            sortOrder: 0,
          ),
        ],
      );

      final result = await repo.getTemplateById('t1');
      expect(result, isNotNull);
      expect(result!.template.name, 'Updated');
      expect(result.dimensions.length, 1);
      expect(result.dimensions.first.name, 'New Dim');
      expect(result.dimensions.first.type, 'number');
    });
  });

  group('deleteTemplate', () {
    test('deletes template and cascades dimensions', () async {
      await repo.insertTemplate(
        TemplatesCompanion.insert(
          id: 't1',
          name: 'To Delete',
          createdAt: 0,
          updatedAt: 0,
        ),
        [
          TemplateDimensionsCompanion.insert(
            id: 'd1',
            templateId: 't1',
            name: 'Dim',
            type: 'text',
            config: '{}',
            sortOrder: 0,
          ),
        ],
      );

      await repo.deleteTemplate('t1');

      final result = await repo.getTemplateById('t1');
      expect(result, isNull);

      final dimensions = await db.select(db.templateDimensions).get();
      expect(dimensions.where((d) => d.templateId == 't1'), isEmpty);
    });
  });

  group('countInstancesForTemplate', () {
    test('returns correct count using SQL COUNT', () async {
      await db.into(db.templates).insert(TemplatesCompanion.insert(
        id: 't1',
        name: 'Template',
        createdAt: 0,
        updatedAt: 0,
      ));

      expect(await repo.countInstancesForTemplate('t1'), 0);

      await db.into(db.instances).insert(InstancesCompanion.insert(
        id: 'i1',
        templateId: 't1',
        name: 'Instance 1',
        createdAt: 0,
        updatedAt: 0,
      ));
      await db.into(db.instances).insert(InstancesCompanion.insert(
        id: 'i2',
        templateId: 't1',
        name: 'Instance 2',
        createdAt: 0,
        updatedAt: 0,
      ));

      expect(await repo.countInstancesForTemplate('t1'), 2);
    });
  });

  group('getThumbnailFields / setThumbnailFields', () {
    test('sets and retrieves thumbnail fields', () async {
      await db.into(db.templates).insert(TemplatesCompanion.insert(
        id: 't1',
        name: 'Template',
        createdAt: 0,
        updatedAt: 0,
      ));
      await db.into(db.templateDimensions).insert(
        TemplateDimensionsCompanion.insert(
          id: 'd1',
          templateId: 't1',
          name: 'Dim1',
          type: 'text',
          config: '{}',
          sortOrder: 0,
        ),
      );

      final fields = [
        TemplateThumbnailFieldsCompanion.insert(
          id: 'f1',
          templateId: 't1',
          dimensionId: 'd1',
          sortOrder: 0,
        ),
      ];

      await repo.setThumbnailFields('t1', fields);
      final result = await repo.getThumbnailFields('t1');
      expect(result.length, 1);
      expect(result.first.dimensionId, 'd1');
      expect(result.first.sortOrder, 0);
    });

    test('replacing thumbnail fields deletes old ones', () async {
      await db.into(db.templates).insert(TemplatesCompanion.insert(
        id: 't1',
        name: 'Template',
        createdAt: 0,
        updatedAt: 0,
      ));
      await db.into(db.templateDimensions).insert(
        TemplateDimensionsCompanion.insert(
          id: 'd1',
          templateId: 't1',
          name: 'Dim1',
          type: 'text',
          config: '{}',
          sortOrder: 0,
        ),
      );
      await db.into(db.templateDimensions).insert(
        TemplateDimensionsCompanion.insert(
          id: 'd2',
          templateId: 't1',
          name: 'Dim2',
          type: 'text',
          config: '{}',
          sortOrder: 1,
        ),
      );

      await repo.setThumbnailFields('t1', [
        TemplateThumbnailFieldsCompanion.insert(
          id: 'f1',
          templateId: 't1',
          dimensionId: 'd1',
          sortOrder: 0,
        ),
      ]);

      await repo.setThumbnailFields('t1', [
        TemplateThumbnailFieldsCompanion.insert(
          id: 'f2',
          templateId: 't1',
          dimensionId: 'd2',
          sortOrder: 0,
        ),
      ]);

      final result = await repo.getThumbnailFields('t1');
      expect(result.length, 1);
      expect(result.first.dimensionId, 'd2');
    });
  });
}
