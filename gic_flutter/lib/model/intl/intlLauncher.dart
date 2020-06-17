import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/localizations.dart';

enum LauncherText {
  toolbarTitle,

  errorPort,
  errorPassword,
  errorServerInvalid,
  errorFirewall,
  errorVersion,
  errorOutOfDate,

  address,
  port,
  password,
  passwordWarning,
  start,
  close,
  next,

  buttonNew,
  buttonImport,
  buttonUpdate,
  buttonEdit,
  buttonExport,
  buttonDelete,
  screenName,

  helpIpAddress,
  helpPort,
  helpPassword,
  helpScreenManager,
  helpStart,
  helpNew,
  helpScreenList,
  helpExport,
  helpEdit,
  helpDelete,
  helpUpdate,
  helpImport,

  menuTheme,
  menuIntro,
  menuAbout,
  menuDonate,
  menuImport,

  deleteError,
  deleteConfirm,
  deleteConfirmTitle
}

class IntlLauncher {

  BuildContext _context;

  IntlLauncher(this ._context);

  String text(LauncherText text) {
    return _localizedStrings[Intl.of(_context).locale.languageCode][text];
  }

  static Map<String, Map<LauncherText, String>> _localizedStrings = {
    'en': {
      LauncherText.toolbarTitle: 'Graphical Interface Client',

      LauncherText.errorPassword: 'Invalid password, it must be at least 6 digits long',
      LauncherText.errorPort: 'Invalid Port Number',
      LauncherText.errorServerInvalid: 'Invalid Server Address',
      LauncherText.errorFirewall: 'Error connecting, check that the server is running and firewall ports opened',
      LauncherText.errorOutOfDate: 'There is a new version of GIC Server.  Please update it before continuing',
      LauncherText.errorVersion: 'Wrong Version',

      LauncherText.address: 'Address',
      LauncherText.port: 'Port',
      LauncherText.password: 'Password',
      LauncherText.passwordWarning: 'Warning - do NOT use an existing password that you use ANYWHERE else',

      LauncherText.close: 'Close',
      LauncherText.next: 'Next',
      LauncherText.start: 'Start',
      LauncherText.buttonNew: 'New',
      LauncherText.buttonImport: 'Import',
      LauncherText.buttonUpdate: 'Update Name',
      LauncherText.buttonDelete: 'Delete',
      LauncherText.buttonEdit: 'Edit',
      LauncherText.buttonExport: 'Share',
      LauncherText.screenName: 'Screen Name',

      LauncherText.helpNew: 'To add a new Screen, tap here',
      LauncherText.helpScreenList: 'You can change the name here, then tap on Update Name',
      LauncherText.helpImport: 'Tap here to Import an existing screen saved on your device',
      LauncherText.helpExport: 'Share your screen with others by exporting with this',
      LauncherText.helpEdit: 'This will open the Screen Editor',
      LauncherText.helpDelete: 'This will PERMANENTLY delete this screen',
      LauncherText.helpUpdate: 'After changing the name above, tap here to save the change',
      LauncherText.helpPort: '',

      LauncherText.deleteError: 'Cannot remove last screen!',
      LauncherText.deleteConfirm: 'Are you sure you wish to PERMANENTLY delete ',
      LauncherText.deleteConfirmTitle: 'Confirm Delete',

      LauncherText.menuAbout: 'About',
      LauncherText.menuDonate: 'Donate',
      LauncherText.menuIntro: 'Show Intro',
      LauncherText.menuTheme: 'Change Theme',
      LauncherText.menuImport: 'Import',
    }
  };
}