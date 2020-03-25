enum ManageText {
  toolbarTitle,
  buttonNew,
  buttonImport,
  buttonUpdate,
  buttonEdit,
  buttonExport,
  buttonDelete,
  screenName
}

class IntlManage {
  static Map<String, Map<ManageText, String>> localizedStrings = {
    'en': {
      ManageText.toolbarTitle: 'Screen Manager',
      ManageText.buttonNew: 'New',
      ManageText.buttonImport: 'Import',
      ManageText.buttonUpdate: 'Update',
      ManageText.buttonDelete: 'Delete',
      ManageText.buttonEdit: 'Edit',
      ManageText.buttonExport: 'Export',
      ManageText.screenName: 'Screen Name',
    }
  };
}