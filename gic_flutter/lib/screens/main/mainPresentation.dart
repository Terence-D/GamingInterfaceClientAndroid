import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/mainVM.dart';
import 'package:gic_flutter/screens/main/main.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';

class MainPresentation {
  MainVM _viewModel;
  MainScreenState _state;
  static const String _Version = "\"1.3.0.0\"";

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

  getStartActivity() async {
    MethodChannel platform = new MethodChannel(Channel.channelView);
    try {
      await platform.invokeMethod(Channel.actionViewStart, {"password": password, "address": address, "port":port, "selectedScreenId": selectedScreenID});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<http.Response> _restGet(String address) async {
    try {
      return await http.get(address);
    } catch (e) {
      return Future.error(e);
    }
  }

  void startGame(String password, String address, String port, int selectedScreenId) async {
    _state.setConnectingIndicator(true);
    if (password.length < 6) {
        _state.showMessage("invalid password, it must be at least 6 digits long");
        _state.setConnectingIndicator(false);
        return;
    }
    if (int.tryParse(port) == null) {
        _state.showMessage("invalid port number");
        _state.setConnectingIndicator(false);
        return;
    }

    _viewModel.password = password;
    _viewModel.address = address;
    _viewModel.port = port;
    _viewModel.selectedScreenId = selectedScreenId;
    _viewModel.saveSettings();
    String url = "http://" + address + ":" + port + "/api/Version";
    
    try {
      http.Response response = await _restGet(url);    
      if (response == null)
        _state.showMessage("Error connecting, is the server running and firewall ports opened?");
      else if (response.statusCode == 200) {
        if (response.body == _Version) {
            _state.startGame();
        } else {
          _state.showUpgradeWarning();
        }
      } else {
          _state.showMessage(response.statusCode.toString());
      }
    } catch (e) {
          _state.showMessage(e.toString());
    } finally {
        _state.setConnectingIndicator(false);
    }
  }

  String get toolbarTitle => _viewModel.toolbarTitle;
  String get screenTitle => _viewModel.screenTitle;
  bool get darkTheme => _viewModel.darkMode;
  bool get firstRun => _viewModel.firstRun;
  String get address => _viewModel.address;
  String get port => _viewModel.port;
  String get password => _viewModel.password;
  bool get donate => _viewModel.donate;
  bool get donateStar => _viewModel.donateStar;
  List<ScreenListItem> get screenList => _viewModel.screenList;
  int get selectedScreenID => _viewModel.selectedScreenId;
  set darkTheme(bool newValue) => {
    _viewModel.darkMode = newValue
  };
}