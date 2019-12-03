import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gic_flutter/views/intro/introView.dart';
import 'package:gic_flutter/views/main/mainView.dart';
import 'package:gic_flutter/service_locator.dart';
import 'package:gic_flutter/services/localStorageService.dart';

import 'model/channel.dart';
import 'model/intl/localizations.dart';
import 'theme/theme.dart';

class GicApp extends StatelessWidget {
  GicApp () {
  }

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
    } else if (localStorageService.needToConvert)
      _convertLegacy();
    return MainView();
  }

  //can be removed around 4.5 era
  Future _convertLegacy() async {
    MethodChannel platform = new MethodChannel(Channel.channelUtil);
    try {
      await platform.invokeMethod(Channel.actionUtilUpdateScreens);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
}
