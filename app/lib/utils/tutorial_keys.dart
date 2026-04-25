import 'package:flutter/widgets.dart';

class TutorialKeys {
  static final templateListFab = GlobalKey();
  static final instanceListFab = GlobalKey();
  static final templateNameField = GlobalKey();
  static final addDimensionButton = GlobalKey();
  static final templateSaveButton = GlobalKey();
  static final instanceSaveButton = GlobalKey();
  static final breadcrumbRoot = GlobalKey();
  static final settingsTutorialButton = GlobalKey();

  static final _instanceCardKeys = <String, GlobalKey>{};
  static final _visibilityIconKeys = <String, GlobalKey>{};

  static GlobalKey instanceCard(String id) =>
      _instanceCardKeys.putIfAbsent(id, () => GlobalKey(debugLabel: 'instance_card_$id'));
  static GlobalKey visibilityIcon(String dimensionId) =>
      _visibilityIconKeys.putIfAbsent(dimensionId, () => GlobalKey(debugLabel: 'visibility_$dimensionId'));
}
