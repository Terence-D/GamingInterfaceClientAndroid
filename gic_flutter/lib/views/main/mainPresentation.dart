import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/views/intro/introView.dart';

import 'mainRepo.dart';
import 'mainVM.dart';

abstract class MainViewContract {
  void onLoadComplete(MainVM viewModel);

  void setConnectingIndicator(bool show);
  void showMessage(String message);
}
  
class MainPresentation implements MainRepoContract {
  MainViewContract _view;
  MainRepo _repository;

  MainPresentation(this._view) {
    _repository = new MainRepo(this);
  }

  @override
  void preferencesLoaded(MainVM viewModel) {
    _view.onLoadComplete(viewModel);
  }

  void loadViewModel() {
    _repository.fetch(); //this will wind up calling the preferencesLoaded above
  }

  setDarkTheme(bool newValue) {
    _repository.setDarkMode(newValue);
  }

  getNewActivity(String activity) async {
    MethodChannel platform = new MethodChannel(Channel.channelView);
    try {
      await platform.invokeMethod(activity);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void startGame(String password, String address, String port, int selectedScreenId) async {
    if (password.length < 6) {
      _view.showMessage(Intl.mainPasswordError);
      return;
    }
    if (int.tryParse(port) == null) {
      _view.showMessage(Intl.mainInvalidPort);
      return;
    }
    _repository.saveMainSettings(address, port, password, selectedScreenId);
    getStartActivity(password, address, port, selectedScreenId);
  }


  getStartActivity(String password, String address, String port, int selectedScreenId) async {
    MethodChannel platform = new MethodChannel(Channel.channelView);
    try {
      await platform.invokeMethod(Channel.actionViewStart, {"password": password, "address": address, "port":port, "selectedScreenId": selectedScreenId});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void showIntro(BuildContext context) {
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => IntroView())
    );
  }
}