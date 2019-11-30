import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/views/intro/introPresentation.dart';
import 'package:gic_flutter/views/intro/introView.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'mainRepo.dart';
import 'mainVM.dart';

abstract class MainViewContract {
  void onLoadComplete(MainVM viewModel);
  void showOnboarding();

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
    _view.setConnectingIndicator(true);
    if (password.length < 6) {
      _view.showMessage(Intl.mainPasswordError);
      _view.setConnectingIndicator(false);
      return;
    }
    if (int.tryParse(port) == null) {
      _view.showMessage(Intl.mainInvalidPort);
      _view.setConnectingIndicator(false);
      return;
    }
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
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => IntroView())
    );
  }


// MainScreenState _state;
// ScreenListItem selectedScreen;
// static const String _Version = "\"1.3.0.0\"";

// String get toolbarTitle => _viewModel.toolbarTitle;
// String get screenTitle => _viewModel.screenTitle;
// bool get darkTheme => _viewModel.darkMode;
// bool get firstRun => _viewModel.firstRun;
// String get address => _viewModel.address;
// String get port => _viewModel.port;
// String get password => _viewModel.password;
// bool get donate => _viewModel.donate;
// bool get donateStar => _viewModel.donateStar;
// List<ScreenListItem> get screenList => _viewModel.screenList;
// int get selectedScreenID => _viewModel.selectedScreenId;

// MainPresentation(MainScreenState state, SettingRepository repo) {
//   _viewModel = new MainVM(repo);
//   _state = state;
// }



// Future<http.Response> _restGet(String address) async {
//   try {
//     return await http.get(address);
//   } catch (e) {
//     return Future.error(e);
//   }
// }

//   _viewModel.password = password;
//   _viewModel.address = address;
//   _viewModel.port = port;
//   _viewModel.selectedScreenId = selectedScreenId;
//   _viewModel.saveSettings();
//   String url = "http://" + address + ":" + port + "/api/Version";
  
//   try {
//     http.Response response = await _restGet(url);    
//     if (response == null)
//       _state.showMessage(Intl.mainFirewallError);
//     else if (response.statusCode == 200) {
//       if (response.body == _Version) {
//           _state.startGame();
//       } else {
//         _state.showUpgradeWarning();
//       }
//     } else {
//         _state.showMessage(response.statusCode.toString());
//     }
//   } catch (e) {
//         _state.showMessage(e.toString());
//   } finally {
//       _state.setConnectingIndicator(false);
//   }
// }


// Future _loadData(BuildContext context, {bool checkEmpty = false}) async {
//   await _viewModel.loadSettings(context);
//   _state.loadSettings();
//   if (_viewModel.screenList.length > 0)
//     selectedScreen = _viewModel.screenList[0];
//   else if (checkEmpty) {
//     Screen newScreen = new Screen();
//     newScreen.screenId = 0;
//     newScreen.name = "Screen";
//     Screens screens = new Screens();
//     await screens.save(newScreen);
//     await _viewModel.loadSettings(context); //reload
//     debugPrint("added empty screen by default");
//   }

//   _state.selectedScreen = selectedScreen;     
// }
}