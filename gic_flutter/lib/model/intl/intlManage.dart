enum ManageText {
  toolbarTitle,
  buttonNew,
  buttonImport,
  buttonUpdate,
  buttonEdit,
  buttonExport,
  buttonDelete,
  screenName,
  helpNew,
  helpScreenList,
  helpExport,
  helpEdit,
  helpDelete,
  helpUpdate,
  helpImport
}

class IntlManage {
  static Map<String, Map<ManageText, String>> localizedStrings = {
    'en': {
      ManageText.toolbarTitle: 'Screen Manager',
      ManageText.buttonNew: 'New',
      ManageText.buttonImport: 'Import',
      ManageText.buttonUpdate: 'Update Name',
      ManageText.buttonDelete: 'Delete',
      ManageText.buttonEdit: 'Edit',
      ManageText.buttonExport: 'Share',
      ManageText.screenName: 'Screen Name',

      ManageText.helpNew: 'To add a new Screen, tap here',
      ManageText.helpScreenList: 'You can change the name here, then tap on Update Name',
      ManageText.helpImport: 'Tap here to Import an existing screen saved on your device',
      ManageText.helpExport: 'Share your screen with others by exporting with this',
      ManageText.helpEdit: 'This will open the Screen Editor',
      ManageText.helpDelete: 'This will PERMANENTLY delete this screen',
      ManageText.helpUpdate: 'After changing the name above, tap here to save the change'
    }
  };
}