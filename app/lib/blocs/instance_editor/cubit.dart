import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/database.dart';
import '../../data/instance_repository.dart';
import '../../data/template_repository.dart';
import '../../models/dimension_node.dart';
import 'state.dart';

export 'state.dart';

class InstanceEditorCubit extends Cubit<InstanceEditorState> {
  final InstanceRepository? _instanceRepo;
  final TemplateRepository? _templateRepo;
  String? _instanceId;

  InstanceEditorCubit([this._instanceRepo, this._templateRepo]) : super(const InstanceEditorState());

  void setName(String name) => emit(state.copyWith(name: name));

  void updateDimensionValue(String dimensionId, String value) {
    final updated = Map<String, String>.from(state.dimensionValues);
    updated[dimensionId] = value;
    emit(state.copyWith(dimensionValues: updated));
  }

  void hideDimension(String dimensionId) {
    emit(state.copyWith(hiddenDimensionIds: {...state.hiddenDimensionIds, dimensionId}));
  }

  void restoreDimension(String dimensionId) {
    emit(state.copyWith(hiddenDimensionIds: {
      ...state.hiddenDimensionIds.where((id) => id != dimensionId),
    }));
  }

  void addCustomField(String name, String type, {String value = '', String config = '{}'}) {
    final field = CustomFieldData(
      id: const Uuid().v4(),
      name: name,
      type: type,
      value: value,
      config: config,
    );
    emit(state.copyWith(customFields: [...state.customFields, field]));
  }

  void updateCustomField(String id, {String? name, String? value}) {
    emit(state.copyWith(customFields: state.customFields.map((f) {
      if (f.id == id) return f.copyWith(name: name, value: value);
      return f;
    }).toList()));
  }

  void removeCustomField(String id) {
    emit(state.copyWith(customFields: state.customFields.where((f) => f.id != id).toList()));
  }

  Future<void> initNewInstance(String templateId, {String? parentInstanceId}) async {
    if (_templateRepo == null) return;
    final template = await _templateRepo!.getTemplateById(templateId);
    if (template == null) return;
    final tree = _buildTree(template.dimensions);
    emit(InstanceEditorState(
      templateId: templateId,
      parentInstanceId: parentInstanceId,
      dimensions: tree,
      dimensionValues: {for (final d in template.dimensions) d.id: ''},
      hiddenDimensionIds: const {},
      customFields: const [],
    ));
  }

  Future<void> loadInstance(String instanceId) async {
    if (_instanceRepo == null || _templateRepo == null) return;
    final data = await _instanceRepo!.getInstanceById(instanceId);
    if (data == null) return;
    final template = await _templateRepo!.getTemplateById(data.instance.templateId);
    final tree = template != null ? _buildTree(template.dimensions) : <DimensionNode>[];
    final values = {for (final v in data.values) v.dimensionId: v.value};
    final hidden = data.hiddenDimensions.map((h) => h.dimensionId).toSet();
    final custom = data.customFields.map((f) => CustomFieldData(
      id: f.id,
      name: f.name,
      type: f.type,
      value: f.value,
      config: f.config,
    )).toList();
    _instanceId = instanceId;
    emit(InstanceEditorState(
      name: data.instance.name,
      templateId: data.instance.templateId,
      parentInstanceId: data.instance.parentInstanceId,
      dimensions: tree,
      dimensionValues: {for (final d in template?.dimensions ?? []) d.id: values[d.id] ?? ''},
      hiddenDimensionIds: hidden,
      customFields: custom,
    ));
  }

  Future<void> saveInstance() async {
    if (_instanceRepo == null) return;
    final id = _instanceId ?? const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final instance = InstancesCompanion(
      id: Value(id),
      templateId: Value(state.templateId!),
      parentInstanceId: state.parentInstanceId == null
          ? const Value.absent()
          : Value(state.parentInstanceId!),
      name: Value(state.name),
      createdAt: _instanceId != null ? const Value.absent() : Value(now),
      updatedAt: Value(now),
    );
    final values = state.dimensionValues.entries.map((e) {
      return InstanceValuesCompanion(
        id: Value(const Uuid().v4()),
        instanceId: Value(id),
        dimensionId: Value(e.key),
        value: Value(e.value),
      );
    }).toList();
    final customFields = state.customFields.map((f) {
      return InstanceCustomFieldsCompanion(
        id: Value(f.id),
        instanceId: Value(id),
        name: Value(f.name),
        type: Value(f.type),
        value: Value(f.value),
        config: Value(f.config),
      );
    }).toList();
    final hidden = state.hiddenDimensionIds.map((hid) {
      return InstanceHiddenDimensionsCompanion(
        id: Value(const Uuid().v4()),
        instanceId: Value(id),
        dimensionId: Value(hid),
      );
    }).toSet();

    if (_instanceId != null) {
      await _instanceRepo!.updateInstance(
        instance,
        values: values,
        customFields: customFields,
        hiddenDimensions: hidden.toList(),
      );
    } else {
      await _instanceRepo!.insertInstance(
        instance,
        values: values,
        customFields: customFields,
        hiddenDimensions: hidden.toList(),
      );
      _instanceId = id;
    }
  }

  List<DimensionNode> _buildTree(List<TemplateDimension> dimensions) {
    final map = <String, DimensionNode>{};
    final roots = <DimensionNode>[];
    for (final d in dimensions) {
      map[d.id] = DimensionNode(
        id: d.id,
        templateId: d.templateId,
        parentId: d.parentId,
        name: d.name,
        type: d.type,
        config: d.config,
        sortOrder: d.sortOrder,
      );
    }
    for (final d in dimensions) {
      final node = map[d.id]!;
      if (d.parentId == null) {
        roots.add(node);
      } else {
        final parent = map[d.parentId];
        if (parent != null) {
          map[d.parentId!] = parent.copyWith(children: [...parent.children, node]);
        }
      }
    }
    return roots;
  }
}
