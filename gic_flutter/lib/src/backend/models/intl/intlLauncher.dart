import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/localizations.dart';

enum LauncherText {
  toolbarTitle,

  errorPort,
  errorPassword,
  errorServerInvalid,
  errorServerError,
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
  helpScreenName,
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
  deleteConfirmTitle,
  deleteComplete,

  exportComplete,
  importComplete,
  nameUpdated,

  loading,
  yes,
  no,
  resize,
  cont,
  recommendResize,
  saveToFolder,
  saveToFolderPickText,
  resizeScreen,
  resizeScreenText
}

class IntlLauncher {
  BuildContext _context;

  IntlLauncher(this._context);

  String text(LauncherText text) {
    return _localizedStrings[Intl.of(_context).locale.languageCode][text];
  }

  static Map<String, Map<LauncherText, String>> _localizedStrings = {
    'en': {
      LauncherText.toolbarTitle: 'Graphical Interface Client',
      LauncherText.errorPassword:
          'Invalid password, it must be at least 6 digits long',
      LauncherText.errorPort: 'Invalid Port Number',
      LauncherText.errorServerInvalid: 'Invalid Server Address',
      LauncherText.errorServerError: 'Server Error: ',
      LauncherText.errorFirewall:
          'Error connecting, check that the server is running and firewall ports opened',
      LauncherText.errorOutOfDate:
          'There is a new version of GIC Server.  Please update it before continuing.  Visit https://github.com/Terence-D/GamingInterfaceCommandServer/releases on your computer or click the button below to send an email to yourself.',
      LauncherText.errorVersion: 'Wrong Version',
      LauncherText.address: 'Address',
      LauncherText.port: 'Port',
      LauncherText.password: 'Password',
      LauncherText.passwordWarning:
          'Warning - do NOT use an existing password that you use ANYWHERE else',
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
      LauncherText.helpNew: 'Tap to add a new Screen',
      LauncherText.helpUpdate: 'Tap to save a new name',
      LauncherText.helpExport: 'Tap to Share your Screen',
      LauncherText.helpEdit: 'Tap to Edit the Screen',
      LauncherText.helpDelete: 'Tap to PERMANENTLY delete this screen',
      LauncherText.helpPort: 'Must Match the Server. Default is 8091',
      LauncherText.helpIpAddress:
          'Network/IP Address of the server. (192.x...)',
      LauncherText.helpPassword: 'Must Match the Server',
      LauncherText.helpScreenName: 'Enter a new name',
      LauncherText.helpStart: 'Tapping to start using the Screen!',
      LauncherText.deleteError: 'Cannot remove last screen!',
      LauncherText.deleteConfirm:
          'Are you sure you wish to PERMANENTLY delete ',
      LauncherText.deleteConfirmTitle: 'Confirm Delete',
      LauncherText.deleteComplete: 'Screen removed',
      LauncherText.menuAbout: 'About',
      LauncherText.menuDonate: 'Donate',
      LauncherText.menuIntro: 'Show Intro',
      LauncherText.menuTheme: 'Change Theme',
      LauncherText.menuImport: 'Import',
      LauncherText.exportComplete: 'Export completed',
      LauncherText.importComplete: 'Import completed',
      LauncherText.nameUpdated: 'Name Updated',
      LauncherText.loading: 'Locating Server, Please Wait',
      LauncherText.yes: 'Yes',
      LauncherText.no: 'No',
      LauncherText.resize: 'Resize',
      LauncherText.cont: 'Continue',
      LauncherText.recommendResize:
          'Note it is recommended to rotate your device for using this screen',
      LauncherText.saveToFolder: 'Save to folder',
      LauncherText.saveToFolderPickText: 'Save file to this folder',
      LauncherText.resizeScreen: 'Resize Screen',
      LauncherText.resizeScreenText:
          'This appears to be made for a larger device - would you like to adjust the screen to fit your devices dimensions?    Note this will create a new screen with the new dimensions and launch that.'
    }
  };
}
