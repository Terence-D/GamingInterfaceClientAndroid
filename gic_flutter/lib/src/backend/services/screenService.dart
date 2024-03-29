//this service handles the backend work required for screen editor view
//for now going with a simple service layer

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:gic_flutter/src/backend/models/screen/controlDefaults.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/services/screenImportService.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenService {
  //sub folders where we store resources
  static String controlImageFolder = "controls";
  static String screenFolder = "screens";

  bool altMode = false;

  //current screen working with
  ScreenViewModel? activeScreenViewModel;

  //list of all screens available
  List<ScreenViewModel> screenViewModels = [];

  //default control values to use
  late ControlDefaults defaultControls;

  //snap to grid feature for the editor
  final String _prefGridSize = "prefGridSize";
  int gridSize = 0;

  //constructor
  ScreenService();

  /// Initialize our service with values from preferences
  Future initDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (activeScreenViewModel == null) {
      await loadScreens();
    }

    defaultControls = ControlDefaults(prefs, activeScreenViewModel!.screenId);
    gridSize = prefs.getInt(_prefGridSize) ?? 0;
  }

  // Sets which screen we are using as active
  // Returns true on success, false when no matching screen id is found
  bool setActiveScreen(int? screenId) {
    bool rv = false;
    if (screenViewModels.isNotEmpty) {
      screenViewModels.forEach((element) {
        if (element.screenId == screenId) {
          activeScreenViewModel = element;
          rv = true;
        }
      });
    }
    return rv;
  }

  /// Load in all screens
  /// Returns true on success, false on any failure
  Future<bool> loadScreens() async {
    try {
      screenViewModels.clear();

      final Directory appSupportPath = await getApplicationDocumentsDirectory();
      String screenPath = path.join(appSupportPath.path, screenFolder);

      if (!Directory(screenPath).existsSync()) {
        Directory(screenPath).createSync(recursive: true);
      } else {
        Directory screenDirectory = Directory(screenPath);

        Stream stream = screenDirectory.list();
        await stream.forEach((element) {
          try {
            File file = File(path.join(element.path, "data.json"));
            ScreenViewModel svm = ScreenViewModel.fromJson(
                json.decode(file.readAsStringSync()));
            screenViewModels.add(svm);
          } catch (error) {
            print (error);
          }
        }).catchError((error, stackTrace) {
          print (error);
        }).whenComplete(() => activeScreenViewModel = screenViewModels.first);
      }
      return true;
    } catch (e) {
      print (e);
      // If encountering an error, return false.
      return false;
    }
  }

  /// Create an empty screen, makes it active, and place it in the model list
  /// This does NOT save it to the file system
  Future<void> createScreen() async {
    await loadScreens();
    ScreenViewModel newScreenVM = ScreenViewModel.empty();
    newScreenVM.screenId = _findUniqueId();
    newScreenVM.name = _findUniqueName();
    screenViewModels.add(newScreenVM);
    activeScreenViewModel = screenViewModels.last;
  }

  /// Delete the screen with the associated id
  /// returns the number of deleted records (SHOULD BE 1!!) on success, sub zero on fail
  Future<int> deleteScreen(int? idToDelete) async {
    //can't delete the last screen
    if (screenViewModels.length < 2) return -1;

    //remove the json file
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String appPath = directory.path;
      String pathToDelete =
          path.join(appPath, "screens", idToDelete.toString());
      Directory dirToDelete = Directory(pathToDelete);
      dirToDelete.deleteSync(recursive: true);
    } catch (_) {
      // If encountering an error, return 0.
      return -2;
    }

    int originalLength = screenViewModels.length;
    ScreenViewModel? toRemove;
    screenViewModels.forEach((screen) {
      if (screen.screenId == idToDelete) {
        //remove the model from the list
        toRemove = screen;
      }
    });
    if (toRemove != null) screenViewModels.remove(toRemove);
    return originalLength - screenViewModels.length;
  }

  /// Takes a compressed or json file and import it and any resources into GIC
  Future<int> import(String file) async {
    ScreenImportService sis = ScreenImportService();
    await sis.init();
    if (file.endsWith("zip")) {
      await sis.importZip(file);
    } else {
      await sis.importJson(file);
    }

    await loadScreens();

    return 0;
  }

  /// This will duplicate the screen with matching ID
  Future<bool> duplicateScreen(int originalScreenId) async {
    //build the path to the original screen
    try {
      final Directory appFolder = await getApplicationDocumentsDirectory();
      String originalPath = path.join(
          appFolder.path, screenFolder, originalScreenId.toString());
      Directory originalDirectory = Directory(originalPath);

      //get a new folder path
      int newId = _findUniqueId();
      String newPath =
          path.join(appFolder.path, screenFolder, newId.toString());
      await Directory(newPath).create(recursive: true);
      Directory newDirectory = Directory(newPath);

      //copy the files over
      await originalDirectory.list().forEach((element) {
        File originalFile = File(element.path);
        originalFile.copySync(path.join(newPath, path.basename(element.path)));
      });

      //now we need to update the json with its new id
      File newScreenJson = File(path.join(newPath, "data.json"));
      ScreenViewModel newScreen = ScreenViewModel.fromJson(
          json.decode(newScreenJson.readAsStringSync()));

      if (newScreen.backgroundPath!.contains(originalPath))
        newScreen.backgroundPath!.replaceAll(originalPath, newPath);
      for (int i=0; i < newScreen.controls!.length; i++) {
        for (int n=0; n < newScreen.controls![i].images.length; n++) {
          if (newScreen.controls![i].images[n].contains(originalPath))
            newScreen.controls![i].images[n].replaceAll(originalPath, newPath);
        }
      }
      newScreen.screenId = newId;

      await newScreen.save();

      //reload now and set our active screen to the new one
      await loadScreens();
      setActiveScreen(newId);
    } on Exception catch (e) {
      log(e.toString());
      return false;
    }

    return true;
  }

  /// Here we assign a new screen a unique name
  /// baseName: name we want to use
  /// foundCount: how many instances of this name we found
  String _findUniqueName({String baseName = "New Screen", int foundCount = 0}) {
    screenViewModels.map((screen) {
      if (screen.name == baseName) {
        foundCount++;
        return _findUniqueName(
            baseName: "baseName${foundCount}", foundCount: foundCount);
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
    if (startingId < 0) {
      startingId = screenViewModels.length;
    }

    for (var screen in screenViewModels) {
      if (screen.screenId == startingId) {
        startingId++;
        return _findUniqueId(startingId: startingId);
      }
    }

    return startingId;
  }
}
