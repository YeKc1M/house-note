import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/instance_repository.dart';

void main() {
  late AppDatabase db;
  late InstanceRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = InstanceRepository(db);
    await db.customStatement('PRAGMA foreign_keys = ON');
    await db.into(db.templates).insert(TemplatesCompanion.insert(
      id: 'tmpl',
      name: 'T',
      createdAt: 0,
      updatedAt: 0,
    ));
    await db.into(db.templateDimensions).insert(TemplateDimensionsCompanion.insert(
      id: 'dim',
      templateId: 'tmpl',
      name: 'F',
      type: 'text',
      config: '',
      sortOrder: 0,
    ));
    await db.into(db.templateDimensions).insert(TemplateDimensionsCompanion.insert(
      id: 'dim2',
      templateId: 'tmpl',
      name: 'F2',
      type: 'number',
      config: '',
      sortOrder: 1,
    ));
  });

  tearDown(() async => db.close());

  test('insertInstance with values', () async {
    final instance = InstancesCompanion.insert(
      id: 'i1',
      templateId: 'tmpl',
      name: 'Instance',
      createdAt: 1,
      updatedAt: 1,
    );
    final values = [
      InstanceValuesCompanion.insert(
        id: 'v1',
        instanceId: 'i1',
        dimensionId: 'dim',
        value: 'hello',
      ),
    ];
    await repo.insertInstance(instance, values: values);
    final result = await repo.getInstanceById('i1');
    expect(result, isNotNull);
    expect(result!.instance.name, 'Instance');
    expect(result.values.length, 1);
    expect(result.values.first.value, 'hello');
  });

  test('watchTopLevelInstances emits inserted instances', () async {
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'i1',
      templateId: 'tmpl',
      name: 'Top',
      createdAt: 1,
      updatedAt: 1,
    ));
    expectLater(
      repo.watchTopLevelInstances(),
      emits(predicate<List<Instance>>((list) => list.length == 1 && list.first.name == 'Top')),
    );
  });

  test('updateInstance updates values, custom fields, and hidden dimensions', () async {
    await repo.insertInstance(
      InstancesCompanion.insert(
        id: 'i1',
        templateId: 'tmpl',
        name: 'Original',
        createdAt: 1,
        updatedAt: 1,
      ),
      values: [
        InstanceValuesCompanion.insert(
          id: 'v1',
          instanceId: 'i1',
          dimensionId: 'dim',
          value: 'old',
        ),
      ],
      customFields: [
        InstanceCustomFieldsCompanion.insert(
          id: 'cf1',
          instanceId: 'i1',
          name: 'Old CF',
          type: 'text',
          value: 'old cf value',
          config: '',
        ),
      ],
      hiddenDimensions: [
        InstanceHiddenDimensionsCompanion.insert(
          id: 'hd1',
          instanceId: 'i1',
          dimensionId: 'dim2',
        ),
      ],
    );

    await repo.updateInstance(
      InstancesCompanion.insert(
        id: 'i1',
        templateId: 'tmpl',
        name: 'Updated',
        createdAt: 1,
        updatedAt: 2,
      ),
      values: [
        InstanceValuesCompanion.insert(
          id: 'v2',
          instanceId: 'i1',
          dimensionId: 'dim2',
          value: 'new',
        ),
      ],
      customFields: [
        InstanceCustomFieldsCompanion.insert(
          id: 'cf2',
          instanceId: 'i1',
          name: 'New CF',
          type: 'number',
          value: '42',
          config: '',
        ),
      ],
      hiddenDimensions: [
        InstanceHiddenDimensionsCompanion.insert(
          id: 'hd2',
          instanceId: 'i1',
          dimensionId: 'dim',
        ),
      ],
    );

    final result = await repo.getInstanceById('i1');
    expect(result, isNotNull);
    expect(result!.instance.name, 'Updated');
    expect(result.values.length, 1);
    expect(result.values.first.value, 'new');
    expect(result.customFields.length, 1);
    expect(result.customFields.first.name, 'New CF');
    expect(result.hiddenDimensions.length, 1);
    expect(result.hiddenDimensions.first.dimensionId, 'dim');
  });

  test('deleteInstance deletes instance and child instances', () async {
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'parent',
      templateId: 'tmpl',
      name: 'Parent',
      createdAt: 1,
      updatedAt: 1,
    ));
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'child',
      templateId: 'tmpl',
      parentInstanceId: Value('parent'),
      name: 'Child',
      createdAt: 1,
      updatedAt: 1,
    ));

    await repo.deleteInstance('parent');

    expect(await repo.getInstanceById('parent'), isNull);
    expect(await repo.getInstanceById('child'), isNull);
  });

  test('watchChildInstances emits child instances', () async {
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'parent',
      templateId: 'tmpl',
      name: 'Parent',
      createdAt: 1,
      updatedAt: 1,
    ));
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'child',
      templateId: 'tmpl',
      parentInstanceId: Value('parent'),
      name: 'Child',
      createdAt: 1,
      updatedAt: 1,
    ));

    expectLater(
      repo.watchChildInstances('parent'),
      emits(predicate<List<Instance>>((list) => list.length == 1 && list.first.name == 'Child')),
    );
  });

  test('getInstanceById with custom fields and hidden dimensions', () async {
    await repo.insertInstance(
      InstancesCompanion.insert(
        id: 'i1',
        templateId: 'tmpl',
        name: 'Full',
        createdAt: 1,
        updatedAt: 1,
      ),
      values: [
        InstanceValuesCompanion.insert(
          id: 'v1',
          instanceId: 'i1',
          dimensionId: 'dim',
          value: 'val',
        ),
      ],
      customFields: [
        InstanceCustomFieldsCompanion.insert(
          id: 'cf1',
          instanceId: 'i1',
          name: 'CF',
          type: 'text',
          value: 'cfv',
          config: '',
        ),
      ],
      hiddenDimensions: [
        InstanceHiddenDimensionsCompanion.insert(
          id: 'hd1',
          instanceId: 'i1',
          dimensionId: 'dim2',
        ),
      ],
    );

    final result = await repo.getInstanceById('i1');
    expect(result, isNotNull);
    expect(result!.instance.name, 'Full');
    expect(result.values.length, 1);
    expect(result.values.first.value, 'val');
    expect(result.customFields.length, 1);
    expect(result.customFields.first.value, 'cfv');
    expect(result.hiddenDimensions.length, 1);
    expect(result.hiddenDimensions.first.dimensionId, 'dim2');
  });
}
