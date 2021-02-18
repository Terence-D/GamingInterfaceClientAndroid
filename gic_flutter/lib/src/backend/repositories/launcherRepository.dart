import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/src/backend/models/launcherModel.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/screen.dart';
import 'package:gic_flutter/src/backend/services/cryptoService.dart';
import 'package:gic_flutter/src/backend/services/screenService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LauncherRepository {
  SharedPreferences _prefs;
  ScreenService _screenService = new ScreenService();

  static const String _prefNightMode = "nightMode";
  static const String _prefPassword = "password";
  static const String _prefPort = "port";
  static const String _prefAddress = "address";
  static const String _prefConvertB =
      "legacyConvertScreensB"; //show the whole intro thing
  static const String _prefDonate = "coffee";
  static const String _prefDonateStar = "star";
  static const String _prefsScreen = "screen_";

  /// Startup method, retrieves pay and version settings
  /// Once done will load in the viewmodel
  Future<LauncherModel> fetch() async {
    _prefs = await SharedPreferences.getInstance();

    /// convert legacy screen
    if (_prefs.getBool(_prefConvertB) ?? true) {
      _prefs.setBool(_prefConvertB, false);
      await _convertLegacyScreens();
    }
    return await _loadVM();
  }

  /// Save the primary server related settings
  /// Based on the network model
  void saveMainSettings(NetworkModel networkModel) async {
    if (networkModel.address != null && networkModel.port.isNotEmpty) {
      _prefs.setString(_prefAddress, networkModel.address);
    }
    if (networkModel.port != null &&
        networkModel.port.isNotEmpty &&
        _isNumeric(networkModel.port)) {
      _prefs.setString(_prefPort, networkModel.port);
    }
    if (networkModel.password != null && networkModel.password.isNotEmpty) {
      _prefs.setString(
          _prefPassword, await _encryptPassword(networkModel.password));
    }
  }

  /// Updates the screen name for the matching ID
  Future updateName(int id, String newName) async {
    _screenService.screenViewModels.forEach((screen) {
      if (screen.screenId == id) {
        screen.name = newName;
        screen.save(jsonOnly: true);
      }
    });
  }

  /// Toggles dark mode based on newValue
  void setDarkMode(bool newValue) {
    _prefs.setBool(_prefNightMode, newValue);
  }

  /// Save the screen
  Future<bool> saveScreen(Screen toSave) async {
    LauncherModel _viewModel = new LauncherModel();
    ScreenRepository screenRepo = await _getScreenRepository(_viewModel);

    try {
      await screenRepo.save(screen: toSave);
      _viewModel.screens
          .insert(0, new ScreenListItem(toSave.screenId, toSave.name));
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

    if (await saveScreen(newScreen))
      return id;
    else
      return -1;
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
    Screen screen =
        screens.singleWhere((element) => element.screenId == screenId);

    int orientation = 0;
    double furthestRight = 0;
    double furthestBottom = 0;

    screen.controls.forEach((element) {
      double rightPos = element.left + element.width;
      double bottomPos = element.top + element.height;
      if (rightPos > furthestRight) furthestRight = rightPos;
      if (bottomPos > furthestBottom) furthestBottom = bottomPos;
    });
    if (furthestRight > furthestBottom) orientation = 1;

    return [orientation, furthestRight, furthestBottom];
  }

  List buildDimensions(BuildContext context) {
    int orientation = 0;
    int width = 0;
    int height = 0;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      orientation = 0;
      width = (MediaQuery.of(context).size.height *
              MediaQuery.of(context).devicePixelRatio)
          .floor();
      height = (MediaQuery.of(context).size.width *
              MediaQuery.of(context).devicePixelRatio)
          .floor();
    } else {
      orientation = 1;
      height = (MediaQuery.of(context).size.height *
              MediaQuery.of(context).devicePixelRatio)
          .floor();
      width = (MediaQuery.of(context).size.width *
              MediaQuery.of(context).devicePixelRatio)
          .floor();
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
    Screen oldScreen =
        screens.singleWhere((element) => element.screenId == oldId);
    Screen newScreen = oldScreen;
    newScreen.screenId = _getUniqueId(_viewModel);
    newScreen.name += " resized";

    newScreen.controls.forEach((element) {
      element.left = element.left * adjustX;
      element.width = (element.width * adjustX).round();
      element.top = element.top * adjustY;
      element.height = (element.height * adjustY).round();
    });

    await screenRepo.save(screen: newScreen);
    return newScreen.screenId;
  }

  Future<Screen> loadScreen(int screenId) async {
    LauncherModel _viewModel = new LauncherModel();
    ScreenRepository screenRepo = await _getScreenRepository(_viewModel);
    Screen toReturn = new Screen();
    List<Screen> screens = await screenRepo.loadScreens();
    screens.forEach((element) {
      if (element.screenId == screenId) toReturn = element;
    });
    return toReturn;
  }

  _loadVM() async {
    LauncherModel viewModel = new LauncherModel();

    //get encrypted password
    viewModel.password = await _getPassword();

    //load screens
    if (await _screenService.loadScreens()) {
      viewModel.screens = new List();
      if (_screenService.screenViewModels.length < 1) {
        _screenService.createScreen();
        _screenService.activeScreenViewModel.save();
      }
      _screenService.screenViewModels.forEach((element) {
        viewModel.screens
            .add(new ScreenListItem(element.screenId, element.name));
      });
      viewModel.screens
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
    //TODO ALL OF IT
  }

  Future<String> _getPassword() async {
    String encrypted = _prefs.getString(_prefPassword) ?? "";
    try {
      return CryptoService.decrypt(encrypted);
    } catch (Exception) {
      //will probably fail on legacy
      return "";
    }
  }

  Future<String> _encryptPassword(String password) async {
    return CryptoService.encrypt(password);
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  int _getUniqueId(LauncherModel _viewModel) {
    int id = 0;
    for (int i = 0; i < _viewModel.screens.length; i++) {
      if (id == _viewModel.screens[i].id) {
        id++;
        i = -1; //restart our search
      }
    }
    return id;
  }

  Future<ScreenRepository> _getScreenRepository(
      LauncherModel _viewModel) async {
    ScreenRepository screenRepo = new ScreenRepository();
    _viewModel.screens = new List();
    LinkedHashMap _screenListMap = await screenRepo.getScreenList();
    _screenListMap
        .forEach((k, v) => _viewModel.screens.add(new ScreenListItem(k, v)));
    return screenRepo;
  }
}
