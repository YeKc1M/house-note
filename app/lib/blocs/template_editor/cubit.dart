import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/database.dart';
import '../../data/template_repository.dart';
import '../../models/dimension_node.dart';
import 'state.dart';

export 'state.dart';

class TemplateEditorCubit extends Cubit<TemplateEditorState> {
  final TemplateRepository _repo;
  String? _templateId;

  TemplateEditorCubit(this._repo) : super(const TemplateEditorState());

  Future<List<Template>> getAllTemplates() => _repo.watchAllTemplates().first;

  String? get currentTemplateId => _templateId;

  void setTemplateName(String name) {
    emit(state.copyWith(templateName: name));
  }

  void addDimension({required String name, required String type, String config = '{}'}) {
    final node = DimensionNode(
      id: const Uuid().v4(),
      templateId: _templateId ?? '',
      name: name,
      type: type,
      config: config,
      sortOrder: state.dimensions.length,
    );
    emit(state.copyWith(dimensions: [...state.dimensions, node]));
  }

  void updateDimension(String id, {String? name, String? type, String? config}) {
    emit(state.copyWith(
      dimensions: state.dimensions.map((n) {
        if (n.id == id) {
          return n.copyWith(name: name, type: type, config: config);
        }
        return n;
      }).toList(),
    ));
  }

  void removeDimension(String id) {
    emit(state.copyWith(
      dimensions: state.dimensions.where((n) => n.id != id).toList(),
    ));
  }

  void moveDimension({required int oldIndex, required int newIndex}) {
    final list = state.dimensions.toList();
    if (oldIndex < 0 || oldIndex >= list.length) return;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex.clamp(0, list.length), item);
    emit(state.copyWith(dimensions: list));
  }

  Future<void> loadTemplate(String id) async {
    final data = await _repo.getTemplateById(id);
    if (data == null) return;
    _templateId = id;
    final thumbnailFields = await _repo.getThumbnailFields(id);
    final thumbnailIds = thumbnailFields.map((f) => f.dimensionId).toList();
    emit(state.copyWith(
      templateName: data.template.name,
      dimensions: data.dimensions.map((d) => DimensionNode(
        id: d.id,
        templateId: d.templateId,
        name: d.name,
        type: d.type,
        config: d.config,
        sortOrder: d.sortOrder,
      )).toList(),
      thumbnailDimensionIds: thumbnailIds,
    ));
  }

  Future<void> saveTemplate() async {
    final id = _templateId ?? const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final template = _templateId != null
        ? TemplatesCompanion(
            id: Value(id),
            name: Value(state.templateName),
            updatedAt: Value(now),
          )
        : TemplatesCompanion.insert(
            id: id,
            name: state.templateName,
            createdAt: now,
            updatedAt: now,
          );
    final companions = state.dimensions.asMap().entries.map((e) {
      return TemplateDimensionsCompanion.insert(
        id: e.value.id,
        templateId: id,
        name: e.value.name,
        type: e.value.type,
        config: e.value.config,
        sortOrder: e.key,
      );
    }).toList();
    final thumbnailCompanions = state.thumbnailDimensionIds.asMap().entries.map((e) {
      return TemplateThumbnailFieldsCompanion.insert(
        id: const Uuid().v4(),
        templateId: id,
        dimensionId: e.value,
        sortOrder: e.key,
      );
    }).toList();
    await _repo.setThumbnailFields(id, thumbnailCompanions);
    if (_templateId != null) {
      await _repo.updateTemplate(template, companions);
    } else {
      await _repo.insertTemplate(template, companions);
      _templateId = id;
    }
  }

  void toggleThumbnailDimension(String dimensionId) {
    final current = state.thumbnailDimensionIds;
    if (current.contains(dimensionId)) {
      emit(state.copyWith(
        thumbnailDimensionIds: current.where((id) => id != dimensionId).toList(),
      ));
    } else {
      emit(state.copyWith(
        thumbnailDimensionIds: [...current, dimensionId],
      ));
    }
  }

  void reorderThumbnailDimensions(int oldIndex, int newIndex) {
    final list = state.thumbnailDimensionIds.toList();
    if (oldIndex < 0 || oldIndex >= list.length) return;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex.clamp(0, list.length), item);
    emit(state.copyWith(thumbnailDimensionIds: list));
  }
}
