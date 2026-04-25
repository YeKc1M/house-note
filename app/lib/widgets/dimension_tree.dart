import 'package:flutter/material.dart';
import '../models/dimension_node.dart';
import '../utils/tutorial_keys.dart';

class DimensionTree extends StatelessWidget {
  final List<DimensionNode> nodes;
  final void Function(DimensionNode) onEdit;
  final void Function(String) onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Set<String> thumbnailDimensionIds;
  final void Function(String) onToggleThumbnail;

  const DimensionTree({
    super.key,
    required this.nodes,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
    this.thumbnailDimensionIds = const {},
    required this.onToggleThumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: nodes.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        onReorder(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final node = nodes[index];
        return ListTile(
          key: ValueKey(node.id),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: const Icon(Icons.drag_handle),
          title: Text('${node.name} (${node.type})'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: TutorialKeys.visibilityIcon(node.id),
                icon: Icon(
                  thumbnailDimensionIds.contains(node.id)
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                tooltip: '缩略图显示',
                onPressed: () => onToggleThumbnail(node.id),
              ),
              IconButton(icon: const Icon(Icons.edit), onPressed: () => onEdit(node)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => onDelete(node.id)),
            ],
          ),
        );
      },
    );
  }
}
