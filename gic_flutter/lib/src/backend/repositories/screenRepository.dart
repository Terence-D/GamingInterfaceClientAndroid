import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/gicControl.dart';
import 'package:gic_flutter/src/backend/models/screen/screen.dart';
import 'package:gic_flutter/src/views/intro/screenListWidget.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenRepository {
  List<Screen> _cache;
  String _prefsScreen = "screen_";
  String _prefsBackgroundSuffix = "_background";
  String _prefsBackgroundPathSuffix = "_background_path";
  String _prefsControl = "_control_";

  int defaultBackground = 0xFF383838;

  _load(SharedPreferences prefs) async {
    _cache = new List<Screen>();
    await prefs.reload();
    Set<String> keys = prefs.getKeys();

    keys.forEach((key) {
      if (key.contains(_prefsScreen)) {
        int screenId = int.parse(key.substring(_prefsScreen.length));
        Screen screen = new Screen(screenId: screenId);
        try {
          //legacy used an integer dummy value, so need to handle that
          screen.name = prefs.getString(key);
        } catch (_) {
          screen.name = "Screen $screenId";
        }
        _loadBackground(prefs, screen);
        _loadControls(prefs, screen);
        _cache.add(screen);
      }
    });
  }

  _loadBackground(SharedPreferences prefs, Screen screen) {
    int backgroundColor =
        prefs.getInt("${screen.screenId}$_prefsBackgroundSuffix");
    String backgroundPath =
        prefs.getString("${screen.screenId}$_prefsBackgroundPathSuffix");
    screen.backgroundColor = backgroundColor;
    screen.backgroundPath = backgroundPath;
  }

  _loadControls(SharedPreferences prefs, Screen screen) {
    screen.controls = new List<GicControl>();
    prefs.getKeys().forEach((key) {
      if (key.contains("${screen.screenId}$_prefsControl")) {
        try {
          //legacy used an integer dummy value, so need to handle that
          Map controlMap = jsonDecode(prefs.getString(key));
          screen.controls.add(GicControl.fromJson(controlMap));
          //screen.name = prefs.getString(key);
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    });
  }

  String _findUniqueName(String baseName) {
    _cache.forEach((screen) {
      if (screen.name == baseName) {
        baseName = baseName + " 1";
        return _findUniqueName(baseName);
      }
      return baseName;
    });
    return baseName;
  }

  /// This will find a unique ID to provide for a new screen
  /// It will start off by setting it's ID to the length of the list, a safe bet
  /// From there it searches through all the screens to see if it can find the
  /// ID, if so, it will increment the ID by 1, and call itself recursively
  /// Once it has exhausted the whole list and has not found a match, it wil
  /// return this unused number
  int findUniqueId({int startingId = -1}) {
    if (startingId < 0)
      startingId = _cache.length;

    _cache.forEach((screen) {
      if (screen.screenId == startingId) {
        startingId++;
        return findUniqueId(startingId: startingId);
      }
      return startingId;
    });

    return startingId;
  }

  _save(SharedPreferences prefs, Screen screen) {
    prefs.setString("$_prefsScreen${screen.screenId}", screen.name);
    prefs.setInt(
        "${screen.screenId}$_prefsBackgroundSuffix", screen.backgroundColor);
    prefs.setString(
        "${screen.screenId}$_prefsBackgroundPathSuffix", screen.backgroundPath);

    //clear out the old
    prefs.getKeys().forEach((key) {
      if (key.contains("${screen.screenId}$_prefsControl"))
        prefs.remove(key);
    });

    //add the updated controls
    int i = 0;
    if (screen.controls != null && screen.controls.length > 0) {
      screen.controls.forEach((control) {
        String json = jsonEncode(control.toJson());
        prefs.setString("${screen.screenId}$_prefsControl$i", json);
        i++;
      });
    }
  }

  updateName(int id, String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("$_prefsScreen$id", newName);
  }

  loadFromJson(
      List<ScreenItem> screens, String device, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_cache == null || _cache.length < 1)
      await _load(prefs);

    //the name will have spaces, but the asset file does not.
    // so turn Large Tablet into LargeTablet
    device = device.replaceAll(" ", ""); //remove spaces

    //load in the asset and decode the json
    for (int n = 0; n < screens.length; n++) {
      String jsonString = await DefaultAssetBundle.of(context)
          .loadString("assets/screens/${screens[n].title}-$device.json");
      Map controlMap = jsonDecode(jsonString);

      //build the new screen from the incoming json
      Screen newScreen = new Screen.fromJson(controlMap);

      //get a unique name and ID
      newScreen.name = _findUniqueName(newScreen.name);
      newScreen.screenId = findUniqueId();

      //save the new screen
      await _save(prefs, newScreen);
      _cache.add(newScreen);
    }
  }

  Future<List<Screen>> loadScreens() async {
    if (_cache != null)
      return _cache;
    else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      await _load(prefs);
    }

    return _cache;
  }

  //Loads in the screen name list
  Future<LinkedHashMap> getScreenList() async {
    LinkedHashMap rv = new LinkedHashMap<int, String>();

    await loadScreens();

    _cache.forEach((screen) {
      rv[screen.screenId] = screen.name;
    });
    return rv;
  }

  Future save(Screen newScreen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _save(prefs, newScreen);
    if (_cache == null) {
      _cache = new List<Screen>();
    }
    _cache.add(newScreen);
  }

  Future<int> delete(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_cache == null)
      await _load(prefs);

    if (_cache.length < 2)
      return -1;

    prefs.remove("$_prefsScreen$id");
    prefs.remove("${id}_background");
    prefs.remove("${id}_background_path");
    prefs.getKeys().forEach((key) {
      if (key.contains("$id" + "_control_"))
        prefs.remove(key);
    });

    for (int i = 0; i < _cache.length; i++) {
      if (_cache[i].screenId == id) {
        if (_cache[i].backgroundPath != null &&
            _cache[i].backgroundPath.isNotEmpty) {
          final File background = new File(_cache[i].backgroundPath);
          background.delete();
        }
        _cache[i].controls.forEach((element) {
          if (element.primaryImage.contains("_control_")) {
            final File control = new File(element.primaryImage);
            control.delete();
          }
        });
        _cache.removeAt(i);
      }
    }

    return _cache.length;
  }

  /// Takes a file (retrieved from the view) and imports it into the application
  /// File is a ZIP, containing JSON and zero to many image files
  Future<int> import(File file) async {
    //get our various folders ready
    Directory cacheTemp = await getTemporaryDirectory();
    Directory files = await getApplicationSupportDirectory();
    String importPath = path.join(cacheTemp.path, "imported");

    _extractZipFiles(file, importPath);

    // get a screen object based on the JSON extracted
    Screen importedScreen = await _parseJson(importPath);

    // now we need to get a new ID and Name, as the existing one is probably taken
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _load(prefs);
    importedScreen.name = _findUniqueName(importedScreen.name);
    importedScreen.screenId = findUniqueId();
    _cache = null; //invalidate the cache

    //now take the extracted image files, and add them to the app with possibly new names
    _saveImageFiles(importedScreen, importPath, files);

    //save the screen
    _save(prefs, importedScreen);

    //finally, clean up the cache
    Directory(importPath).deleteSync(recursive: true);

    return importedScreen.screenId;
  }

  /// Here we copy the image files stored in cache and move them inside the files
  /// directory, then delete the cached file
  _saveImageFiles(Screen screen, String importLocation, Directory files) {
    // For each file we copy it from the cache to the files directory
    // If we find any other files with that name, we'll search for a new id
    // then update the screen with that new id

    Directory cache = new Directory(importLocation);

    //keep track of id's we already modified and their new id
    final Map<int, int> foundButtonIds = new Map<int, int>();
    final Map<int, int> foundSwitchIds = new Map<int, int>();

    //we need to check against these filename types:
    //screenId_background.png
    //screenId_control_i.png
    //button_i.png
    //switch_i.png

    cache.listSync().forEach((element) {
      //ensure it's a file first
      if (element is File) {
        //see if it's a supported image
        if (path.extension(element.path).toLowerCase() == ".png") {
          //check if it's a background image or control, if so it's a simple
          //change, just change the start of the filename to the new screen id
          if (path
              .basenameWithoutExtension(element.path)
              .contains("_background")) {
            _renameBackground(element, screen, files);
          }
          if (path
              .basenameWithoutExtension(element.path)
              .contains("_control_")) {
            _renameImage(element, screen, files);
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
            _renameControl(element, foundButtonIds, screen, files, "button_");
          } else if (element.path.contains("switch_")) {
            _renameControl(element, foundSwitchIds, screen, files, "switch_");
          }
        }
      }
    });
  }

  void _renameControl(File element, Map<int, int> foundIds, Screen screen,
      Directory files, String searchParam) {
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
          if (control.primaryImage.contains("${searchParam}_$oldId")) {
            control.primaryImage = path.join(files.path, "$newFilename.png");
          }
          if (control.secondaryImage.contains("${searchParam}_$oldId")) {
            control.secondaryImage = path.join(files.path, "$newFilename.png");
          }
        });
      } else {
        //we haven't seen this id before
        int originalId = oldId; //back it up for later
        //we'll look through and search until we find a no match
        String newFilename =
            "${fileName.substring(0, separatorPosition + 1)}$oldId";
        String searchFor = path.join(files.path, "$newFilename.png");
        List<FileSystemEntity> dirList = files.listSync();
        for (int i = 0; i < dirList.length; i++) {
          newFilename = "${fileName.substring(0, separatorPosition + 1)}$oldId";
          searchFor = path.join(files.path, "$newFilename.png");
          if (dirList[i].path == searchFor) {
            oldId++;
            i = -1;
          }
        }

        newFilename = "${fileName.substring(0, separatorPosition + 1)}$oldId";

        //found a new id, update file and references
        newFilename = path.join(files.path, "$newFilename.png");

        screen.controls.forEach((control) {
          if (control.primaryImage.contains("${searchParam}_$oldId")) {
            control.primaryImage = newFilename;
          }
          if (control.secondaryImage.contains("${searchParam}_$oldId")) {
            control.secondaryImage = newFilename;
          }
        });
        element.copy(newFilename);
        foundIds[originalId] = oldId;
      }
    }
  }

  void _renameImage(File element, Screen screen, Directory files) {
    String newFilename =
        path.join(files.path, "${_findElementToRename(element, files)}.png");
    screen.controls.forEach((control) {
      if (control.primaryImage.contains(path.basename(element.path))) {
        control.primaryImage = newFilename;
      }
    });
    element.copy(newFilename);
  }

  void _renameBackground(File element, Screen screen, Directory files) {
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

  /// Extracts the supplied ZIP file to a temporary location
  void _extractZipFiles(File file, String tempPath) {
    //construct a file name based on the name of the zip file
    String name = path.basename(file.path);
    name = name.replaceAll(".zip", "");

    // Read the Zip file from disk.
    final bytes = file.readAsBytesSync();

    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract the contents of the Zip archive to the temp path.
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(path.join(tempPath, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }
  }

  Future<Screen> _parseJson(String fullPath) async {
    File jsonFile = File(path.join(fullPath, "data.json"));
    String jsonString = await jsonFile.readAsString();

    Map controlMap = jsonDecode(jsonString);
    //build the new screen from the incoming json
    Screen screen = new Screen.fromJson(controlMap);

    return screen;
  }

  Future<int> export(String exportPath, int id) async {
    Directory cache = await getTemporaryDirectory();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_cache == null || _cache.length < 1)
      await _load(prefs);

    String filesPath = (await getApplicationSupportDirectory()).path;
    for (int i = 0; i < _cache.length; i++) {
      if (_cache[i].screenId == id) {
        return await _exportScreen(_cache[i], cache, exportPath, filesPath);
      }
    }
    return -1;
  }

  Future<int> _exportScreen(screen, cache, exportPath, filesPath) async {
    String rawJson = jsonEncode(screen);
    //store the json data file in the directory
    File jsonData = new File(path.join(cache.path, "data.json"));
    await jsonData.writeAsString(rawJson);

    var archive = ZipFileEncoder();
    archive.create(path.join(exportPath, screen.name + ".zip"));
    archive.addFile(jsonData);
    if (screen.backgroundPath != null && screen.backgroundPath.isNotEmpty) {
      File background = new File(path.join(
        filesPath,
        path.split(screen.backgroundPath).last,
      ));
      archive.addFile(background);
    }
    screen.controls.forEach((control) {
      if (control.primaryImage != null && control.primaryImage.isNotEmpty)
        archive.addFile(new File(path.join(
          filesPath,
          path.split(control.primaryImage).last,
        )));
      if (control.secondaryImage != null && control.secondaryImage.isNotEmpty)
        archive.addFile(new File(path.join(
          filesPath,
          path.split(control.secondaryImage).last,
        )));
    });

    archive.close();
    return 0;
  }
}
