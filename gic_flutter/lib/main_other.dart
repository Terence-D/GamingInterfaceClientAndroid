import 'package:flutter/material.dart';

import 'package:gic_flutter/services/setting/settingRepository.dart';
import 'package:gic_flutter/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'flavor.dart';

void main() async {
  BuildEnvironment.init(flavor: BuildFlavor.other);
  var myApp = GicApp(SettingRepository(await SharedPreferences.getInstance()));
  var myTheme =  CustomTheme(
      initialThemeKey: ThemeKeys.DARK,
      child: myApp,
    );
    WidgetsFlutterBinding.ensureInitialized();
    runApp(myTheme);
}
