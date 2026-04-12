import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/models/dimension_node.dart';

void main() {
  group('DimensionNode', () {
    test('copyWith updates name', () {
      final node = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Old',
        type: 'text',
        children: const [],
      );
      final updated = node.copyWith(name: 'New');
      expect(updated.name, 'New');
      expect(updated.id, '1');
    });

    test('flatten returns DFS ordered list with depth', () {
      final child = DimensionNode(
        id: '2',
        templateId: 't1',
        name: 'Child',
        type: 'number',
        parentId: '1',
        children: const [],
      );
      final root = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Root',
        type: 'group',
        children: [child],
      );
      final flat = root.flatten();
      expect(flat.length, 2);
      expect(flat[0].node.id, '1');
      expect(flat[0].depth, 0);
      expect(flat[1].node.id, '2');
      expect(flat[1].depth, 1);
    });
  });
}
