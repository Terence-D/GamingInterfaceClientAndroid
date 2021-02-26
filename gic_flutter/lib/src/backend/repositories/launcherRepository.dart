import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/src/backend/models/launcherModel.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/screen.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/repositories/screenRepository.dart';
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
  static const String _prefConvertB = "legacyConvertScreensB";
  static const String _prefDonate = "coffee";
  static const String _prefDonateStar = "star";

  /// Startup method, retrieves pay and version settings
  /// Once done will load in the view model
  Future<LauncherModel> fetch() async {
    _prefs = await SharedPreferences.getInstance();

    /// convert legacy screen
    if (_prefs.getBool(_prefConvertB) ?? true) {
      await _convertLegacyScreens();
      _prefs.setBool(_prefConvertB, false);
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

  /// Remove the matching screen
  Future<int> deleteScreen(int id) async {
    return await _screenService.deleteScreen(id);
  }

  /// Imports a screen based on supplied file value
  Future<int> import(String file) async {
    return _screenService.import(file);
  }

  /// Exports the screen with matching id to the export path
  Future<int> export(String exportPath, int id) async {
    _screenService.setActiveScreen(id);
    return _screenService.activeScreenViewModel.export(exportPath);
  }

  /// Checks the screen with matching ids dimensions and returns an array with
  /// orientation, width, and height values.  Used to calculate if we have to
  /// resize.
  Future<List> checkScreenSize(int screenId) async {
    _screenService.setActiveScreen(screenId);

    int orientation = 0;
    double furthestRight = 0;
    double furthestBottom = 0;

    _screenService.activeScreenViewModel.controls.forEach((element) {
      double rightPos = element.left + element.width;
      double bottomPos = element.top + element.height;
      if (rightPos > furthestRight) furthestRight = rightPos;
      if (bottomPos > furthestBottom) furthestBottom = bottomPos;
    });
    if (furthestRight > furthestBottom) orientation = 1;

    return [orientation, furthestRight, furthestBottom];
  }

  /// Gets our devices dimensions and returns an array with orientation, width,
  /// and height
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

  /// Resizes the chosen screens dimensions
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

    _screenService.duplicateScreen(oldId);

    _screenService.activeScreenViewModel.controls.forEach((control) {
      control.left = control.left * adjustX;
      control.width = (control.width * adjustX);
      control.top = control.top * adjustY;
      control.height = (control.height * adjustY);
    });
    _screenService.activeScreenViewModel.save(jsonOnly: true);
    return _screenService.activeScreenViewModel.screenId;
  }

  /// sets us to use the currently active screen
  ScreenViewModel setActiveScreen(int screenId) {
    _screenService.setActiveScreen(screenId);
    return _screenService.activeScreenViewModel;
  }

  /// Build our view model
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
    ScreenRepository legacy = new ScreenRepository();
    List<Screen> legacyScreens = await legacy.loadScreens();
    legacyScreens.forEach((element) async {
      ScreenViewModel screenViewModel = ScreenViewModel.fromLegacyModel(element);
      await screenViewModel.save();
    });
  }

  /// Returns a decrypted password
  Future<String> _getPassword() async {
    String encrypted = _prefs.getString(_prefPassword) ?? "";
    try {
      return CryptoService.decrypt(encrypted);
    } catch (Exception) {
      //will probably fail on legacy
      return "";
    }
  }

  /// returns an encrypted string based on the passed in string
  Future<String> _encryptPassword(String password) async {
    return CryptoService.encrypt(password);
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
