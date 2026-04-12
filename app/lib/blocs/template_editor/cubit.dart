import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/database.dart';
import '../../data/tables.dart';
import '../../data/template_repository.dart';
import '../../models/dimension_node.dart';
import 'state.dart';

export 'state.dart';

class TemplateEditorCubit extends Cubit<TemplateEditorState> {
  final TemplateRepository? _repo;
  String? _templateId;

  TemplateEditorCubit([this._repo]) : super(const TemplateEditorState());

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
      final updated = moved.copyWith(parentId: targetParentId);
      emit(state.copyWith(dimensions: _insertIntoParent(removed, targetParentId, updated)));
    } else {
      final targetNode = newIndex < flat.length ? flat[newIndex] : null;
      final updated = targetNode != null
          ? moved.copyWith(parentId: targetNode.parentId)
          : moved.copyWith(parentId: null);
      emit(state.copyWith(dimensions: _insertAtRoot(removed, newIndex, updated)));
    }
  }

  Future<void> loadTemplate(String id) async {
    if (_repo == null) return;
    final data = await _repo!.getTemplateById(id);
    if (data == null) return;
    _templateId = id;
    emit(state.copyWith(
      templateName: data.template.name,
      dimensions: _buildTree(data.dimensions),
    ));
  }

  Future<void> saveTemplate() async {
    if (_repo == null) return;
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
    final companions = flat.asMap().entries.map((e) {
      final d = e.value;
      return TemplateDimensionsCompanion.insert(
        id: d.id,
        templateId: id,
        parentId: d.parentId == null ? const Value.absent() : Value(d.parentId!),
        name: d.name,
        type: d.type,
        config: d.config,
        sortOrder: e.key,
      );
    }).toList();
    if (_templateId != null) {
      await _repo!.updateTemplate(template, companions);
    } else {
      await _repo!.insertTemplate(template, companions);
      _templateId = id;
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

  List<DimensionNode> _insertAtRoot(List<DimensionNode> nodes, int index, DimensionNode item) {
    final list = nodes.toList();
    if (index >= list.length) {
      list.add(item);
    } else {
      list.insert(index, item);
    }
    return list;
  }
}
