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
    _viewModel.loadSettings();
    if (firstRun)
      getNewActivity(Channel.actionViewIntro);
  }

  getNewActivity(String activity) async {
    // MethodChannel platform = new MethodChannel(Channel.channelView);
    // try {
    //   await platform.invokeMethod(activity);
    // } on PlatformException catch (e) {
    //   print(e.message);
    // }
  }

  String get toolbarTitle => _viewModel.toolbarTitle;
  String get screenTitle => _viewModel.screenTitle;

  bool get firstRun => _viewModel.firstRun;
  String get address => _viewModel.address;
  String get port => _viewModel.port;
  String get password => _viewModel.password;
}
