import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/model/screen/gicControl.dart';
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
    await _upgradeDefaults();
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
  //update the default control values to be flutter compatible
  Future<void> _upgradeDefaults() async {
    MethodChannel platform = new MethodChannel(Channel.channelUtil);
    try {
      platform.invokeMethod(Channel.actionCheckDefaults);
    } on PlatformException catch (e) {
      print(e.message);
    }
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

  Future<bool> saveScreen(Screen toSave) async {
    LauncherModel _viewModel = new LauncherModel();
    ScreenRepository screenRepo = await _getScreenRepository(_viewModel);

    try {
      await screenRepo.save(toSave);
      _viewModel.screens.insert(0, new ScreenListItem(toSave.screenId, toSave.name));
    } catch (Exception) {
      return false;
    }

    return true;
  }

  Future<int> newScreen() async {
    LauncherModel _viewModel = new LauncherModel();
    await _getScreenRepository(_viewModel);
    int id = _getUniqueId(_viewModel);
    Screen newScreen = new Screen();
    newScreen.screenId = id;
    newScreen.name = "New Screen $id";

    if ( await saveScreen(newScreen) )
      return id;
    else
      return -1;
  }

  int _getUniqueId(LauncherModel _viewModel) {
    int id=0;
    for(int i=0; i < _viewModel.screens.length; i++) {
      if (id == _viewModel.screens[i].id) {
        id++;
        i = -1; //restart our search
      }
    }
    return id;
  }

  Future<ScreenRepository> _getScreenRepository(LauncherModel _viewModel) async {
    ScreenRepository screenRepo = new ScreenRepository();
    _viewModel.screens = new List();
    LinkedHashMap _screenListMap = await screenRepo.getScreenList();
    _screenListMap.forEach((k, v) => _viewModel.screens.add(new ScreenListItem(k, v)) );
    return screenRepo;
  }

  Future<int> deleteScreen(int id) async {
    LauncherModel _viewModel = new LauncherModel();
    ScreenRepository screenRepo = await _getScreenRepository(_viewModel);
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

  Future<List> checkScreenSize(int screenId) async {
    ScreenRepository screenRepo = new ScreenRepository();
    List<Screen> screens = await screenRepo.loadScreens();
    Screen screen = screens.singleWhere((element) => element.screenId == screenId);

    int orientation = 0;
    double furthestRight = 0;
    double furthestBottom = 0;

    screen.controls.forEach((element) {
      double rightPos = element.left + element.width;
      double bottomPos = element.top + element.height;
      if (rightPos > furthestRight)
        furthestRight = rightPos;
      if (bottomPos > furthestBottom)
        furthestBottom = bottomPos;
    });
    if (furthestRight > furthestBottom)
      orientation = 1;

    return [orientation, furthestRight, furthestBottom];
  }

  List buildDimensions(BuildContext context) {
    int orientation = 0;
    int width = 0;
    int height = 0;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      orientation = 0;
      width = (MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio).floor();
      height = (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).floor();
    } else {
      orientation = 1;
      height = (MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio).floor();
      width = (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).floor();
    }
    return [orientation, width, height];
  }

  Future<int> resizeScreen(oldId, BuildContext context) async {
    List screenInfo = await checkScreenSize(oldId);
    List deviceInfo = buildDimensions(context);

    //check if we need to rotate dimensions
    if (deviceInfo[0] != screenInfo[0]) {
      double temp = screenInfo[1];
      screenInfo[1] = screenInfo[2];
      screenInfo[2] = temp;
    }

    double adjustX = deviceInfo[1] / screenInfo[1];
    double adjustY = deviceInfo[2] / screenInfo[2];

    LauncherModel _viewModel = new LauncherModel();
    ScreenRepository screenRepo = await _getScreenRepository(_viewModel);
    List<Screen> screens = await screenRepo.loadScreens();
    Screen oldScreen = screens.singleWhere((element) => element.screenId == oldId);
    Screen newScreen = oldScreen;
    newScreen.screenId = _getUniqueId(_viewModel);
    newScreen.name += " resized";

    newScreen.controls.forEach((element) {
      element.left = element.left * adjustX;
      element.width = (element.width * adjustX).round();
      element.top = element.top * adjustY;
      element.height = (element.height * adjustY).round();
    });

    await screenRepo.save(newScreen);
    return newScreen.screenId;
  }
}