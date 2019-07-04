import 'package:shared_preferences/shared_preferences.dart';

class SettingRepository{
  SharedPreferences prefs;
  final String _nightMode = "NIGHT_MODE";
  final String _firstRun = "prefSplash";
  final String _prefPassword = "password";
  final String _prefPort = "port";
  final String _prefAddress = "address";

  SettingRepository(SharedPreferences sharedPrefs)  {
    this.prefs = sharedPrefs;
  }

  bool getDarkMode() {
  	return prefs.getBool(_nightMode) ?? true;
  }
  
  bool getFirstRun()  {
  	return prefs.getBool(_firstRun) ?? true;
  }
  
  String getPassword()  {
  	return prefs.getString(_prefPassword) ?? "";
  }
  
  String getPort() {
  	return prefs.getString(_prefPort) ?? "";
  }
  
  String getAddress() {
  	return prefs.getString(_prefAddress) ?? "8091";
  }
}