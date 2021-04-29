//this service handles the backend work required for screen editor view
//for now going with a simple service layer

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/screen/controlDefaults.dart';
import 'package:gic_flutter/src/backend/models/screen/screen.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/services/compressedFileService.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenService {
  //sub folders where we store resources
  static String backgroundImageFolder = "backgrounds";
  static String controlImageFolder = "controls";
  static String screenFolder = "screens";

  //current screen working with
  ScreenViewModel activeScreenViewModel;

  //list of all screens available
  List<ScreenViewModel> screenViewModels = [];

  //default control values to use
  ControlDefaults defaultControls;

  //snap to grid feature for the editor
  final String _prefGridSize = "prefGridSize";
  int gridSize = 0;

  //constructor
  ScreenService();

  /// Initialize our service with values from preferences
  Future initDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (activeScreenViewModel == null) //didn't load anything in, lets do it here
      loadScreens();

    defaultControls = new ControlDefaults(prefs, activeScreenViewModel.screenId);
    gridSize = prefs.getInt(_prefGridSize);
    if (gridSize == null) gridSize = 0;
  }

  // Sets which screen we are using as active
  // Returns true on success, false when no matching screen id is found
  bool setActiveScreen(int screenId) {
    bool rv = false;
    if (screenViewModels != null && screenViewModels.isNotEmpty)
      screenViewModels.forEach((element) {
        if (element.screenId == screenId) {
          activeScreenViewModel = element;
          rv = true;
        }
      });
    return rv;
  }

  // void addControl(Offset localPosition, BuildContext context) {
  //     pixelRatio = MediaQuery.of(context).devicePixelRatio;
  //     final double statusBarHeight = MediaQuery.of(context).padding.top;
  //     final double x = gridSize * (localPosition.dx / gridSize) + statusBarHeight;
  //     final double y = gridSize * (localPosition.dy / gridSize);
  //
  //     ControlViewModel toAdd = ControlViewModel.fromModel(defaultControls.defaultButton);
  //     toAdd.left = x;
  //     toAdd.top = y;
  //     screen.controls.add(toAdd);
  // }

  /// Load in all screens
  /// Returns true on success, false on any failure
  Future<bool> loadScreens() async {
    try {
      if (screenViewModels == null)
        screenViewModels = [];
      else
        screenViewModels.clear();
      final Directory appSupportPath = await getApplicationDocumentsDirectory();
      String screenPath = path.join(appSupportPath.path, screenFolder);

      if (!Directory(screenPath).existsSync()) {
        new Directory(screenPath).createSync(recursive: true);
      } else {
        Directory screenDirectory = new Directory(screenPath);

        Stream stream = screenDirectory.list();
        await stream.forEach((element) {
          File file = File(path.join(element.path, "data.json"));
          screenViewModels.add(
              ScreenViewModel.fromJson(json.decode(file.readAsStringSync())));
        }).catchError((error, stackTrace) => {
          print("test")
        }).whenComplete(() => activeScreenViewModel = screenViewModels.first);
      }
      return true;
    } catch (e) {
      // If encountering an error, return false.
        return false;
    }
  }

  /// Create an empty screen, makes it active, and place it in the model list
  /// This does NOT save it to the file system
  void createScreen() {
    ScreenViewModel newScreenVM = ScreenViewModel.empty();
    newScreenVM.screenId = _findUniqueId();
    newScreenVM.name = _findUniqueName();
    screenViewModels.add(newScreenVM);
    activeScreenViewModel = screenViewModels.last;
  }

  /// Delete the screen with the associated id
  /// returns the number of deleted records (SHOULD BE 1!!) on success, sub zero on fail
  Future<int> deleteScreen(int idToDelete) async {
    //can't delete the last screen
    if (screenViewModels.length < 2) return -1;

    //remove the json file
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String appPath = directory.path;
      String pathToDelete = path.join(appPath, "screens", idToDelete.toString());
      Directory dirToDelete = new Directory(pathToDelete);
      dirToDelete.deleteSync(recursive: true);
    } catch (_) {
      // If encountering an error, return 0.
      return -2;
    }

    int originalLength = screenViewModels.length;
    ScreenViewModel toRemove;
    screenViewModels.forEach((screen) {
      if (screen.screenId == idToDelete) {
        //remove the model from the list
        toRemove = screen;
      }
    });
    if (toRemove != null)
      screenViewModels.remove(toRemove);
    return originalLength - screenViewModels.length;
  }

  /// Takes a compressed or json file and import it and any resources into GIC
  Future<int> import(String file) async {
    //get our various folders ready
    int rv = -1; //fail by default
    if (file.endsWith("zip")) {
      Directory tempFolder = await getTemporaryDirectory();
      String importPath = path.join(tempFolder.path, "screenImports");

      //extract compressed file
      CompressedFileService.extract(file, importPath);

      //get a screen object based on the JSON extracted
      String importFile = path.join(importPath, "data.json");
      File jsonFile = File(importFile);
      rv = _importScreen(jsonToImport: jsonFile.readAsStringSync());

      //finally, clean up the cache
      Directory(importPath).deleteSync(recursive: true);
    } else if (file.endsWith("json")) {
      //simple import, this should be an absolute path to asset folder
      String json = await rootBundle.loadString(file);
      rv = _importScreen(jsonToImport: json);
    }
    return rv;
  }

  /// This will duplicate the screen with matching ID
  Future<bool> duplicateScreen(int originalScreenId) async {
    //build the path to the original screen
    try {
      Directory appSupportPath = await getApplicationSupportDirectory();
      String originalPath = path.join(appSupportPath.path, screenFolder, originalScreenId.toString());
      Directory originalDirectory = new Directory(originalPath);

      //get a new folder path
      int newId = _findUniqueId();
      String newPath = path.join(appSupportPath.path, screenFolder, newId.toString());
      Directory newDirectory = new Directory(newPath);
      newDirectory.createSync();

      //copy the files over
      originalDirectory.list().forEach((element) {
        File originalFile = new File(element.path);
        originalFile.copySync(newPath);
      });

      //now we need to update the json with its new id
      File newScreenJson = new File (path.join(newPath, "data.json"));
      ScreenViewModel newScreen = ScreenViewModel.fromJson(json.decode(newScreenJson.readAsStringSync()));
      newScreen.screenId = newId;
      newScreen.save(jsonOnly: true);
      //reload now and set our active screen to the new one
      loadScreens();
      setActiveScreen(newId);
    } on Exception catch (e) {
      log(e.toString());
      return false;
    }

    return true;
  }

  /// This will save a screen object
  int _importScreen({String jsonToImport, String backgroundPath = ""}) {

    Map rawJson = json.decode(jsonToImport);
    ScreenViewModel screenToImport;
    if (rawJson.containsKey("version")) {
      //get a screen object based on the JSON extracted
      screenToImport = ScreenViewModel.fromJson(json.decode(jsonToImport));
    } else {
      //legacy
      // get a screen object based on the JSON extracted
      Map controlMap = jsonDecode(jsonToImport);
      //build the new screen from the incoming json
      Screen legacy = new Screen.fromJson(controlMap);
      screenToImport = ScreenViewModel.fromLegacyModel(legacy);
    }
    //now we need to get a new ID and Name, as the existing one is probably taken
    screenToImport.screenId =
        _findUniqueId(startingId: screenToImport.screenId);
    screenToImport.name = _findUniqueName(baseName: screenToImport.name);

    //save the json file and add it to our list
    screenToImport.save(backgroundImageLocation: backgroundPath);
    screenViewModels.add(screenToImport);
    return screenToImport.screenId;
  }

  /// Here we assign a new screen a unique name
  /// baseName: name we want to use
  /// foundCount: how many instances of this name we found
  String _findUniqueName({String baseName = "New Screen", int foundCount = 0}) {
    screenViewModels.forEach((screen) {
      if (screen.name == baseName) {
        foundCount++;
        return _findUniqueName(baseName: baseName, foundCount: foundCount);
      }
      return "$baseName $foundCount";
    });
    return "$baseName $foundCount";
  }

  /// This will find a unique ID to provide for a new screen
  /// It will start off by setting it's ID to the length of the list, a safe bet
  /// From there it searches through all the screens to see if it can find the
  /// ID, if so, it will increment the ID by 1, and call itself recursively
  /// Once it has exhausted the whole list and has not found a match, it wil
  /// return this unused number
  /// startingId: used for the recursion
  int _findUniqueId({int startingId = -1}) {
    int startingId = screenViewModels.length;

    screenViewModels.forEach((screen) {
      if (screen.screenId == startingId) {
        startingId++;
        return _findUniqueId(startingId: startingId);
      }
      return startingId;
    });

    return startingId;
  }
}
