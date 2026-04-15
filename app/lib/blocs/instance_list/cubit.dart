import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/database.dart';
import '../../data/instance_repository.dart';
import 'state.dart';

export 'state.dart';

class InstanceListCubit extends Cubit<InstanceListState> {
  final InstanceRepository _repo;
  StreamSubscription<List<Instance>>? _sub;

  InstanceListCubit(this._repo) : super(const InstanceListState());

  void loadTopLevel() {
    _sub?.cancel();
    _sub = _repo.watchTopLevelInstances().listen((instances) {
      emit(InstanceListState(instances: instances, breadcrumbs: const []));
    });
  }

  void loadChildren(String parentInstanceId, List<Breadcrumb> breadcrumbs) async {
    _sub?.cancel();
    _sub = _repo.watchChildInstances(parentInstanceId).listen((instances) {
      emit(InstanceListState(instances: instances, breadcrumbs: breadcrumbs));
    });
  }

  void navigateToBreadcrumb(int index) {
    if (index < 0) {
      loadTopLevel();
    } else {
      final target = state.breadcrumbs[index];
      loadChildren(target.id, state.breadcrumbs.sublist(0, index + 1));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
