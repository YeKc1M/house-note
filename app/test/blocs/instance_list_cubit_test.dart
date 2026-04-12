import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/instance_list/cubit.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/instance_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockInstanceRepository extends Mock implements InstanceRepository {}

void main() {
  late MockInstanceRepository repo;

  setUp(() => repo = MockInstanceRepository());

  blocTest<InstanceListCubit, InstanceListState>(
    'loads top-level instances',
    build: () => InstanceListCubit(repo),
    act: (cubit) {
      when(() => repo.watchTopLevelInstances()).thenAnswer(
        (_) => Stream.value([
          Instance(id: 'i1', templateId: 't1', name: 'A', createdAt: 1, updatedAt: 1),
        ]),
      );
      cubit.loadTopLevel();
    },
    expect: () => [
      predicate<InstanceListState>((s) => s.instances.length == 1 && s.breadcrumbs.isEmpty),
    ],
  );
}
