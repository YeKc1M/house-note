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
      );
      final updated = node.copyWith(name: 'New');
      expect(updated.name, 'New');
      expect(updated.id, '1');
    });

    test('Equatable equality on DimensionNode', () {
      final a = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Node',
        type: 'text',
      );
      final b = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Node',
        type: 'text',
      );
      final c = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Other',
        type: 'text',
      );
      expect(a, b);
      expect(a, isNot(c));
    });

    test('copyWith leaves unmentioned fields unchanged', () {
      final node = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Node',
        type: 'text',
        config: '{"key":"value"}',
        sortOrder: 5,
      );
      final updated = node.copyWith();
      expect(updated.id, '1');
      expect(updated.templateId, 't1');
      expect(updated.name, 'Node');
      expect(updated.type, 'text');
      expect(updated.config, '{"key":"value"}');
      expect(updated.sortOrder, 5);
    });
  });
}
