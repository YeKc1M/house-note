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
      await _db.update(_db.templates).replace(template);
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
    final query = _db.select(_db.instances)
      ..where((i) => i.templateId.equals(templateId));
    return query.get().then((rows) => rows.length);
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
}
