import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/gicControl.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This is used to store / save default control values
/// such as backgrounds, sizing, fonts, etc
class ControlDefaults {
  final String _imageDefaults = "_image_defaults";
  final String _buttonDefaults = "_button_defaults";
  final String _textDefaults = "_text_defaults";
  final String _toggleDefaults = "_switch_defaults";

  ControlViewModel defaultImage = ControlViewModel();
  ControlViewModel defaultButton = ControlViewModel();
  ControlViewModel defaultText = ControlViewModel();
  ControlViewModel defaultToggle = ControlViewModel();

  SharedPreferences _prefs;

  ControlDefaults(this._prefs, int? screenId) {
    if (this._prefs.containsKey("v2$screenId$_imageDefaults")) {
      Map<String, dynamic> imageControlMap =
          jsonDecode(_prefs.getString("v2$screenId$_imageDefaults") ?? "");
      defaultImage = ControlViewModel.fromJson(imageControlMap);

      Map<String, dynamic> buttonControlMap =
          jsonDecode(_prefs.getString("v2$screenId$_buttonDefaults") ?? "");
      defaultButton = ControlViewModel.fromJson(buttonControlMap);

      Map<String, dynamic> textControlMap =
          jsonDecode(_prefs.getString("v2$screenId$_textDefaults") ?? "");
      defaultText = ControlViewModel.fromJson(textControlMap);

      Map<String, dynamic> toggleControlMap =
          jsonDecode(_prefs.getString("v2$screenId$_toggleDefaults") ?? "");
      defaultToggle = ControlViewModel.fromJson(toggleControlMap);
    } else if (_prefs.containsKey("$screenId$_imageDefaults")) {
      try {
        defaultImage = ControlViewModel.fromLegacyModel(
            loadControl("$screenId$_imageDefaults"));
        defaultButton = ControlViewModel.fromLegacyModel(
            loadControl("$screenId$_buttonDefaults"));
        defaultText = ControlViewModel.fromLegacyModel(
            loadControl("$screenId$_textDefaults"));
        defaultToggle = ControlViewModel.fromLegacyModel(
            loadControl("$screenId$_toggleDefaults"));
      } catch (ex) {
        print(ex);
      }
    }

    //if nothing was loaded in
    if (defaultImage.type != ControlViewModelType.Image) {
      defaultImage.type = ControlViewModelType.Image;
      defaultImage.images = [];
      defaultButton.type = ControlViewModelType.Button;
      defaultButton.design = ControlDesignType.Image;
      defaultButton.images = [];
      defaultButton.colors = [];
      defaultButton.colors.add(Colors.blue);
      defaultButton.colors.add(Colors.black);
      defaultButton.images.add("button_black");
      defaultButton.images.add("button_black2");
      defaultText.type = ControlViewModelType.Text;
      defaultToggle.type = ControlViewModelType.Toggle;
      defaultToggle.images = [];
      defaultToggle.images.add("toggle_off");
      defaultToggle.images.add("toggle_on");
      defaultToggle.colors = [];
      defaultToggle.colors.add(Colors.blue);
      defaultToggle.colors.add(Colors.black);
    }
  }

  GicControl loadControl(String preference) {
    if (!_prefs.containsKey(preference)) {
      return GicControl.empty();
    } else {
      Map<String, dynamic> controlMap = jsonDecode(_prefs.getString(preference) ?? "");
      return GicControl.fromJson(controlMap);
    }
  }

  bool saveDefaults(int screenId) {
    try {
      _prefs.setString(
          "v2$screenId$_imageDefaults", jsonEncode(defaultImage.toJson()));
      _prefs.setString(
          "v2$screenId$_buttonDefaults", jsonEncode(defaultButton.toJson()));
      _prefs.setString(
          "v2$screenId$_textDefaults", jsonEncode(defaultText.toJson()));
      _prefs.setString(
          "v2$screenId$_toggleDefaults", jsonEncode(defaultToggle.toJson()));
      return true;
    } catch (_) {
      return false;
    }
  }
}
