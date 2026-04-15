import 'package:flutter/material.dart';
import '../models/dimension_node.dart';

class DimensionTree extends StatelessWidget {
  final List<DimensionNode> nodes;
  final void Function(DimensionNode) onEdit;
  final void Function(String) onDelete;
  final void Function(int oldIndex, int newIndex, String? targetParentId) onReorder;

  const DimensionTree({
    super.key,
    required this.nodes,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final flat = nodes.expand((n) => n.flatten()).toList();
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: flat.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final target = flat[newIndex];
        final targetParentId = target.node.type == 'group' ? target.node.id : target.node.parentId;
        onReorder(oldIndex, newIndex, targetParentId);
      },
      itemBuilder: (context, index) {
        final item = flat[index];
        return ListTile(
          key: ValueKey(item.node.id),
          contentPadding: EdgeInsets.only(left: 24.0 + item.depth * 24.0, right: 16.0),
          leading: const Icon(Icons.drag_handle),
          title: Text('${item.node.name} (${item.node.type})'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () => onEdit(item.node)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => onDelete(item.node.id)),
            ],
          ),
        );
      },
    );
  }
}
