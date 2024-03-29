enum AboutText {
  toolbarTitle,
  versionText,
  libraryTitle,
  legalTitle,
  legalText,
  legalUrl,
  url,
  serverTitle,
  serverText,
  serverUrl,

  cryptoTitle,
  cryptoText,
  cryptoUrl,
  flutterDevTitle,
  flutterDevText,
  flutterDevUrl,
  httpTitle,
  httpText,
  httpUrl,
  fluttertoastTitle,
  fluttertoastText,
  fluttertoastUrl,
  introductionScreenTitle,
  introductionScreenText,
  introductionScreenUrl,
  flutterEmailSenderTitle,
  flutterEmailSenderText,
  flutterEmailSenderUrl,
  flutterCommunityTitle,
  flutterCommunityText,
  flutterCommunityUrl,
  flutterLinkifyTitle,
  flutterLinkifyText,
  flutterLinkifyUrl,
  archiveTitle,
  archiveText,
  archiveUrl,
  scrollablePositionedListTitle,
  scrollablePositionedListText,
  scrollablePositionedListUrl,
  permissionHandlerTitle,
  permissionHandlerText,
  permissionHandlerUrl,
  filePickerTitle,
  filePickerText,
  filePickerUrl,
  showcaseviewTitle,
  showcaseviewText,
  showcaseviewUrl,
  oxoTitle,
  oxoText,
  oxoUrl
}

class IntlAbout {
  static Map<String, Map<AboutText, String>> localizedStrings = {
    'en': {
      AboutText.toolbarTitle: 'About',
      AboutText.versionText: 'Version: ',
      AboutText.url:
          'https://github.com/Terence-D/GamingInterfaceClientAndroid/wiki',
      AboutText.legalTitle: 'Legal',
      AboutText.legalText:
          'GIC (this software) and the GIC Server are open source products and combined are used to act as a remote control style device for your PC.  Copyright 2020 Terence Doerksen',
      AboutText.legalUrl: 'http://www.apache.org/licenses/LICENSE-2.0',
      AboutText.serverTitle: 'Server',
      AboutText.serverText:
          'To use this you need to run GIC Server (also Open Source) on your computer where the game resides.  Please visit the link below for further information',
      AboutText.serverUrl:
          'https://github.com/Terence-D/GamingInterfaceCommandServer',
      AboutText.libraryTitle: '3rd Party',
      AboutText.cryptoTitle: 'Encryption library by Mataprasad',
      AboutText.cryptoText: 'Licensed under the MIT License.',
      AboutText.cryptoUrl:
          'https://github.com/mataprasad/Cross-platform-AES-encryption-128bit/blob/master/LICENSE',
      AboutText.flutterDevTitle: 'Flutter Packages',
      AboutText.flutterDevText:
          'shared_preferences, device_info, package_info, url_launcher, path_provider developed by the Flutter Dev team and licensed under the BSD license',
      AboutText.flutterDevUrl:
          'https://github.com/flutter/plugins/blob/master/packages/shared_preferences/shared_preferences/LICENSE',
      AboutText.httpTitle: 'http Package by the Dart Dev team',
      AboutText.httpText: 'Licensed under the BSD license',
      AboutText.httpUrl:
          'https://github.com/dart-lang/http/blob/master/LICENSE',
      AboutText.fluttertoastTitle: 'Fluttertoast Package by karthikponnam.dev',
      AboutText.fluttertoastText: 'Licensed under the MIT license',
      AboutText.fluttertoastUrl:
          'https://github.com/PonnamKarthik/FlutterToast/blob/master/LICENSE',
      AboutText.introductionScreenTitle:
          'introduction_screen by jeancharles.msse@gmail.com',
      AboutText.introductionScreenText: 'Licensed under the MIT license',
      AboutText.introductionScreenUrl:
          'https://github.com/pyozer/introduction_screen/blob/master/LICENSE',
      AboutText.flutterEmailSenderTitle:
          'flutter email sender by tautvydas.sidlauskas@gmail.com',
      AboutText.flutterEmailSenderText: 'LIcensed under the Apache 2.0 license',
      AboutText.flutterEmailSenderUrl:
          'https://github.com/sidlatau/flutter_email_sender',
      AboutText.flutterCommunityTitle: 'Flutter Community Dev Packages',
      AboutText.flutterCommunityText:
          'get_it, rxdart developed by the Flutter Community Dev Team under the MIT license',
      AboutText.flutterCommunityUrl:
          'https://github.com/fluttercommunity/get_it/blob/master/LICENSE',
      AboutText.flutterLinkifyTitle: 'flutter_linkify by cretezy.com',
      AboutText.flutterLinkifyText: 'Licensed under the MIT license',
      AboutText.flutterLinkifyUrl:
          'https://github.com/Cretezy/flutter_linkify/blob/master/LICENSE',
      AboutText.archiveTitle:
          'archive by brendanduncan@gmail.com and kevmoo@google.com',
      AboutText.archiveText: 'Licensed under the Apache 2.0 license',
      AboutText.archiveUrl:
          'https://github.com/brendan-duncan/archive/blob/master/LICENSE',
      AboutText.scrollablePositionedListTitle:
          'scrollable_positioned_list by Google Dev team',
      AboutText.scrollablePositionedListText: 'Licensed under the BSD license',
      AboutText.scrollablePositionedListUrl:
          'https://github.com/google/flutter.widgets/blob/master/LICENSE',
      AboutText.permissionHandlerTitle: 'permissionHandler by baseflow.com',
      AboutText.permissionHandlerText: 'Licensed under the MIT license',
      AboutText.permissionHandlerUrl:
          'https://github.com/Baseflow/flutter-permission-handler/blob/master/LICENSE',
      AboutText.filePickerTitle: 'file_picker by miguelruivo.com',
      AboutText.filePickerText: 'Licensed under the MIT license',
      AboutText.filePickerUrl:
          'https://github.com/miguelpruivo/flutter_file_picker',
      AboutText.showcaseviewTitle: 'showcaseview by developer@simform.com',
      AboutText.showcaseviewText: 'Licensed under the BSD license',
      AboutText.showcaseviewUrl:
          'https://github.com/simformsolutions/flutter_showcaseview/blob/master/LICENSE',
      AboutText.oxoTitle: 'Lever and Button-Toggles',
      AboutText.oxoText: 'Images by Oxo, thank you!',
      AboutText.oxoUrl: 'On Discord @ Oxo#3515'
    }
  };
}
