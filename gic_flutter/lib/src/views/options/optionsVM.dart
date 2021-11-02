import 'dart:core';

import 'package:gic_flutter/src/backend/models/viewModel.dart';
import 'package:gic_flutter/src/backend/models/viewSection.dart';

class OptionsVM implements ViewModel {
  String _toolbarTitle = "";
  String darkModeTitle = "";
  String darkModelText = "";
  String _soundTitle = "";
  String _soundText = "";
  String _vibrationTitle = "";
  String _vibrationText = "";

  bool _sound = false;
  bool _haptics = false;
  bool _darkMode = true;

  String get toolbarTitle => _toolbarTitle;
  String get soundTitle => _soundTitle;
  String get soundText => _soundText;
  String get vibrationTitle => _vibrationTitle;
  String get vibrationText => _vibrationText;

  bool get darkMode => _darkMode;
  bool get vibration => _haptics;
  bool get sound => _sound;

  set toolbarTitle(String toolbarTitle) {
    _toolbarTitle = toolbarTitle;
  }

  set darkMode(bool darkTheme) {
    _darkMode = darkTheme;
  }

  set vibration(bool haptics) {
    _haptics = haptics;
  }

  set sound(bool sound) {
    _sound = sound;
  }

  set soundTitle(String soundTitle) {
    _soundTitle = soundTitle;
  }

  set soundText(String soundText) {
    _soundText = soundText;
  }
  set vibrationTitle(String vibrationTitle) {
    _vibrationTitle = vibrationTitle;
  }
  set vibrationText(String vibrationText) {
    _vibrationText = vibrationText;
  }
}

