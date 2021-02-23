import 'package:shared_preferences/shared_preferences.dart';

class FirstRunService {
  static FirstRunService _instance;
  static SharedPreferences _preferences;
  static const String _prefFirstRun = "firstRun"; //show the whole intro thing

  static Future<FirstRunService> getInstance() async {
    if (_instance == null) {
      _instance = FirstRunService();
    }

    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }

    return _instance;
  }

  dynamic _getBoolFromDisk(String key) {
    var value = true;
    if (_preferences.containsKey(key))
      value  = _preferences.get(key);
    return value;
  }

  void _saveBoolToDisk(String key, bool value){
    _preferences.setBool(key, value);
  }

  bool get firstRun {
    bool firstRun = _getBoolFromDisk(_prefFirstRun);
    if (firstRun)
      _saveBoolToDisk(_prefFirstRun, false);
    return firstRun;
  }
}