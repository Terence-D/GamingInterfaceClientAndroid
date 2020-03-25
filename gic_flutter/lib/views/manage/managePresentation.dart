import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/model/intl/intlManage.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
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

    _viewModel.screens = new List<ScreenListItem>();

    _contract.onLoadComplete(_viewModel);
  }

  void editScreen() {

  }

  void newScreen() {

  }

  void importScreen() {}

  void updateScreen(String text) {}

  void deleteScreen() {}

  void exportScreen() {}
}
