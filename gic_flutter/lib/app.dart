import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gic_flutter/screens/main/mainView.dart';

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
      home: MainView(),
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
