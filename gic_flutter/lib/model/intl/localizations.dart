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

      'onboardIntroTitle': 'Welcome!',
      'onboardIntroDesc': 'Thank you for installing GIC - the open source Game Interface Client.  Ahead are just a few tips to help you get started.  This will only be shown once - tap on the bottom right corner arrow to begin.',
      'onboardServerTitle': 'Server',
      'onboardServerDesc': 'GIC requires software on the computer your communicating with.  The link is in inside the "About" view from the main screen.  Alternatively clicking this button will open your email app with the link to the server inside.',
      'onboardAboutTitle': 'About',
      'onboardAboutDesc' :'GIC allows you to create fully customizable interfaces (screens) to send commands to an app on your computer.  Useful for complex sim type games, but GIC can be used for any app or game that you like.  You can also share your screens with others!',
      'onboardLetsGoTitle' :'Questions?',
      'onboardLetsGoDesc': 'I\'ve added Help sections to each part of this app - click the \'?\' at the top right corner of the app for help!  Thank you for using GIC!',
      'onboardSendLink': 'Send Link',
      'onboardScreenTitle': 'Screen Starter',
      'onboardScreenDesc': 'If you like you can pick one (or more!) of the screens I\'ve built below as a starting point, or you can skip this step and build your own!',
      'onboardScreenDevice': 'Device Type',
      'onboardScreenList': 'Pick a Screen:',
      'onboardSkip': 'Skip',
      'onboardDone': 'Done',
      'onboardImport': 'Import',
      'onboardEmailSubject': 'Link to GIC Server',
      'onboardOldAndroidTitle': 'Unsupported',
      'onboardOldAndroidDesc': 'You are running an older version of Android.  Certain functions are disabled (such as import/export) for now.  This may change if I can find the time to work around the limitations.',
      'onboardSupportTitle': 'Support Me',
      'onboardSupportDesc': 'Although this app is completely free and open source (and will remain as such!), if you like the app and wish to support development, I appreciate any support you can provide.  There is a Donate menu option for more information.  Thank you :)',
      'onboardImportSuccess': 'Import Complete!'
    }
  };

  //these are used in view models where context aren't available... i should do all in here, but for now its as needed
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

  String get onboardSkip { return _localized[locale.languageCode]['onboardSkip']; }
  String get onboardDone { return _localized[locale.languageCode]['onboardDone']; }
  String get onboardImport { return _localized[locale.languageCode]['onboardImport']; }
  String get onboardIntroTitle { return _localized[locale.languageCode]['onboardIntroTitle']; }
  String get onboardIntroDesc { return _localized[locale.languageCode]['onboardIntroDesc']; }
  String get onboardServerTitle { return _localized[locale.languageCode]['onboardServerTitle']; }
  String get onboardServerDesc { return _localized[locale.languageCode]['onboardServerDesc']; }
  String get onboardAboutTitle { return _localized[locale.languageCode]['onboardAboutTitle']; }
  String get onboardAboutDesc { return _localized[locale.languageCode]['onboardAboutDesc']; }
  String get onboardLetsGoTitle { return _localized[locale.languageCode]['onboardLetsGoTitle']; }
  String get onboardLetsGoDesc { return _localized[locale.languageCode]['onboardLetsGoDesc']; }
  String get onboardScreenTitle { return _localized[locale.languageCode]['onboardScreenTitle']; }
  String get onboardScreenDesc { return _localized[locale.languageCode]['onboardScreenDesc']; }
  String get onboardScreenList { return _localized[locale.languageCode]['onboardScreenList']; }
  String get onboardScreenDevice { return _localized[locale.languageCode]['onboardScreenDevice']; }
  String get onboardSendLink { return _localized[locale.languageCode]['onboardSendLink']; }
  String get onboardEmailSubject { return _localized[locale.languageCode]['onboardEmailSubject']; }
  String get onboardOldAndroidTitle { return _localized[locale.languageCode]['onboardOldAndroidTitle']; }
  String get onboardOldAndroidDesc { return _localized[locale.languageCode]['onboardOldAndroidDesc']; }
  String get onboardSupportTitle { return _localized[locale.languageCode]['onboardSupportTitle']; }
  String get onboardSupportDesc { return _localized[locale.languageCode]['onboardSupportDesc']; }
  String get onboardImportSuccess { return _localized[locale.languageCode]['onboardImportSuccess']; }
  String get mainPasswordError { return _localized[locale.languageCode]['mainPasswordError'];}
  String get mainInvalidPort { return _localized[locale.languageCode]['mainInvalidPort'];}
  String get mainFirewallError { return _localized[locale.languageCode]['mainFirewallError'];}
}
