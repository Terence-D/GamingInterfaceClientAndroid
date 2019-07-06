import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingRepository {
  SharedPreferences prefs;
  final String _nightMode = "NIGHT_MODE";
  final String _firstRun = "prefSplash";
  final String _prefPassword = "password";
  final String _prefPort = "port";
  final String _prefAddress = "address";

  SettingRepository(SharedPreferences sharedPrefs) {
    this.prefs = sharedPrefs;
  }

  bool getDarkMode() {
    return prefs.getBool(_nightMode) ?? true;
  }

  bool getFirstRun() {
    return prefs.getBool(_firstRun) ?? true;
  }

  Future<String> getPassword()  async {
    String response = "";
    String encrypted = prefs.getString(_prefPassword) ?? "";

    const platform = const MethodChannel(Channel.utilCrypto);
    if (encrypted.isNotEmpty) {
      try {
        final String result = await platform.invokeMethod('decrypt', {"code": encrypted});
        response = result;
      } on PlatformException catch (e) {
        response = "Failed to Invoke: '${e.message}'.";
      }
    }
    return response;
  }

  String getPort() {
    return prefs.getString(_prefPort) ?? "";
  }

  String getAddress() {
    return prefs.getString(_prefAddress) ?? "8091";
  }
}
