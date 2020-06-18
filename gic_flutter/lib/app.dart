import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gic_flutter/ui/launcher.dart';
import 'package:gic_flutter/views/intro/introView.dart';
import 'package:gic_flutter/views/main/mainView.dart';
import 'package:gic_flutter/service_locator.dart';
import 'package:gic_flutter/services/localStorageService.dart';

import 'model/intl/localizations.dart';
import 'theme/theme.dart';

class GicApp extends StatelessWidget {
  GicApp ();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => Intl.of(context).title,
      theme: CustomTheme.of(context),
      //theme: lightTheme(),
      //darkTheme: darkTheme(),
      home: _getStartupScreen(),
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

  Widget _getStartupScreen() {
    var localStorageService = locator<LocalStorageService>();
    if(localStorageService.firstRun) {
      return IntroView();
    }
    return Launcher();
  }
}
