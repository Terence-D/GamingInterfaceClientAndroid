import 'dart:collection';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_picker/flutter_document_picker.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/intl/intlManage.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/model/screen/Screen.dart';
import 'package:gic_flutter/model/screen/ScreenRepository.dart';
import 'package:gic_flutter/views/basePage.dart';
import 'package:gic_flutter/views/main/mainVM.dart';

import 'manageVM.dart';

class ManagePresentation implements BasePresentation {
  BaseState _contract;
  ManageVM _viewModel = new ManageVM();
  ScreenRepository _screenRepo = new ScreenRepository();

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

    _viewModel.screens = new List();
    LinkedHashMap _screenListMap = await _screenRepo.getScreenList();
    if (_screenListMap != null && _screenListMap.length > 0) {
      _screenListMap.forEach((k, v) => _viewModel.screens.add(new ScreenListItem(k, v)) );
    } else {
      _saveScreen("Empty Screen", 0);
    }

    _contract.onLoadComplete(_viewModel);
  }

  Future<void> editScreen() async {
    MethodChannel platform = new MethodChannel(Channel.channelView);
    try {
      await platform.invokeMethod(Channel.actionViewEditor, {"selectedScreenId": _viewModel.selectedScreen.id});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void newScreen() {
    _saveScreen(_getUniqueName("New"), _getUniqueId(0));
  }

  Future<void> importScreen() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 19) {
        FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
          allowedFileExtensions: ['zip'],
          allowedMimeTypes: ['application/zip'],
          invalidFileNameSymbols: ['/'],
        );

        final path = await FlutterDocumentPicker.openDocument(params: params);
        _screenRepo.import(path);
      }
    }
  }

  void updateScreen(String text) {

  }

  void deleteScreen() {}

  void exportScreen() {}

  void _saveScreen(String name, int id) {
    Screen newScreen = new Screen();
    newScreen.screenId = id;
    newScreen.name = name;
    _screenRepo.save(newScreen);
    _viewModel.screens.add(new ScreenListItem(newScreen.screenId, newScreen.name));
  }

  String _getUniqueName(String startingName) {
    _viewModel.screens.forEach((screen) {
      if (startingName == screen.name)
        startingName += "1";
      startingName = _getUniqueName(startingName);
    });
    return startingName;
  }

  int _getUniqueId(int startingId) {
    int unique = startingId;

    if (_viewModel.screens != null) {
      _viewModel.screens.forEach((screen) {
        if (unique == screen.id)
          unique = _getUniqueId(startingId);
      });
    }
    return unique;
  }

}
