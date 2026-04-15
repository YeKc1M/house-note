import 'package:drift/drift.dart';
import 'database.dart';

class TemplateWithDimensions {
  final Template template;
  final List<TemplateDimension> dimensions;

  TemplateWithDimensions(this.template, this.dimensions);
}

class TemplateRepository {
  final AppDatabase _db;

  TemplateRepository(this._db);

  Stream<List<Template>> watchAllTemplates() {
    return _db.select(_db.templates).watch();
  }

  Future<TemplateWithDimensions?> getTemplateById(String id) async {
    final template = await (_db.select(_db.templates)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (template == null) return null;

    final dimensions = await (_db.select(_db.templateDimensions)
          ..where((d) => d.templateId.equals(id))
          ..orderBy([(d) => OrderingTerm(expression: d.sortOrder)]))
        .get();

    return TemplateWithDimensions(template, dimensions);
  }

  Future<void> insertTemplate(
    TemplatesCompanion template,
    List<TemplateDimensionsCompanion> dimensions,
  ) async {
    await _db.transaction(() async {
      await _db.into(_db.templates).insert(template);
      for (final d in dimensions) {
        await _db.into(_db.templateDimensions).insert(d);
      }
    });
  }

  Future<void> updateTemplate(
    TemplatesCompanion template,
    List<TemplateDimensionsCompanion> dimensions,
  ) async {
    await _db.transaction(() async {
      await (_db.update(_db.templates)
            ..where((t) => t.id.equals(template.id.value)))
          .write(template);
      await (_db.delete(_db.templateDimensions)
            ..where((d) => d.templateId.equals(template.id.value)))
          .go();
      for (final d in dimensions) {
        await _db
            .into(_db.templateDimensions)
            .insert(d, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<void> deleteTemplate(String id) async {
    await (_db.delete(_db.templates)..where((t) => t.id.equals(id))).go();
  }

  Future<int> countInstancesForTemplate(String templateId) async {
    final countExp = _db.instances.templateId.count();
    final query = _db.selectOnly(_db.instances)..addColumns([countExp]);
    query.where(_db.instances.templateId.equals(templateId));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<List<TemplateThumbnailField>> getThumbnailFields(String templateId) async {
    return (_db.select(_db.templateThumbnailFields)
          ..where((f) => f.templateId.equals(templateId))
          ..orderBy([(f) => OrderingTerm(expression: f.sortOrder)]))
        .get();
  }

  Future<void> setThumbnailFields(
    String templateId,
    List<TemplateThumbnailFieldsCompanion> fields,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(_db.templateThumbnailFields)
            ..where((f) => f.templateId.equals(templateId)))
          .go();
      for (final f in fields) {
        await _db.into(_db.templateThumbnailFields).insert(f);
      }
    });
  }

  Future<List<TemplateDimension>> getRefSubtemplateDimensions(String templateId) async {
    return (_db.select(_db.templateDimensions)
          ..where((d) => d.templateId.equals(templateId) & d.type.equals('ref_subtemplate'))
          ..orderBy([(d) => OrderingTerm(expression: d.sortOrder)]))
        .get();
  }

  Future<Map<String, String>> getThumbnailValues(String instanceId, String templateId) async {
    final query = _db.customSelect(
      '''
      SELECT d.name, v.value
      FROM template_thumbnail_fields f
      INNER JOIN template_dimensions d ON f.dimension_id = d.id
      LEFT JOIN instance_values v ON v.dimension_id = d.id AND v.instance_id = ?
      WHERE f.template_id = ?
      ORDER BY f.sort_order
      ''',
      variables: [Variable(instanceId), Variable(templateId)],
    );
    final rows = await query.get();
    return {
      for (final row in rows)
        if (row.read<String?>('value') != null) row.read<String>('name'): row.read<String>('value'),
    };
  }
}
