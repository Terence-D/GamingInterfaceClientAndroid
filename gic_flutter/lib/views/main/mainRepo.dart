import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/screen/Screen.dart';
import 'package:gic_flutter/model/screen/ScreenRepository.dart';
import 'package:gic_flutter/views/main/mainVM.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MainRepoContract {
  void preferencesLoaded(MainVM viewModel); 
}

class MainRepo implements MainVMRepo {
  SharedPreferences _prefs;
  MainRepoContract _mainContract;
  MainVM _viewModel;

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

  MainRepo(MainRepoContract loader) {
    _mainContract = loader;
  }

  @override
  fetch() {
    SharedPreferences.getInstance().then((shared) {
      _prefs = shared;
      _loadSettings();
    });
  }

  _loadSettings() async {
    _prefs.reload();
    //this handles reading in legacy settings
    bool needToConvert = _prefs.getBool(_prefConvert) ?? true;
    if (needToConvert) {
      _prefs.setBool(_prefConvert, false);
      await _convertLegacy();
    }
    bool convertScreens = _prefs.getBool(_prefConvertB) ?? true;
    if (convertScreens) {
      _prefs.setBool(_prefConvertB, false);
      await _convertLegacyScreens();
    } else {
      await _loadVM();
    }
  }

  Future _loadVM() async {
    MainVM viewModel = new MainVM();

    //get encrypted password
    viewModel.password = await _getPassword();

    ScreenRepository screenRepo = new ScreenRepository();
    viewModel.screenList = new List();
    screenRepo.getScreenList().then((result) {
      LinkedHashMap _screenListMap = result;
      if (_screenListMap != null && _screenListMap.length > 0) {
        _screenListMap.forEach((k, v) => viewModel.screenList.add(new ScreenListItem(k, v)) );
      } else {
        Screen newScreen = new Screen();
        newScreen.screenId = 0;
        newScreen.name = "Empty Screen";
        screenRepo.save(newScreen);
        viewModel.screenList.add(new ScreenListItem(newScreen.screenId, newScreen.name));
      }

      viewModel.darkMode = _prefs.getBool(_prefNightMode) ?? true;
      viewModel.port = _prefs.getString(_prefPort) ?? "8091";
      viewModel.address = _prefs.getString(_prefAddress) ?? "192.168.x.x";

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

      this._viewModel = viewModel;

      _mainContract.preferencesLoaded(viewModel);
    });


  }

  Future _convertLegacyScreens() async {
    MethodChannel platform = new MethodChannel(Channel.channelUtil);
    try {
      await platform.invokeMethod(Channel.actionUtilUpdateScreens);
    } on PlatformException catch (e) {
      print(e.message);
    }
    await _loadVM();
  }

  Future _convertLegacy() async {
    MethodChannel platform = new MethodChannel(Channel.channelUtil);
    try {
      final LinkedHashMap result =
          await platform.invokeMethod(Channel.actionUtilGetSettings);
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

  Future<String> _encryptPassword() async {
    String response = "";

    const platform = const MethodChannel(Channel.channelUtil);
    if (_viewModel.password.isNotEmpty) {
      try {
        final String result = await platform.invokeMethod(Channel.actionUtilEncrypt, {"password": _viewModel.password});
        response = result;
      } on PlatformException catch (e) {
        response = "";
      }
    }
    return response;
  }

  //calls legacy code
  Future<String> _getPassword() async {
    String response = "";
    String encrypted = _prefs.getString(_prefPassword) ?? "";

    const platform = const MethodChannel(Channel.channelUtil);
    if (encrypted.isNotEmpty) {
      try {
        final String result = await platform
            .invokeMethod(Channel.actionUtilDecrypt, {"code": encrypted});
        response = result;
      } on PlatformException catch (_) {
        response = "";
      }
    }
    return response;
  }

  saveMainSettings(String address, String port, String password, int screenId) async {
    _viewModel.address = address;
    _viewModel.port = port;
    _viewModel.password = password;
    _prefs.setString(_prefAddress, address);
    _prefs.setString(_prefPort, port);
    _prefs.setString(_prefPassword, await _encryptPassword());
    _prefs.setInt(_prefSelectedScreenId, screenId);
  }

  setDarkMode(bool newValue) {
    _viewModel.darkMode = newValue;
    _prefs.setBool(_prefNightMode, newValue);
    const platform = const MethodChannel(Channel.channelUtil);
    try {
      platform.invokeMethod(Channel.actionUtilUpdateDarkMode, {"darkMode": newValue});
      } on PlatformException catch (e) {
    }
  }

}
