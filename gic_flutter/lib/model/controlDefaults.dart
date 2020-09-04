import 'dart:convert';

import 'package:gic_flutter/model/screen/gicControl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This is used to store / save default control values
/// such as backgrounds, sizing, fonts, etc
class ControlDefaults {
  final String _imageDefaults = "_image_defaults";
  final String _buttonDefaults = "_button_defaults";
  final String _textDefaults = "_text_defaults";
  final String _switchDefaults = "_switch_defaults";

  GicControl defaultImage;
  GicControl defaultButton;
  GicControl defaultText;
  GicControl defaultSwitch;

  SharedPreferences _prefs;

  ControlDefaults(this._prefs, int screenId) {
    defaultImage = loadControl("$screenId$_imageDefaults");
    defaultButton = loadControl("$screenId$_buttonDefaults");
    defaultText = loadControl("$screenId$_textDefaults");
    defaultSwitch = loadControl("$screenId$_switchDefaults");
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