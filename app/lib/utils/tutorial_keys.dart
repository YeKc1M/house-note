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

  static GlobalKey instanceCard(String id) =>
      GlobalKey(debugLabel: 'instance_card_$id');
  static GlobalKey visibilityIcon(String dimensionId) =>
      GlobalKey(debugLabel: 'visibility_$dimensionId');
}
