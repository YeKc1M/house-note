import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/database.dart';
import '../../data/instance_repository.dart';
import '../../data/template_repository.dart';
import 'state.dart';

export 'state.dart';

class InstanceListCubit extends Cubit<InstanceListState> {
  final InstanceRepository _repo;
  final TemplateRepository _templateRepo;
  StreamSubscription<InstanceListState>? _sub;

  InstanceListCubit(this._repo, this._templateRepo) : super(const InstanceListState());

  void loadTopLevel() {
    _sub?.cancel();
    _sub = _repo.watchTopLevelInstances().asyncMap((instances) async {
      final thumbs = await _loadThumbnails(instances);
      return InstanceListState(instances: instances, breadcrumbs: const [], thumbnailValues: thumbs);
    }).listen(emit);
  }

  void loadChildren(String parentInstanceId, List<Breadcrumb> breadcrumbs) {
    _sub?.cancel();
    _sub = _repo.watchChildInstances(parentInstanceId).asyncMap((instances) async {
      final thumbs = await _loadThumbnails(instances);
      return InstanceListState(instances: instances, breadcrumbs: breadcrumbs, thumbnailValues: thumbs);
    }).listen(emit);
  }

  void navigateToBreadcrumb(int index) {
    if (index < 0) {
      loadTopLevel();
    } else {
      final target = state.breadcrumbs[index];
      loadChildren(target.id, state.breadcrumbs.sublist(0, index + 1));
    }
  }

  Future<Map<String, Map<String, String>>> _loadThumbnails(List<Instance> instances) async {
    final result = <String, Map<String, String>>{};
    for (final inst in instances) {
      final thumbs = await _templateRepo.getThumbnailValues(inst.id, inst.templateId);
      result[inst.id] = thumbs;
    }
    return result;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
