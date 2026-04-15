import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/instance_editor/cubit.dart';

void main() {
  group('InstanceEditorCubit', () {
    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'sets instance name',
      build: () => InstanceEditorCubit(),
      act: (cubit) => cubit.setName('Test'),
      expect: () => [const InstanceEditorState(name: 'Test')],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'hides dimension',
      build: () => InstanceEditorCubit(),
      seed: () => const InstanceEditorState(
        dimensionValues: {'d1': 'v1'},
        hiddenDimensionIds: {},
      ),
      act: (cubit) => cubit.hideDimension('d1'),
      expect: () => [
        const InstanceEditorState(
          name: '',
          dimensionValues: {'d1': 'v1'},
          hiddenDimensionIds: {'d1'},
        ),
      ],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'adds custom field',
      build: () => InstanceEditorCubit(),
      seed: () => const InstanceEditorState(customFields: []),
      act: (cubit) => cubit.addCustomField('Field1', 'text'),
      expect: () => [
        isA<InstanceEditorState>().having(
          (s) => s.customFields.length,
          'customFields length',
          1,
        ).having(
          (s) => s.customFields.first.name,
          'customFields first name',
          'Field1',
        ),
      ],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'updates custom field',
      build: () => InstanceEditorCubit(),
      seed: () {
        const field = CustomFieldData(
          id: 'cf1',
          name: 'Field1',
          type: 'text',
          value: 'old',
          config: '{}',
        );
        return const InstanceEditorState(customFields: [field]);
      },
      act: (cubit) => cubit.updateCustomField('cf1', name: 'Updated', value: 'new'),
      expect: () => [
        isA<InstanceEditorState>().having(
          (s) => s.customFields.first.name,
          'name',
          'Updated',
        ).having(
          (s) => s.customFields.first.value,
          'value',
          'new',
        ),
      ],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'removes custom field',
      build: () => InstanceEditorCubit(),
      seed: () {
        const field = CustomFieldData(
          id: 'cf1',
          name: 'Field1',
          type: 'text',
          value: '',
          config: '{}',
        );
        return const InstanceEditorState(customFields: [field]);
      },
      act: (cubit) => cubit.removeCustomField('cf1'),
      expect: () => [const InstanceEditorState(customFields: [])],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'restores dimension',
      build: () => InstanceEditorCubit(),
      seed: () => const InstanceEditorState(hiddenDimensionIds: {'d1'}),
      act: (cubit) => cubit.restoreDimension('d1'),
      expect: () => [const InstanceEditorState(hiddenDimensionIds: {})],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'updates dimension value',
      build: () => InstanceEditorCubit(),
      seed: () => const InstanceEditorState(dimensionValues: {'d1': ''}),
      act: (cubit) => cubit.updateDimensionValue('d1', 'v1'),
      expect: () => [
        const InstanceEditorState(dimensionValues: {'d1': 'v1'}),
      ],
    );
  });
}
