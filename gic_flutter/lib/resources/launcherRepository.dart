import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/model/screen/screen.dart';
import 'package:gic_flutter/resources/screenRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LauncherRepository {
  SharedPreferences _prefs;

  static const String _prefNightMode = "nightMode";
  static const String _prefPassword = "password";
  static const String _prefPort = "port";
  static const String _prefAddress = "address";
  static const String _prefConvertB = "legacyConvertScreens"; //show the whole intro thing
//  static const String _prefSelectedScreenId = "chosenId";
  static const String _prefDonate = "coffee";
  static const String _prefDonateStar = "star";
  static const String _prefsScreen = "screen_";
//  static const String _prefsBackgroundSuffix = "_background";
//  static const String _prefsBackgroundPathSuffix = "_background_path";
//  static const String _prefsControl = "_control_";

  Future<LauncherModel> fetch() async {
    _prefs = await SharedPreferences.getInstance();

    bool convertScreens = _prefs.getBool(_prefConvertB) ?? true;
    if (convertScreens) {
      _prefs.setBool(_prefConvertB, false);
      return await _convertLegacyScreens();
    } else {
      return await _loadVM();
    }
  }

  _loadVM() async {
    LauncherModel viewModel = new LauncherModel();

    //get encrypted password
    viewModel.password = await _getPassword();

    //load screens
    ScreenRepository screenRepo = new ScreenRepository();
    viewModel.screens = new List();
    LinkedHashMap _screenListMap = await screenRepo.getScreenList();
    if (_screenListMap != null && _screenListMap.length > 0) {
      _screenListMap.forEach((k, v) => viewModel.screens.add(new ScreenListItem(k, v)) );
      viewModel.screens.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      Screen newScreen = new Screen();
      newScreen.screenId = 0;
      newScreen.name = "Empty Screen";
      screenRepo.save(newScreen);
      viewModel.screens.add(new ScreenListItem(newScreen.screenId, newScreen.name));
    }

    //get generic info
    viewModel.darkMode = _prefs.getBool(_prefNightMode) ?? true;
    viewModel.port = _prefs.getString(_prefPort) ?? "8091";
    viewModel.address = _prefs.getString(_prefAddress) ?? "192.168.x.x";

    //donation settings
    if (_prefs.containsKey(_prefDonate))
      viewModel.donate = _prefs.getBool(_prefDonate);
    else {
      viewModel.donate = false;
    }

    if (_prefs.containsKey(_prefDonateStar))
      viewModel.donateStar = _prefs.getBool(_prefDonateStar);
    else {
      viewModel.donateStar = false;
    }

    return viewModel;
  }

  _convertLegacyScreens() async {
    MethodChannel platform = new MethodChannel(Channel.channelUtil);
    try {
      platform.invokeMethod(Channel.actionUtilUpdateScreens);
    } on PlatformException catch (e) {
      print(e.message);
    }
    return _loadVM();
  }

  //calls legacy code
  Future<String> _getPassword() async {
    String response = "";
    String encrypted = _prefs.getString(_prefPassword) ?? "";

    const platform = const MethodChannel(Channel.channelUtil);
    if (encrypted.isNotEmpty) {
      try {
        response = await platform.invokeMethod(Channel.actionUtilDecrypt, {"code": encrypted});
      } on PlatformException catch (_) {
        response = "";
      }
    }
    return response;
  }

  Future<String> _encryptPassword(String password) async {
    String response = "";

    const platform = const MethodChannel(Channel.channelUtil);
    if (password.isNotEmpty) {
      try {
        final String result = await platform.invokeMethod(Channel.actionUtilEncrypt, {"password": password});
        response = result;
      } on PlatformException catch (_) {
        response = "";
      }
    }
    return response;
  }

  bool _isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  saveMainSettings(String address, String port, String password) async {
    if (address != null && port.isNotEmpty) {
      _prefs.setString(_prefAddress, address);
    }
    if (port != null && port.isNotEmpty && _isNumeric(port)) {
      _prefs.setString(_prefPort, port);
    }
    if (password != null && password.isNotEmpty) {
      _prefs.setString(_prefPassword, await _encryptPassword(password));
    }
  }

  updateName (int id, String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("$_prefsScreen$id", newName);
  }

  setDarkMode(bool newValue) {
    _prefs.setBool(_prefNightMode, newValue);
  }

  Future<int> newScreen() async {
    LauncherModel _viewModel = new LauncherModel();
    ScreenRepository screenRepo = await _getScreen(_viewModel);

    int id=0;
    for(int i=0; i < _viewModel.screens.length; i++) {
      if (id == _viewModel.screens[i].id) {
        id++;
        i = -1; //restart our search
      }
    }
    Screen newScreen = new Screen();
    newScreen.screenId = id;
    newScreen.name = "New Screen $id";
    await screenRepo.save(newScreen);
    _viewModel.screens.insert(0, new ScreenListItem(newScreen.screenId, newScreen.name));

    return id;
  }

  Future<ScreenRepository> _getScreen(LauncherModel _viewModel) async {
    ScreenRepository screenRepo = new ScreenRepository();
    _viewModel.screens = new List();
    LinkedHashMap _screenListMap = await screenRepo.getScreenList();
    _screenListMap.forEach((k, v) => _viewModel.screens.add(new ScreenListItem(k, v)) );
    return screenRepo;
  }

  Future<int> deleteScreen(int id) async {
    LauncherModel _viewModel = new LauncherModel();
    ScreenRepository screenRepo = await _getScreen(_viewModel);
    int rv = await screenRepo.delete(id);

    return rv;
  }

  Future<int> import(file) async {
    ScreenRepository screenRepo = new ScreenRepository();
    return screenRepo.import(file);
  }

  Future<int> export(String exportPath, int id) {
    ScreenRepository screenRepo = new ScreenRepository();
    return screenRepo.export(exportPath, id);
  }
}