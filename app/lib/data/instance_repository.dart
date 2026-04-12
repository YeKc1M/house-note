import 'package:drift/drift.dart';
import 'database.dart';

class InstanceWithData {
  final Instance instance;
  final List<InstanceValue> values;
  final List<InstanceCustomField> customFields;
  final List<InstanceHiddenDimension> hiddenDimensions;

  InstanceWithData(
    this.instance,
    this.values,
    this.customFields,
    this.hiddenDimensions,
  );
}

class InstanceRepository {
  final AppDatabase _db;

  InstanceRepository(this._db);

  Stream<List<Instance>> watchTopLevelInstances() {
    return (_db.select(_db.instances)
      ..where((i) => i.parentInstanceId.isNull())
      ..orderBy([(i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)]))
      .watch();
  }

  Stream<List<Instance>> watchChildInstances(String parentInstanceId) {
    return (_db.select(_db.instances)
      ..where((i) => i.parentInstanceId.equals(parentInstanceId))
      ..orderBy([(i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)]))
      .watch();
  }

  Future<InstanceWithData?> getInstanceById(String id) async {
    final instance = await (_db.select(_db.instances)
      ..where((i) => i.id.equals(id)))
      .getSingleOrNull();
    if (instance == null) return null;

    final values = await (_db.select(_db.instanceValues)
      ..where((v) => v.instanceId.equals(id)))
      .get();
    final customFields = await (_db.select(_db.instanceCustomFields)
      ..where((f) => f.instanceId.equals(id)))
      .get();
    final hidden = await (_db.select(_db.instanceHiddenDimensions)
      ..where((h) => h.instanceId.equals(id)))
      .get();

    return InstanceWithData(instance, values, customFields, hidden);
  }

  Future<void> insertInstance(
    InstancesCompanion instance, {
    List<InstanceValuesCompanion> values = const [],
    List<InstanceCustomFieldsCompanion> customFields = const [],
    List<InstanceHiddenDimensionsCompanion> hiddenDimensions = const [],
  }) async {
    await _db.transaction(() async {
      await _db.into(_db.instances).insert(instance);
      for (final v in values) {
        await _db.into(_db.instanceValues).insert(v, mode: InsertMode.insertOrReplace);
      }
      for (final f in customFields) {
        await _db.into(_db.instanceCustomFields).insert(f, mode: InsertMode.insertOrReplace);
      }
      for (final h in hiddenDimensions) {
        await _db.into(_db.instanceHiddenDimensions).insert(h, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<void> updateInstance(
    InstancesCompanion instance, {
    List<InstanceValuesCompanion> values = const [],
    List<InstanceCustomFieldsCompanion> customFields = const [],
    List<InstanceHiddenDimensionsCompanion> hiddenDimensions = const [],
  }) async {
    await _db.transaction(() async {
      await _db.update(_db.instances).replace(instance);
      for (final v in values) {
        await _db.into(_db.instanceValues).insert(v, mode: InsertMode.insertOrReplace);
      }
      await (_db.delete(_db.instanceCustomFields)
        ..where((f) => f.instanceId.equals(instance.id.value)))
        .go();
      for (final f in customFields) {
        await _db.into(_db.instanceCustomFields).insert(f);
      }
      await (_db.delete(_db.instanceHiddenDimensions)
        ..where((h) => h.instanceId.equals(instance.id.value)))
        .go();
      for (final h in hiddenDimensions) {
        await _db.into(_db.instanceHiddenDimensions).insert(h);
      }
    });
  }

  Future<void> deleteInstance(String id) async {
    await (_db.delete(_db.instances)..where((i) => i.id.equals(id))).go();
  }

  Future<List<TemplateDimension>> getRefSubtemplateDimensions(String templateId) async {
    return (_db.select(_db.templateDimensions)
      ..where((d) => d.templateId.equals(templateId) & d.type.equals('ref_subtemplate'))
      ..orderBy([(d) => OrderingTerm(expression: d.sortOrder)]))
      .get();
  }
}
