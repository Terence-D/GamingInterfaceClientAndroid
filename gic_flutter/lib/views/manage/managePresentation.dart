import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/intlManage.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/model/screen/Screen.dart';
import 'package:gic_flutter/model/screen/ScreenRepository.dart';
import 'package:gic_flutter/views/basePage.dart';
import 'package:gic_flutter/views/main/mainVM.dart';

import 'manageVM.dart';

class ManagePresentation implements BasePresentation {
  BaseState _contract;
  ManageVM _viewModel;

  ManagePresentation(BaseState contract) {
    _contract = contract;
  }

  Future<void> buildVM(BuildContext context) async {
    _viewModel = new ManageVM();

    _viewModel.toolbarTitle = Intl.of(context).manage(ManageText.toolbarTitle);
    _viewModel.btnDelete = Intl.of(context).manage(ManageText.buttonDelete);
    _viewModel.btnEdit =  Intl.of(context).manage(ManageText.buttonEdit);
    _viewModel.btnExport = Intl.of(context).manage(ManageText.buttonExport);
    _viewModel.btnImport = Intl.of(context).manage(ManageText.buttonImport);
    _viewModel.btnNew = Intl.of(context).manage(ManageText.buttonNew);
    _viewModel.btnUpdate = Intl.of(context).manage(ManageText.buttonUpdate);
    _viewModel.screenName = Intl.of(context).manage(ManageText.screenName);
    _viewModel.helpImport = Intl.of(context).manage(ManageText.helpImport);
    _viewModel.helpNew  = Intl.of(context).manage(ManageText.helpNew);
    _viewModel.helpScreenList = Intl.of(context).manage(ManageText.helpScreenList);
    _viewModel.helpEdit = Intl.of(context).manage(ManageText.helpEdit);
    _viewModel.helpExport = Intl.of(context).manage(ManageText.helpExport);
    _viewModel.helpDelete = Intl.of(context).manage(ManageText.helpDelete);
    _viewModel.helpUpdate = Intl.of(context).manage(ManageText.helpUpdate);
    _viewModel.deleteError = Intl.of(context).manage(ManageText.deleteError);
    _viewModel.deleteConfirm = Intl.of(context).manage(ManageText.deleteConfirm);
    _viewModel.deleteConfirmTitle = Intl.of(context).manage(ManageText.deleteConfirmTitle);

    ScreenRepository screenRepo = new ScreenRepository();
    _viewModel.screens = new List();
    LinkedHashMap _screenListMap = await screenRepo.getScreenList();
    if (_screenListMap != null && _screenListMap.length > 0) {
      _screenListMap.forEach((k, v) => _viewModel.screens.insert(0, new ScreenListItem(k, v)) );
    } else {
      _saveScreen(screenRepo, "Empty Screen", 0);
    }

    _contract.onLoadComplete(_viewModel);
  }

  void _saveScreen(ScreenRepository screenRepo, String name, int id) {
    Screen newScreen = new Screen();
    newScreen.screenId = id;
    newScreen.name = name;
    screenRepo.save(newScreen);
    _viewModel.screens.insert(0, new ScreenListItem(newScreen.screenId, newScreen.name));
  }

  void editScreen(int index) {

  }

  void newScreen() {
    int id=0;
    for(int i=0; i < _viewModel.screens.length; i++) {
      if (id == _viewModel.screens[i].id) {
        id++;
        i = -1; //restart our search
      }
    }
    ScreenRepository screenRepo = new ScreenRepository();
    _saveScreen(screenRepo, "New Screen $id", id);
    _contract.onLoadComplete(_viewModel);
  }

  Future<void> updateScreenName(int index, String text) async {
    ScreenRepository screenRepo = new ScreenRepository();
    for(int i=0; i < _viewModel.screens.length; i++) {
      if (i == index) {
        screenRepo.updateName(
            _viewModel.screens[i].id,
            text
        );
        break;
      }
    }
  }

  void deleteScreen(int index) async {
    ScreenRepository screenRepo = new ScreenRepository();

    for(int i=0; i < _viewModel.screens.length; i++) {
      if (i == index) {
        int rv = await screenRepo.delete(_viewModel.screens[i].id);
        if (rv < 0) {
          _contract.onError(1);
        } else {
          _viewModel.screens.removeAt(i);
          _contract.onLoadComplete(_viewModel);
        }
        break;
      }
    }
  }

  void exportScreen(int index) {

  }

  void importScreen() {

  }

}
