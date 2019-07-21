import 'package:flutter/material.dart';

import 'package:gic_flutter/screens/main/main.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';
import 'package:gic_flutter/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  var myApp = MyApp(SettingRepository(await SharedPreferences.getInstance()));
    runApp(myApp);
}

class MyApp extends StatelessWidget {
  SettingRepository _settingRepository  ;

  MyApp (SettingRepository sharedPreferences) {
    _settingRepository = sharedPreferences;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaming Interface Client',
      theme: appTheme(),
      darkTheme: darkTheme(),
      home: MainScreen(_settingRepository),
    );
  }
}
