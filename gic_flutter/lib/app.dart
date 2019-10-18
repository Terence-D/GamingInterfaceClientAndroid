import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gic_flutter/screens/main/main.dart';

import 'model/intl/localizations.dart';
import 'services/setting/settingRepository.dart';
import 'theme/theme.dart';

class GicApp extends StatelessWidget {
  SettingRepository _settingRepository  ;

  GicApp (SettingRepository 
  sharedPreferences) {
    _settingRepository = sharedPreferences;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => Intl.of(context).title,
      theme: CustomTheme.of(context),
      //theme: lightTheme(),
      //darkTheme: darkTheme(),
      home: MainScreen(_settingRepository),
      localizationsDelegates: [
        const IntlDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
      ],
    );
  }
}
