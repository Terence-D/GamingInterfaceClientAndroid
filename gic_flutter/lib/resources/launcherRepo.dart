import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/model/screen/Screen.dart';
import 'package:gic_flutter/model/screen/ScreenRepository.dart';
import 'package:gic_flutter/views/main/mainVM.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LauncherRepo {
  SharedPreferences _prefs;

  static const String _prefNightMode = "nightMode";
  static const String _prefShowHints = "showHints"; //show the help page
  static const String _prefPassword = "password";
  static const String _prefPort = "port";
  static const String _prefAddress = "address";
  static const String _prefConvert = "legacyConvert";
  static const String _prefConvertB = "legacyConvertScreens"; //show the whole intro thing
  static const String _prefSelectedScreenId = "chosenId";
  static const String _prefDonate = "coffee";
  static const String _prefDonateStar = "star";

  Future<LauncherModel> fetch() async {
    _prefs = await SharedPreferences.getInstance();

    //this handles reading in legacy settings
    bool needToConvert = _prefs.getBool(_prefConvert) ?? true;
    if (needToConvert) {
      _prefs.setBool(_prefConvert, false);
      await _convertLegacy();
    }

    bool convertScreens = _prefs.getBool(_prefConvertB) ?? true;
    if (convertScreens) {
      _prefs.setBool(_prefConvertB, false);
      return await _convertLegacyScreens();
    } else {
      return await _loadVM();
    }
  }

  _loadVM() async {
    LauncherModel viewModel = new LauncherModel();

    //get encrypted password
    viewModel.password = await _getPassword();

    //load screens
    ScreenRepository screenRepo = new ScreenRepository();
    viewModel.screens = new List();
    LinkedHashMap _screenListMap = await screenRepo.getScreenList();
    if (_screenListMap != null && _screenListMap.length > 0) {
      _screenListMap.forEach((k, v) => viewModel.screens.add(new ScreenListItem(k, v)) );
    } else {
      Screen newScreen = new Screen();
      newScreen.screenId = 0;
      newScreen.name = "Empty Screen";
      screenRepo.save(newScreen);
      viewModel.screens.add(new ScreenListItem(newScreen.screenId, newScreen.name));
    }

    //get generic info
    viewModel.darkMode = _prefs.getBool(_prefNightMode) ?? true;
    viewModel.port = _prefs.getString(_prefPort) ?? "8091";
    viewModel.address = _prefs.getString(_prefAddress) ?? "192.168.x.x";

    //donation settings
    if (_prefs.containsKey(_prefDonate))
      viewModel.donate = _prefs.getBool(_prefDonate);
    else {
      viewModel.donate = false;
    }

    if (_prefs.containsKey(_prefDonateStar))
      viewModel.donateStar = _prefs.getBool(_prefDonateStar);
    else {
      viewModel.donateStar = false;
    }

    return viewModel;
  }

  _convertLegacyScreens() async {
    MethodChannel platform = new MethodChannel(Channel.channelUtil);
    try {
      platform.invokeMethod(Channel.actionUtilUpdateScreens);
    } on PlatformException catch (e) {
      print(e.message);
    }
    return _loadVM();
  }

  _convertLegacy() async {
    MethodChannel platform = new MethodChannel(Channel.channelUtil);
    try {
      final LinkedHashMap result = await platform.invokeMethod(Channel.actionUtilGetSettings);
      if (result != null && result.length > 0) {
        result.forEach((key, value) {
          switch (key) {
            case "NIGHT_MODE":
              _prefs.setBool(_prefNightMode, value);
              break;
            case "address":
              _prefs.setString(_prefAddress, value);
              break;
            case "port":
              _prefs.setString(_prefPort, value);
              break;
            case "password":
              _prefs.setString(_prefPassword, value);
              break;
            case "chosen_id":
              _prefs.setInt(_prefSelectedScreenId, value);
              break;
            case "seenHelp":
              _prefs.setBool(_prefShowHints, value);
              break;
          }
        });
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  //calls legacy code
  Future<String> _getPassword() async {
    String response = "";
    String encrypted = _prefs.getString(_prefPassword) ?? "";

    const platform = const MethodChannel(Channel.channelUtil);
    if (encrypted.isNotEmpty) {
      try {
        response = await platform.invokeMethod(Channel.actionUtilDecrypt, {"code": encrypted});
      } on PlatformException catch (_) {
        response = "";
      }
    }
    return response;
  }

//  Future<String> _encryptPassword(String password) async {
//    String response = "";
//
//    const platform = const MethodChannel(Channel.channelUtil);
//    if (password.isNotEmpty) {
//      try {
//        final String result = await platform.invokeMethod(Channel.actionUtilEncrypt, {"password": password});
//        response = result;
//      } on PlatformException catch (_) {
//        response = "";
//      }
//    }
//    return response;
//  }

//  bool _isNumeric(String str) {
//    if(str == null) {
//      return false;
//    }
//    return double.tryParse(str) != null;
//  }

//  saveMainSettings(String address, String port, String password, int screenId) async {
//    if (address != null && port.isNotEmpty) {
//      _viewModel.address = address;
//      _prefs.setString(_prefAddress, address);
//    }
//    if (port != null && port.isNotEmpty && _isNumeric(port)) {
//      _viewModel.port = port;
//      _prefs.setString(_prefPort, port);
//    }
//    if (password != null && password.isNotEmpty) {
//      _viewModel.password = password;
//      _prefs.setString(_prefPassword, await _encryptPassword());
//    }
//    _prefs.setInt(_prefSelectedScreenId, screenId);
//  }
//
//  setDarkMode(bool newValue) {
//    _viewModel.darkMode = newValue;
//    _prefs.setBool(_prefNightMode, newValue);
//    const platform = const MethodChannel(Channel.channelUtil);
//    try {
//      platform.invokeMethod(Channel.actionUtilUpdateDarkMode, {"darkMode": newValue});
//      } on PlatformException catch (e) {
//    }
//  }

}
