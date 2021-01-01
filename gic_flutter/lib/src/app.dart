import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gic_flutter/src/views/intro/introView.dart';
import 'package:gic_flutter/src/views/launcher/launcher.dart';
import 'backend/models/intl/localizations.dart';
import 'backend/services/localStorageService.dart';
import 'service_locator.dart';
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
