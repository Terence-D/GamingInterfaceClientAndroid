import 'dart:core';

import 'package:gic_flutter/model/viewModel.dart';
import 'package:gic_flutter/views/main/mainVM.dart';

class ManageVM implements ViewModel {
  String toolbarTitle = "";
  String btnNew = "";
  String btnImport = "";
  String btnUpdate = "";
  String btnEdit = "";
  String btnExport = "";
  String btnDelete  = "";
  String screenName = "";
  String helpNew = "";
  String helpImport = "";
  String helpExport = "";
  String helpEdit = "";
  String helpDelete = "";
  String helpUpdate = "";
  String helpScreenList = "";
  String deleteError = "";
  String deleteConfirm = "";
  String deleteConfirmTitle = "";

  List<ScreenListItem> screens;
  ScreenListItem selectedScreen;

}

