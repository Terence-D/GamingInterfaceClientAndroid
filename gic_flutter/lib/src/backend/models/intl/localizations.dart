import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlDonate.dart';

import 'intlAbout.dart';
import 'intlFeedback.dart';
import 'intlOptions.dart';

class IntlDelegate extends LocalizationsDelegate<Intl> {
  const IntlDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

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

  static Intl? of(BuildContext context) {
    return Localizations.of<Intl>(context, Intl);
  }

  String about(AboutText resource) {
    return IntlAbout.localizedStrings[locale.languageCode]![resource]!;
  }

  String options(OptionsText resource) {
    return IntlOptions.localizedStrings[locale.languageCode]![resource]!;
  }

  String donate(DonateText resource) {
    return IntlDonate.localizedStrings[locale.languageCode]![resource]!;
  }

  String feedback(FeedbackText resource) {
    return IntlFeedback.localizedStrings[locale.languageCode]![resource]!;
  }

  static Map<String, Map<String, String>> _localized = {
    'en': {
      'title': 'Gaming Interface Client ',
      'mainPasswordError':
          'invalid password, it must be at least 6 digits long',
      'mainInvalidPort': 'invalid port number',
      'mainInvalidServerError': 'invalid server address',
      'mainFirewallError':
          'Error connecting, is the server running and firewall ports opened?',
      'mainAddress': 'Address',
      'mainPort': 'Port',
      'mainPassword': 'Password',
      'mainPasswordWarning':
          'Warning - do NOT use an existing password that you use ANYWHERE else',
      'mainScreenManager': 'Screen Manager',
      'mainErrorNoScreen':
          'You need to add a screen from the screen manager first!',
      'mainStart': 'Start',
      'mainWrongVersion': 'Wrong Version',
      'mainOutOfDate':
          'The GIC Server appears to be out of date - please upgrade to the latest version by clicking on the "Website" link on the server.  If you did not yet install the server, click the Help button',
      'mainClose': 'Close',
      'mainNext': 'Next',
      'mainHelpScreenList':
          'Screen List: This will let you select different screens you have created to use',
      'mainHelpScreenManager':
          'Manager: Tapping on this will open up the Screen Manager where you can create, edit, delete, and import/export other screens',
      'mainHelpStart':
          'Start: Tapping this will connect to the server and let you start with the screen you\'ve selected',
      'onboardIntroTitle': 'Welcome!',
      'onboardIntroDesc':
          'Thank you for installing GIC - this app allows you to create unique screens to send commands to an app on your computer.  No need to memorize keyboard shortcuts!  Click on the ? icons in the app for help!',
      'onboardServerTitle': 'Server',
      'onboardServerDesc':
          'GIC requires software on the computer your communicating with.  The link is in inside the "About" view from the main screen.  Alternatively clicking this button will open your email app with the link to the server inside.',
      'onboardSendLink': 'Send Link',
      'onboardScreenTitle': 'Screen Starter',
      'onboardScreenDesc':
          'If you like you can pick one (or more!) of the screens I\'ve built below as a starting point, or you can skip this step and build your own!',
      'onboardScreenDevice': 'Device Type',
      'onboardScreenList': 'Pick a Screen:',
      'onboardSkip': 'Skip',
      'onboardDone': 'Done',
      'onboardImport': 'Import',
      'onboardEmailSubject': 'Link to GIC Server',
      'onboardOldAndroidTitle': 'Unsupported',
      'onboardOldAndroidDesc':
          'You are running an older version of Android.  Certain functions are disabled (such as import/export) for now.  This may change if I can find the time to work around the limitations.',
      'onboardSupportTitle': 'Support',
      'onboardSupportDesc':
          'Although this app is completely free and open source (and will remain as such!), if you like the app and wish to support development, I appreciate any support you can provide.  There is a Donate menu option for more information.  Thank you :)',
      'onboardImportSuccess': 'Import Complete!',
    }
  };

  //useful where context is available.. as above i should do this for all
  //String get menuTheme { return _localized[locale.languageCode]['menuTheme'];}

  String get title {
    return _localized[locale.languageCode]!['title']!;
  }

  String get onboardSkip {
    return _localized[locale.languageCode]!['onboardSkip']!;
  }

  String get onboardDone {
    return _localized[locale.languageCode]!['onboardDone']!;
  }

  String get onboardImport {
    return _localized[locale.languageCode]!['onboardImport']!;
  }

  String get onboardIntroTitle {
    return _localized[locale.languageCode]!['onboardIntroTitle']!;
  }

  String get onboardIntroDesc {
    return _localized[locale.languageCode]!['onboardIntroDesc']!;
  }

  String get onboardServerTitle {
    return _localized[locale.languageCode]!['onboardServerTitle']!;
  }

  String get onboardServerDesc {
    return _localized[locale.languageCode]!['onboardServerDesc']!;
  }

  String get onboardScreenTitle {
    return _localized[locale.languageCode]!['onboardScreenTitle']!;
  }

  String get onboardScreenDesc {
    return _localized[locale.languageCode]!['onboardScreenDesc']!;
  }

  String get onboardScreenList {
    return _localized[locale.languageCode]!['onboardScreenList']!;
  }

  String get onboardScreenDevice {
    return _localized[locale.languageCode]!['onboardScreenDevice']!;
  }

  String get onboardSendLink {
    return _localized[locale.languageCode]!['onboardSendLink']!;
  }

  String get onboardEmailSubject {
    return _localized[locale.languageCode]!['onboardEmailSubject']!;
  }

  String get onboardOldAndroidTitle {
    return _localized[locale.languageCode]!['onboardOldAndroidTitle']!;
  }

  String get onboardOldAndroidDesc {
    return _localized[locale.languageCode]!['onboardOldAndroidDesc']!;
  }

  String get onboardSupportTitle {
    return _localized[locale.languageCode]!['onboardSupportTitle']!;
  }

  String get onboardSupportDesc {
    return _localized[locale.languageCode]!['onboardSupportDesc']!;
  }

  String get onboardImportSuccess {
    return _localized[locale.languageCode]!['onboardImportSuccess']!;
  }
}
