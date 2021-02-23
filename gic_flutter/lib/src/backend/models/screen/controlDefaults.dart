import 'dart:convert';

import 'package:gic_flutter/src/backend/models/screen/gicControl.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This is used to store / save default control values
/// such as backgrounds, sizing, fonts, etc
class ControlDefaults {
  final String _imageDefaults = "_image_defaults";
  final String _buttonDefaults = "_button_defaults";
  final String _textDefaults = "_text_defaults";
  final String _switchDefaults = "_switch_defaults";

  ControlViewModel defaultImage;
  ControlViewModel defaultButton;
  ControlViewModel defaultText;
  ControlViewModel defaultToggle;

  SharedPreferences _prefs;

  ControlDefaults(this._prefs, int screenId) {
    defaultImage = ControlViewModel.fromLegacyModel(loadControl("$screenId$_imageDefaults"));
    defaultButton = ControlViewModel.fromLegacyModel(loadControl("$screenId$_buttonDefaults"));
    defaultText = ControlViewModel.fromLegacyModel(loadControl("$screenId$_textDefaults"));
    defaultToggle = ControlViewModel.fromLegacyModel(loadControl("$screenId$_switchDefaults"));
  }

  GicControl loadControl(String preference) {
    if (!_prefs.containsKey(preference)) {
        return new GicControl.empty();
    } else {
      Map controlMap = jsonDecode(_prefs.getString(preference));
      return GicControl.fromJson(controlMap);
    }
  }
}