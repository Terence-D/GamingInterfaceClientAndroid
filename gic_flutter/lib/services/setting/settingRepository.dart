import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingRepository {
  SharedPreferences prefs;
  static const String _prefNightMode = "NIGHT_MODE";
  static const String _prefFirstRun = "prefSplash";
  static const String _prefPassword = "password";
  static const String _prefPort = "port";
  static const String _prefAddress = "address";
  static const String _prefSelectedScreenId = "chosen_id";

  bool _firstRun;
  bool _darkMode;
  String _address;
  String _port;
  String _password;
  int _selectedScreenId;
  LinkedHashMap _screenList;

  SettingRepository(SharedPreferences sharedPrefs) {
    this.prefs = sharedPrefs;
    _firstRun = prefs.getBool(_prefFirstRun) ?? true;
    _darkMode = prefs.getBool(_prefNightMode) ?? true;
    _port = prefs.getString(_prefPort) ?? "8091";
    _address = prefs.getString(_prefAddress) ?? "192.168.x.x";
    _selectedScreenId = prefs.getInt(_prefSelectedScreenId) ?? 0;
    //if first run is true, we set it to false automatically
    if (_firstRun)
      prefs.setBool(_prefFirstRun, false);
  }

  bool get darkMode => _darkMode;
  bool get firstRun => _firstRun;
  String get port => _port;
  String get address => _address;
  int get selectedScreenId => _selectedScreenId;
  String get password => _password;
  LinkedHashMap get screenList => _screenList;

  loadSettings() async {
    _screenList = await _getScreenList();
    _password = await _getPassword();

  }

  Future<String> _getPassword() async {
    String response = "";
    String encrypted = prefs.getString(_prefPassword) ?? "";

    const platform = const MethodChannel(Channel.channelUtil);
    if (encrypted.isNotEmpty) {
      try {
        final String result = await platform.invokeMethod(Channel.actionUtilDecrypt, {"code": encrypted});
        response = result;
      } on PlatformException catch (e) {
        response = "";
      }
    }
    return response;
  }

  Future<LinkedHashMap> _getScreenList() async {
    MethodChannel platform = new MethodChannel(Channel.channelUtil);
    try {
      final LinkedHashMap result = await platform.invokeMethod(Channel.actionUtilGetScreens);
      return result;
    } on PlatformException catch (e) {
      print(e.message);
    }
    return null;
  }

}
