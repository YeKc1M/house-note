import '../data/database.dart';
import '../models/dimension_node.dart';

List<DimensionNode> buildDimensionTree(List<TemplateDimension> dimensions) {
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
