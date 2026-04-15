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

    test('Equatable equality on DimensionNode', () {
      final a = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Node',
        type: 'text',
        children: const [],
      );
      final b = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Node',
        type: 'text',
        children: const [],
      );
      final c = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Other',
        type: 'text',
        children: const [],
      );
      expect(a, b);
      expect(a, isNot(c));
    });

    test('Equatable equality on FlattenedDimension', () {
      final node = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Node',
        type: 'text',
        children: const [],
      );
      final a = FlattenedDimension(node, 0);
      final b = FlattenedDimension(node, 0);
      final c = FlattenedDimension(node, 1);
      expect(a, b);
      expect(a, isNot(c));
    });

    test('multi-level flatten', () {
      final grandchild = DimensionNode(
        id: '3',
        templateId: 't1',
        name: 'Grandchild',
        type: 'text',
        parentId: '2',
        children: const [],
      );
      final child = DimensionNode(
        id: '2',
        templateId: 't1',
        name: 'Child',
        type: 'number',
        parentId: '1',
        children: [grandchild],
      );
      final root = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Root',
        type: 'group',
        children: [child],
      );
      final flat = root.flatten();
      expect(flat.length, 3);
      expect(flat[0].node.id, '1');
      expect(flat[0].depth, 0);
      expect(flat[1].node.id, '2');
      expect(flat[1].depth, 1);
      expect(flat[2].node.id, '3');
      expect(flat[2].depth, 2);
    });

    test('copyWith clears parentId to null', () {
      final node = DimensionNode(
        id: '2',
        templateId: 't1',
        name: 'Child',
        type: 'text',
        parentId: '1',
        children: const [],
      );
      final updated = node.copyWith(parentId: null);
      expect(updated.parentId, isNull);
      expect(updated.name, 'Child');
    });

    test('copyWith leaves unmentioned fields unchanged', () {
      final node = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Node',
        type: 'text',
        config: '{"key":"value"}',
        sortOrder: 5,
        children: const [],
      );
      final updated = node.copyWith();
      expect(updated.id, '1');
      expect(updated.templateId, 't1');
      expect(updated.parentId, isNull);
      expect(updated.name, 'Node');
      expect(updated.type, 'text');
      expect(updated.config, '{"key":"value"}');
      expect(updated.sortOrder, 5);
      expect(updated.children, isEmpty);
    });
  });
}
