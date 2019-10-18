import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class IntlDelegate extends LocalizationsDelegate<Intl> {
  const IntlDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<Intl> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<Intl>(Intl(locale));
  }

  @override
  bool shouldReload(IntlDelegate old) => false;
}

class Intl {
  Intl(this.locale);

  final Locale locale;

  static Intl of(BuildContext context) {
    return Localizations.of<Intl>(context, Intl);
  }

  String getText(String resource) { 
    return _localized[locale.languageCode][resource];
  }

  static Map<String, Map<String, String>> _localized = {
    'en': {
      'title': 'Gaming Interface Client ',

      'mainPasswordError': 'invalid password, it must be at least 6 digits long',
      'mainInvalidPort': 'invalid port number',
      'mainFirewallError': 'Error connecting, is the server running and firewall ports opened?',
      'mainAddress': 'Address',
      'mainPort': 'Port',
      'mainPassword': 'Password',
      'mainPasswordWarning': 'Warning - do NOT use an existing password that you use ANYWHERE else',
      'mainScreenManager': 'Screen Manager',
      'mainErrorNoScreen': 'You need to add a screen from the screen manager first!',
      'mainStart': 'Start',
      'mainWrongVersion': 'Wrong Version',
      'mainOutOfDate': 'The GIC Server appears to be out of date - please upgrade to the latest version by clicking on the "Website" link on the server.  If you did not yet install the server, click the Help button',
      'mainClose': 'Close',
      'mainNext': 'Next',
      'mainHelpIpAddress': 'IP Address: The network address of the computer running the server.  This can be found in Windows 10 by going into Settings, then Network and Internet, and usually starts with "192"',
      'mainHelpPassword': 'Password: this has to match on the server as well, and is used to provide some security',
      'mainHelpScreenList': 'Screen List: This will let you select different screens you have created to use',
      'mainHelpScreenManager': 'Manager: Tapping on this will open up the Screen Manager where you can create, edit, delete, and import/export other screens',
      'mainHelpStart': 'Start: Tapping this will connect to the server and let you start with the screen you\'ve selected',

      'menuTheme': 'Toggle Theme',
      'menuIntro': 'Show Intro',
      'menuAbout': 'About',
      'menuDonate': 'Donate',
    }
  };

  //these are used in view models where context aren't available... i should do all in here, but for now its as needed
  static String get mainPasswordError { return 'mainPasswordError'; }
  static String get mainInvalidPort { return 'mainInvalidPort'; }
  static String get mainFirewallError { return 'mainFirewallError'; }
  static String get menuTheme { return 'menuTheme'; }
  static String get menuIntro { return 'menuIntro'; }
  static String get menuAbout { return 'menuAbout'; }
  static String get menuDonate { return 'menuDonate'; }

  //useful where context is available.. as above i should do this for all
  String get title { return _localized[locale.languageCode]['title']; }
  String get mainAddress { return _localized[locale.languageCode]['mainAddress']; }
  String get mainPassword { return _localized[locale.languageCode]['mainPassword']; }
  String get mainPort { return _localized[locale.languageCode]['mainPort']; }
  String get mainPasswordWarning { return _localized[locale.languageCode]['mainPasswordWarning']; }
  String get mainScreenManager { return _localized[locale.languageCode]['mainScreenManager']; }
  String get mainErrorNoScreen { return _localized[locale.languageCode]['mainErrorNoScreen']; }
  String get mainStart { return _localized[locale.languageCode]['mainStart']; }
  String get mainWrongVersion { return _localized[locale.languageCode]['mainWrongVersion']; }
  String get mainOutOfDate { return _localized[locale.languageCode]['mainOutOfDate']; }
  String get mainClose { return _localized[locale.languageCode]['mainClose']; }
  String get mainHelpIpAddress { return _localized[locale.languageCode]['mainHelpIpAddress']; }
  String get mainHelpPassword { return _localized[locale.languageCode]['mainHelpPassword']; }
  String get mainHelpScreenList { return _localized[locale.languageCode]['mainHelpScreenList']; }
  String get mainHelpScreenManager { return _localized[locale.languageCode]['mainHelpScreenManager']; }
  String get mainHelpStart { return _localized[locale.languageCode]['mainHelpStart']; }
  String get mainNext { return _localized[locale.languageCode]['mainNext']; }
}

