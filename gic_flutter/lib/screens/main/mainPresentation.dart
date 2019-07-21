import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/mainVM.dart';
import 'package:gic_flutter/screens/main/main.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';

class MainPresentation {
  MainVM _viewModel;
  MainScreenState _state;

  MainPresentation(MainScreenState state, SettingRepository repo) {
    _viewModel = new MainVM(repo);
    _state = state;
  }

  Future loadSettings() async {
    await _viewModel.loadSettings();
    if (firstRun)
      getNewActivity(Channel.actionViewIntro);
  }

  getNewActivity(String activity) async {
    MethodChannel platform = new MethodChannel(Channel.channelView);
    try {
      await platform.invokeMethod(activity);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  // Future<LinkedHashMap> asyncgetScreenList() async {
  //   MethodChannel platform = new MethodChannel(Channel.channelUtil);
  //   try {
  //     final LinkedHashMap result = await platform.invokeMethod(Channel.actionUtilGetScreens);
  //     debugPrint(result.toString());
  //     return result;
  //   } on PlatformException catch (e) {
  //     print(e.message);
  //   }
  //   return null;
  // }

  String get toolbarTitle => _viewModel.toolbarTitle;
  String get screenTitle => _viewModel.screenTitle;
  bool get darkTheme => _viewModel.darkMode;
  bool get firstRun => _viewModel.firstRun;
  String get address => _viewModel.address;
  String get port => _viewModel.port;
  String get password => _viewModel.password;
  List<ScreenListItem> get screenList => _viewModel.screenList;
  set darkTheme(bool newValue) => {
    _viewModel.darkMode = newValue
  };
}
