import 'package:shared_preferences/shared_preferences.dart';

class SettingRepository{
  final String _nightMode = "NIGHT_MODE";
  final String _firstRun = "prefSplash";

  Future<bool> getDarkMode() async {
	  final SharedPreferences prefs = await SharedPreferences.getInstance();
  	return prefs.getBool(_nightMode) ?? true;
  }
  
  Future<bool> getFirstRun() async {
	  final SharedPreferences prefs = await SharedPreferences.getInstance();
  	return prefs.getBool(_firstRun) ?? true;
  }
}