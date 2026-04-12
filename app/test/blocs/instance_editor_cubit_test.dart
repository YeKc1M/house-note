import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/instance_editor/cubit.dart';
import 'package:mocktail/mocktail.dart';

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
  });
}
