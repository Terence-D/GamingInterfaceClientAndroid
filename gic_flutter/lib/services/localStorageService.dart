import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static LocalStorageService _instance;
  static SharedPreferences _preferences;
  static const String _prefFirstRun = "firstRun"; //show the whole intro thing

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService();
    }

    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }

    return _instance;
  }

  dynamic _getFromDisk(String key) {
    var value = true;
    if (_preferences.containsKey(key))
      value  = _preferences.get(key);
    print('(TRACE) LocalStorageService:_getFromDisk. key: $key value: $value');
    return value;
  }

  void _saveBoolToDisk(String key, bool value){
    print('(TRACE) LocalStorageService:_saveStringToDisk. key: $key value: $value');
    _preferences.setBool(key, value);
  }

  bool get firstRun {
    bool firstRun = _getFromDisk(_prefFirstRun);
    if (firstRun)
        _saveBoolToDisk(_prefFirstRun, false);
    return firstRun;
  }

}