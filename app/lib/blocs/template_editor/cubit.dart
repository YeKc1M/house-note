import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/database.dart';
import '../../data/template_repository.dart';
import '../../models/dimension_node.dart';
import '../../utils/dimension_tree_builder.dart';
import 'state.dart';

export 'state.dart';

class TemplateEditorCubit extends Cubit<TemplateEditorState> {
  final TemplateRepository _repo;
  String? _templateId;

  TemplateEditorCubit(this._repo) : super(const TemplateEditorState());

  void setTemplateName(String name) {
    emit(state.copyWith(templateName: name));
  }

  void addDimension({required String name, required String type, String config = '{}', String? parentId}) {
    final node = DimensionNode(
      id: const Uuid().v4(),
      templateId: _templateId ?? '',
      parentId: parentId,
      name: name,
      type: type,
      config: config,
      sortOrder: state.dimensions.length,
    );
    if (parentId == null) {
      emit(state.copyWith(dimensions: [...state.dimensions, node]));
    } else {
      emit(state.copyWith(dimensions: _insertIntoParent(state.dimensions, parentId, node)));
    }
  }

  void updateDimension(String id, {String? name, String? type, String? config}) {
    emit(state.copyWith(dimensions: _updateInTree(state.dimensions, id, name: name, type: type, config: config)));
  }

  void removeDimension(String id) {
    emit(state.copyWith(dimensions: _removeFromTree(state.dimensions, id)));
  }

  void moveDimension({required int oldIndex, required int newIndex, String? targetParentId}) {
    final flat = _flatten(state.dimensions);
    if (oldIndex < 0 || oldIndex >= flat.length) return;
    final moved = flat[oldIndex];
    final removed = _removeFromTree(state.dimensions, moved.id);

    if (targetParentId != null) {
      final targetNode = removed.expand((n) => n.flatten()).map((f) => f.node).firstWhere((n) => n.id == targetParentId);
      final actualIndex = newIndex.clamp(0, targetNode.children.length);
      final updated = moved.copyWith(parentId: targetParentId);
      final newTree = _insertIntoParentAtIndex(removed, targetParentId, actualIndex, updated);
      emit(state.copyWith(dimensions: newTree));
    } else {
      final actualIndex = newIndex.clamp(0, removed.length);
      final updated = moved.copyWith(parentId: null);
      final list = removed.toList();
      list.insert(actualIndex, updated);
      emit(state.copyWith(dimensions: list));
    }
  }

  Future<void> loadTemplate(String id) async {
    final data = await _repo.getTemplateById(id);
    if (data == null) return;
    _templateId = id;
    emit(state.copyWith(
      templateName: data.template.name,
      dimensions: buildDimensionTree(data.dimensions),
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
    final flat = _flatten(state.dimensions);
    final parentCounters = <String?, int>{};
    final companions = <TemplateDimensionsCompanion>[];
    for (final d in flat) {
      final parentId = d.parentId;
      final sortOrder = parentCounters[parentId] ?? 0;
      parentCounters[parentId] = sortOrder + 1;
      companions.add(TemplateDimensionsCompanion.insert(
        id: d.id,
        templateId: id,
        parentId: parentId == null ? const Value.absent() : Value(parentId),
        name: d.name,
        type: d.type,
        config: d.config,
        sortOrder: sortOrder,
      ));
    }
    if (_templateId != null) {
      await _repo.updateTemplate(template, companions);
    } else {
      await _repo.insertTemplate(template, companions);
      _templateId = id;
    }
  }

  List<DimensionNode> _flatten(List<DimensionNode> nodes) {
    final result = <DimensionNode>[];
    for (final n in nodes) {
      result.add(n);
      result.addAll(_flatten(n.children));
    }
    return result;
  }

  List<DimensionNode> _insertIntoParent(List<DimensionNode> nodes, String parentId, DimensionNode child) {
    return nodes.map((n) {
      if (n.id == parentId) {
        return n.copyWith(children: [...n.children, child]);
      } else if (n.children.isNotEmpty) {
        return n.copyWith(children: _insertIntoParent(n.children, parentId, child));
      }
      return n;
    }).toList();
  }

  List<DimensionNode> _insertIntoParentAtIndex(List<DimensionNode> nodes, String parentId, int index, DimensionNode child) {
    return nodes.map((n) {
      if (n.id == parentId) {
        final children = n.children.toList();
        children.insert(index.clamp(0, children.length), child);
        return n.copyWith(children: children);
      } else if (n.children.isNotEmpty) {
        return n.copyWith(children: _insertIntoParentAtIndex(n.children, parentId, index, child));
      }
      return n;
    }).toList();
  }

  List<DimensionNode> _updateInTree(List<DimensionNode> nodes, String id, {String? name, String? type, String? config}) {
    return nodes.map((n) {
      if (n.id == id) {
        return n.copyWith(name: name, type: type, config: config);
      } else if (n.children.isNotEmpty) {
        return n.copyWith(children: _updateInTree(n.children, id, name: name, type: type, config: config));
      }
      return n;
    }).toList();
  }

  List<DimensionNode> _removeFromTree(List<DimensionNode> nodes, String id) {
    return nodes.where((n) => n.id != id).map((n) {
      if (n.children.isNotEmpty) {
        return n.copyWith(children: _removeFromTree(n.children, id));
      }
      return n;
    }).toList();
  }
}
