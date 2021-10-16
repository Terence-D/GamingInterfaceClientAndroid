//this service handles the backend work required for screen editor view
//for now going with a simple service layer

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
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
    if (activeScreenViewModel == null) {
      await loadScreens();
    }

    defaultControls = ControlDefaults(prefs, activeScreenViewModel.screenId);
    gridSize = prefs.getInt(_prefGridSize);
    if (gridSize == null) gridSize = 0;
  }

  // Sets which screen we are using as active
  // Returns true on success, false when no matching screen id is found
  bool setActiveScreen(int screenId) {
    bool rv = false;
    if (screenViewModels != null && screenViewModels.isNotEmpty) {
      screenViewModels.forEach((element) {
        if (element.screenId == screenId) {
          activeScreenViewModel = element;
          rv = true;
        }
      });
    }
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
      if (screenViewModels == null) {
        screenViewModels = [];
      } else {
        screenViewModels.clear();
      }
      final Directory appSupportPath = await getApplicationDocumentsDirectory();
      String screenPath = path.join(appSupportPath.path, screenFolder);

      if (!Directory(screenPath).existsSync()) {
        Directory(screenPath).createSync(recursive: true);
      } else {
        Directory screenDirectory = Directory(screenPath);

        Stream stream = screenDirectory.list();
        await stream.forEach((element) {
          File file = File(path.join(element.path, "data.json"));
          screenViewModels.add(
              ScreenViewModel.fromJson(json.decode(file.readAsStringSync())));
        }).catchError((error, stackTrace) {
          throw (error);
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
  Future<int> deleteScreen(int idToDelete) async {
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
    ScreenViewModel toRemove;
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
    //get our various folders ready

    int rv = -1; //fail by default
    if (file.endsWith("zip")) {
      Directory tempFolder = await getTemporaryDirectory();
      String importPath = path.join(tempFolder.path, "screenImports");

      //extract compressed file
      String id = CompressedFileService.extract(file, importPath);

      String importFile = path.join(importPath, id, "data.json");
      File jsonFile = File(importFile);

      //get a screen object based on the JSON extracted
      String jsonString = jsonFile.readAsStringSync();
      //build the new screen from the incoming json
      ScreenViewModel screen = ScreenViewModel.fromJson(json.decode(jsonString));
      Directory files = Directory(importPath);
      //now take the extracted image files, and add them to the app with possibly new names
      _saveImageFiles(screen, path.join(importPath, id), files);

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

  /// Here we copy the image files stored in cache and move them inside the files
  /// directory, then delete the cached file
  /// For each file we copy it from the cache to the files directory
  /// If we find any other files with that name, we'll search for a new id
  /// then update the screen with that new id
  _saveImageFiles(ScreenViewModel screen, String importLocation, Directory fileSource) {

    Directory cache = Directory(importLocation);

    //keep track of id's we already modified and their new id
    final Map<int, int> foundButtonIds = Map<int, int>();
    final Map<int, int> foundSwitchIds = Map<int, int>();

    //we need to check against these filename types:
    //screenId_background.png
    //screenId_control_i.png
    //button_i.png
    //switch_i.png

    List allFiles = cache.listSync();
    allFiles.forEach((element) {
      //ensure it's a file first
      if (element is File) {

        //check if it's a background image or control, if so it's a simple
        //change, just change the start of the filename to the new screen id
        if (path
            .basenameWithoutExtension(element.path)
            .contains("_background")) {
          _renameBackground(element, screen, fileSource);
        }
        if (path
            .basenameWithoutExtension(element.path)
            .contains("_control_")) {
          _renameImage(element, screen, fileSource);
        }
        // check if it's a button or switch, if so:
        // 1) check foundIds to see if we updated it already
        // 2) if found, just update the path and carry on
        // 3) if not, find the next unique id
        // 4) change it to that ID
        // 5) add it to the found id's
        // , if so it's a simple
        //change, just change the start of the filename to the new screen id
        if (element.path.contains("button_")) {
          _renameControl(element, foundButtonIds, screen, fileSource, "button_");
        } else if (element.path.contains("switch_")) {
          _renameControl(element, foundSwitchIds, screen, fileSource, "switch_");
        }
      }
    });
  }

  void _renameControl(File element, Map<int, int> foundIds, ScreenViewModel screen,
      Directory fileSource, String searchParam) {
    String fileName = path.basenameWithoutExtension(element.path);
    int separatorPosition = fileName.indexOf("_");
    int oldId = int.tryParse(fileName.substring(separatorPosition + 1));
    if (oldId != null) {
      //check if we've seen this before
      if (foundIds.containsKey(oldId)) {
        String newFilename =
            "${fileName.substring(0, separatorPosition + 1)}_${foundIds[oldId]}";
        //found before, so just update references
        screen.controls.forEach((control) {
          control.images.forEach((imageFilename) {
            if (imageFilename.contains("${searchParam}_$oldId")) {
              imageFilename = path.join(fileSource.path, "$newFilename.png");
            }
          });
        });
      } else {
        //we haven't seen this id before
        int originalId = oldId; //back it up for later
        //we'll look through and search until we find a no match
        String newFilename =
            "${fileName.substring(0, separatorPosition + 1)}$oldId";
        String searchFor = path.join(fileSource.path, "$newFilename.png");
        List<FileSystemEntity> dirList = fileSource.listSync();
        for (int i = 0; i < dirList.length; i++) {
          newFilename = "${fileName.substring(0, separatorPosition + 1)}$oldId";
          searchFor = path.join(fileSource.path, "$newFilename.png");
          if (dirList[i].path == searchFor) {
            oldId++;
            i = -1;
          }
        }

        newFilename = "${fileName.substring(0, separatorPosition + 1)}$oldId";

        //found a new id, update file and references
        newFilename = path.join(fileSource.path, "$newFilename.png");

        screen.controls.forEach((control) {
          control.images.forEach((imageFilename) {
            if (imageFilename.contains("${searchParam}_$oldId")) {
              imageFilename = newFilename;
            }
          });
        });
        element.copy(newFilename);
        foundIds[originalId] = oldId;
      }
    }
  }

  void _renameImage(File element, ScreenViewModel screen, Directory files) {
    String newFilename =
    path.join(files.path, "${_findElementToRename(element, files)}.png");
    screen.controls.forEach((control) {
      control.images.forEach((imageFilename) {
        if (imageFilename.contains(path.basename(element.path))) {
          imageFilename = newFilename;
        }
      });
    });
    element.copy(newFilename);
  }

  void _renameBackground(File element, ScreenViewModel screen, Directory files) {
    String newFilename = _findElementToRename(element, files);
    screen.backgroundPath = path.join(files.path, "$newFilename.png");
    element.copy(screen.backgroundPath);
  }

  //common code for renaming background / image
  String _findElementToRename(element, files) {
    //find first instance of a _
    String fileName = path.basenameWithoutExtension(element.path);
    int separatorPosition = fileName.indexOf("_");
    //before that, we should have our screen id (int)
    int oldId = int.tryParse(fileName.substring(0, separatorPosition));
    if (oldId != null) {
      String newFilename = "$oldId${fileName.substring(separatorPosition)}";
      //we'll look through and search until we find a no match
      String searchParam = path.join(files.path, "$newFilename.png");
      List<FileSystemEntity> dirList = files.listSync();
      for (int i = 0; i < dirList.length; i++) {
        newFilename = "$oldId${fileName.substring(separatorPosition)}";
        searchParam = path.join(files.path, "$newFilename.png");
        if (dirList[i].path == searchParam) {
          oldId++;
          i = -1;
        }
      }
    }
    String rv = "$oldId${fileName.substring(separatorPosition)}";
    return rv;
  }

  /// This will duplicate the screen with matching ID
  Future<bool> duplicateScreen(int originalScreenId) async {
    //build the path to the original screen
    try {
      Directory appSupportPath = await getApplicationSupportDirectory();
      String originalPath = path.join(
          appSupportPath.path, screenFolder, originalScreenId.toString());
      Directory originalDirectory = Directory(originalPath);

      //get a new folder path
      int newId = _findUniqueId();
      String newPath =
          path.join(appSupportPath.path, screenFolder, newId.toString());
      Directory newDirectory = Directory(newPath);
      newDirectory.createSync();

      //copy the files over
      await originalDirectory.list().forEach((element) {
        File originalFile = File(element.path);
        originalFile.copySync(newPath);
      });

      //now we need to update the json with its new id
      File newScreenJson = File(path.join(newPath, "data.json"));
      ScreenViewModel newScreen = ScreenViewModel.fromJson(
          json.decode(newScreenJson.readAsStringSync()));
      newScreen.screenId = newId;
      await newScreen.save(jsonOnly: true);
      //reload now and set our active screen to the new one
      await loadScreens();
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
      Screen legacy = Screen.fromJson(controlMap);
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
        return _findUniqueName(baseName: "baseName${foundCount}", foundCount: foundCount);
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
