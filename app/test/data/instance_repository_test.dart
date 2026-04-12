import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/instance_repository.dart';
import 'package:house_note/data/tables.dart';

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
}
