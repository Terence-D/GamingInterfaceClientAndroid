import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferenceLoaderContract {
  void preferencesLoaded(); 
}

class SettingRepository {
  SharedPreferences _prefs;

  bool _firstRun;
  bool _darkMode;
  String _address;
  String _port;
  String _password;
  int _selectedScreenId;
  bool _donate;
  bool _donateStar;

  bool get donate => _donate;
  bool get donateStar => _donateStar;
  bool get darkMode => _darkMode;
  bool get firstRun => _firstRun;
  String get port => _port;
  String get address => _address;
  int get selectedScreenId => _selectedScreenId;
  String get password => _password;

  static const String _prefNightMode = "nightMode";
  static const String _prefFirstRun = "firstRun"; //show the whole intro thing
  static const String _prefShowHints = "showHints"; //show the help page
  static const String _prefPassword = "password";
  static const String _prefPort = "port";
  static const String _prefAddress = "address";
  static const String _prefConvert = "legacyConvert";
  static const String _prefSelectedScreenId = "chosenId";
  static const String _prefDonate = "coffee";
  static const String _prefDonateStar = "star";

  SettingRepository(PreferenceLoaderContract loader) {
    SharedPreferences.getInstance().then((shared) {
      _prefs = shared;
      _loadSettings().then((_) {
        loader.preferencesLoaded();
      });
    });
  }

  Future _loadSettings() async {
    _prefs.reload();
    //this handles reading in legacy settings
    bool needToConvert = _prefs.getBool(_prefConvert) ?? true;
    if (needToConvert) {
      await _convertLegacy();
      _prefs.setBool(_prefConvert, false);
    }

    _firstRun = _prefs.getBool(_prefFirstRun) ?? true;
    _darkMode = _prefs.getBool(_prefNightMode) ?? true;
    _port = _prefs.getString(_prefPort) ?? "8091";
    _address = _prefs.getString(_prefAddress) ?? "192.168.x.x";
    _selectedScreenId = _prefs.getInt(_prefSelectedScreenId) ?? 0;
    //if first run is true, we set it to false automatically
    if (_firstRun) _prefs.setBool(_prefFirstRun, false);
    _password = await _getPassword();
    if (_prefs.containsKey(_prefDonate)) 
      _donate = _prefs.getBool(_prefDonate);
    else {
      _donate = false;  
    }

     if (_prefs.containsKey(_prefDonateStar))
      _donateStar = _prefs.getBool(_prefDonateStar);
    else {
      _donateStar = false;  
    }
  }

  Future _convertLegacy() async {
    MethodChannel platform = new MethodChannel(Channel.channelUtil);
    try {
      final LinkedHashMap result =
          await platform.invokeMethod(Channel.actionUtilGetSettings);
      if (result != null && result.length > 0) {
        result.forEach((key, value) {
          switch (key) {
            case "prefSplash":
              _prefs.setBool(_prefFirstRun, value);
              break;
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
    if (_password.isNotEmpty) {
      try {
        final String result = await platform.invokeMethod(Channel.actionUtilEncrypt, {"password": password});
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
    _address = address;
    _port = port;
    _password = password;
    _prefs.setString(_prefAddress, address);
    _prefs.setString(_prefPort, port);
    _prefs.setString(_prefPassword, await _encryptPassword());
    _prefs.setInt(_prefSelectedScreenId, screenId);
  }

  setDarkMode(bool newValue) {
    _darkMode = newValue;
    _prefs.setBool(_prefNightMode, newValue);
    const platform = const MethodChannel(Channel.channelUtil);
    try {
      platform.invokeMethod(Channel.actionUtilUpdateDarkMode, {"darkMode": newValue});
      } on PlatformException catch (e) {
    }
  }
}
