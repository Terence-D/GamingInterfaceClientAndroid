import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingRepository {
  SharedPreferences prefs;
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

  bool _firstRun;
  bool _darkMode;
  String _address;
  String _port;
  String _password;
  int _selectedScreenId;
  bool _donate;
  bool _donateStar;

  SettingRepository(SharedPreferences sharedPrefs) {
    this.prefs = sharedPrefs;
  }

  bool get donate => _donate;
  bool get donateStar => _donateStar;
  bool get darkMode => _darkMode;
  bool get firstRun => _firstRun;
  String get port => _port;
  String get address => _address;
  int get selectedScreenId => _selectedScreenId;
  String get password => _password;
  
  saveMainSettings(String address, String port, String password, int screenId) async {
    _address = address;
    _port = port;
    _password = password;
    prefs.setString(_prefAddress, address);
    prefs.setString(_prefPort, port);
    prefs.setString(_prefPassword, await _encryptPassword());
    prefs.setInt(_prefSelectedScreenId, screenId);
  }

  loadSettings() async {
    prefs.reload();
    //this handles reading in legacy settings
    bool needToConvert = prefs.getBool(_prefConvert) ?? true;
    if (needToConvert) {
      await _convertLegacy();
      prefs.setBool(_prefConvert, false);
    }

    _firstRun = prefs.getBool(_prefFirstRun) ?? true;
    _darkMode = prefs.getBool(_prefNightMode) ?? true;
    _port = prefs.getString(_prefPort) ?? "8091";
    _address = prefs.getString(_prefAddress) ?? "192.168.x.x";
    _selectedScreenId = prefs.getInt(_prefSelectedScreenId) ?? 0;
    //if first run is true, we set it to false automatically
    if (_firstRun) prefs.setBool(_prefFirstRun, false);
    _password = await _getPassword();
    if (prefs.containsKey(_prefDonate)) 
      _donate = prefs.getBool(_prefDonate);
    else {
      _donate = false;  
    }

     if (prefs.containsKey(_prefDonateStar))
      _donateStar = prefs.getBool(_prefDonateStar);
    else {
      _donateStar = false;  
    }
  }

  setDarkMode(bool newValue) {
    _darkMode = newValue;
    prefs.setBool(_prefNightMode, newValue);
    const platform = const MethodChannel(Channel.channelUtil);
    try {
      platform.invokeMethod(Channel.actionUtilUpdateDarkMode, {"darkMode": newValue});
      } on PlatformException catch (e) {
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

  //legacy code
  Future<String> _getPassword() async {
    String response = "";
    String encrypted = prefs.getString(_prefPassword) ?? "";

    const platform = const MethodChannel(Channel.channelUtil);
    if (encrypted.isNotEmpty) {
      try {
        final String result = await platform
            .invokeMethod(Channel.actionUtilDecrypt, {"code": encrypted});
        response = result;
      } on PlatformException catch (e) {
        response = "";
      }
    }
    return response;
  }

  // Future<LinkedHashMap> _getScreenList() async {
  //   MethodChannel platform = new MethodChannel(Channel.channelUtil);
  //   try {
  //     final LinkedHashMap result =
  //         await platform.invokeMethod(Channel.actionUtilGetScreens);
  //     return result;
  //   } on PlatformException catch (e) {
  //     print(e.message);
  //   }
  //   return null;
  // }

  Future _convertLegacy() async {
    MethodChannel platform = new MethodChannel(Channel.channelUtil);
    try {
      final LinkedHashMap result =
          await platform.invokeMethod(Channel.actionUtilGetSettings);
      if (result != null && result.length > 0) {
        result.forEach((key, value) {
          switch (key) {
            case "prefSplash":
              prefs.setBool(_prefFirstRun, value);
              break;
            case "NIGHT_MODE":
              prefs.setBool(_prefNightMode, value);
              break;
            case "address":
              prefs.setString(_prefAddress, value);
              break;
            case "port":
              prefs.setString(_prefPort, value);
              break;
            case "password":
              prefs.setString(_prefPassword, value);
              break;
            case "chosen_id":
              prefs.setInt(_prefSelectedScreenId, value);
              break;
            case "seenHelp":
              prefs.setBool(_prefShowHints, value);
              break;
          }
        });
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
}
