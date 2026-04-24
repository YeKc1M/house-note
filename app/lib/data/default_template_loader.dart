import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';
import 'database.dart';
import 'template_repository.dart';

class DefaultTemplateLoader {
  final AppDatabase _db;
  final TemplateRepository _repo;

  DefaultTemplateLoader(this._db) : _repo = TemplateRepository(_db);

  Future<void> loadIfNeeded() async {
    final existing = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals('default_templates_initialized')))
        .getSingleOrNull();
    if (existing != null) return;

    await _loadAndInsert();

    await _db.into(_db.appSettings).insert(
          AppSettingsCompanion.insert(
            key: 'default_templates_initialized',
            value: 'true',
          ),
        );
  }

  Future<int> restoreDefaults() async {
    return _loadAndInsert(skipExisting: true);
  }

  Future<int> _loadAndInsert({bool skipExisting = false}) async {
    final yamlString = await rootBundle.loadString('assets/default_templates.yaml');
    final doc = loadYaml(yamlString) as YamlMap;
    final templatesList = doc['templates'] as YamlList;

    // First pass: map YAML ids to generated UUIDs
    final yamlIdToUuid = <String, String>{};
    final templateDefs = <_TemplateDef>[];

    for (final item in templatesList) {
      final map = item as YamlMap;
      final yamlId = map['id'] as String;
      final name = map['name'] as String;
      yamlIdToUuid[yamlId] = const Uuid().v4();
      templateDefs.add(_TemplateDef(
        yamlId: yamlId,
        name: name,
        dimensions: map['dimensions'] as YamlList,
      ));
    }

    // Check existing templates by name if restoring
    final existingNames = <String>{};
    if (skipExisting) {
      final allTemplates = await _db.select(_db.templates).get();
      existingNames.addAll(allTemplates.map((t) => t.name));
    }

    int createdCount = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final def in templateDefs) {
      if (skipExisting && existingNames.contains(def.name)) continue;

      final templateId = yamlIdToUuid[def.yamlId]!;
      final template = TemplatesCompanion.insert(
        id: templateId,
        name: def.name,
        createdAt: now,
        updatedAt: now,
      );

      final dimensions = <TemplateDimensionsCompanion>[];
      for (var i = 0; i < def.dimensions.length; i++) {
        final dim = def.dimensions[i] as YamlMap;
        final type = dim['type'] as String;
        String config = '{}';

        if (type == 'single_choice') {
          final options = (dim['options'] as YamlList).cast<String>().toList();
          config = jsonEncode({'options': options});
        } else if (type == 'ref_subtemplate') {
          final refId = dim['ref_template_id'] as String;
          final resolvedUuid = yamlIdToUuid[refId]!;
          config = jsonEncode({'ref_template_id': resolvedUuid});
        }

        dimensions.add(TemplateDimensionsCompanion.insert(
          id: const Uuid().v4(),
          templateId: templateId,
          name: dim['name'] as String,
          type: type,
          config: config,
          sortOrder: i,
        ));
      }

      await _repo.insertTemplate(template, dimensions);
      createdCount++;
    }

    return createdCount;
  }
}

class _TemplateDef {
  final String yamlId;
  final String name;
  final YamlList dimensions;

  _TemplateDef({required this.yamlId, required this.name, required this.dimensions});
}
