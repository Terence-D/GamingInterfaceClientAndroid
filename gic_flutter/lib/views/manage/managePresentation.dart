import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/model/intl/intlManage.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/model/screen/Screen.dart';
import 'package:gic_flutter/model/screen/ScreenRepository.dart';
import 'package:gic_flutter/views/basePage.dart';
import 'package:gic_flutter/views/main/mainVM.dart';

import 'manageVM.dart';

class ManagePresentation implements BasePresentation {
  BaseState _contract;

  ManagePresentation(BaseState contract) {
    _contract = contract;
  }

  Future<void> buildVM(BuildContext context) async {
    ManageVM _viewModel = new ManageVM();

    _viewModel.toolbarTitle = Intl.of(context).manage(ManageText.toolbarTitle);
    _viewModel.btnDelete = Intl.of(context).manage(ManageText.buttonDelete);
    _viewModel.btnEdit =  Intl.of(context).manage(ManageText.buttonEdit);
    _viewModel.btnExport = Intl.of(context).manage(ManageText.buttonExport);
    _viewModel.btnImport = Intl.of(context).manage(ManageText.buttonImport);
    _viewModel.btnNew = Intl.of(context).manage(ManageText.buttonNew);
    _viewModel.btnUpdate = Intl.of(context).manage(ManageText.buttonUpdate);
    _viewModel.screenName = Intl.of(context).manage(ManageText.screenName);

    ScreenRepository screenRepo = new ScreenRepository();
    _viewModel.screens = new List();
    LinkedHashMap _screenListMap = await screenRepo.getScreenList();
    if (_screenListMap != null && _screenListMap.length > 0) {
      _screenListMap.forEach((k, v) => _viewModel.screens.add(new ScreenListItem(k, v)) );
    } else {
      _saveScreen(screenRepo, _viewModel, "Empty Screen", 0);
    }

    _contract.onLoadComplete(_viewModel);
  }

  void _saveScreen(ScreenRepository screenRepo, ManageVM _viewModel, String name, int id) {
    Screen newScreen = new Screen();
    newScreen.screenId = id;
    newScreen.name = name;
    screenRepo.save(newScreen);
    _viewModel.screens.add(new ScreenListItem(newScreen.screenId, newScreen.name));
  }

  void editScreen(int index) {

  }

  void newScreen() {

  }

  void importScreen() {}

  void updateScreenName(int index, String text) {}

  void deleteScreen(int index) {}

  void exportScreen(int index) {}
}
