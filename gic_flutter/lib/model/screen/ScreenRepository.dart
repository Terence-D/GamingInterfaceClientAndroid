import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/model/screen/GicControl.dart';
import 'package:gic_flutter/views/intro/screenListWidget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screen.dart';
import 'package:path/path.dart' as path;
class ScreenRepository {
  List<Screen> _cache;
  String _prefsScreen = "screen_";
  String _prefsBackgroundSuffix = "_background";
  String _prefsBackgroundPathSuffix = "_background_path";
  String _prefsControl = "_control_";


  int defaultBackground = 0xFF383838;

  _load (SharedPreferences prefs) async {
    _cache = new List<Screen>();

    Set<String> keys = prefs.getKeys();

    keys.forEach((key) {
      if (key.contains(_prefsScreen)) {
        int screenId = int.parse(key.substring(_prefsScreen.length));
        Screen screen = new Screen(screenId: screenId);
        try {//legacy used an integer dummy value, so need to handle that
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
    
    int backgroundColor = prefs.getInt("${screen.screenId}$_prefsBackgroundSuffix");
    String backgroundPath = prefs.getString("${screen.screenId}$_prefsBackgroundPathSuffix");
    screen.backgroundColor = backgroundColor;
    screen.backgroundPath = backgroundPath;
  }

  _loadControls(SharedPreferences prefs, Screen screen) {
    prefs.getKeys().forEach((key) {
      if (key.contains("${screen.screenId}$_prefsControl")) {
        try {//legacy used an integer dummy value, so need to handle that
          Map controlMap = jsonDecode(prefs.getString(key));
          screen.controls.add(GicControl.fromJson(controlMap));
          screen.name = prefs.getString(key);
        } catch (_) { }
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

  int _findUniqueId({int startingId = -1}) {
    if (startingId < 0)
      startingId = _cache.length;

    _cache.forEach((screen) {
      if (screen.screenId == startingId) {
        startingId++;
        return _findUniqueId(startingId: startingId);
      }
      return startingId;
    });

    return startingId;
  }

  _save(SharedPreferences prefs, Screen screen) {
    prefs.setString("$_prefsScreen${screen.screenId}", screen.name);
    prefs.setInt("${screen.screenId}$_prefsBackgroundSuffix", screen.backgroundColor);
    prefs.setString("${screen.screenId}$_prefsBackgroundPathSuffix", screen.backgroundPath);

    //clear out the old
    prefs.getKeys().forEach((key) {
      if (key.contains("${screen.screenId}$_prefsControl"))
        prefs.remove(key);
    });

    //add the updated controls
    int i=0;
    if (screen.controls != null && screen.controls.length > 0) {
      screen.controls.forEach((control) {
        String json = jsonEncode(control.toJson());
        prefs.setString("${screen.screenId}$_prefsControl$i", json);
        i++;
      });
    }
  }

  updateName (int id, String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("$_prefsScreen$id", newName);
  }

  loadFromJson(List<ScreenItem> screens, String device, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_cache == null || _cache.length < 1)
      _load(prefs);

    //the name will have spaces, but the asset file does not.  so turn Large Tablet into LargeTablet
    device = device.replaceAll(" ", ""); //remove spaces

    //load in the asset and decode the json
    for (int n=0; n < screens.length; n++) {
      String jsonString = await DefaultAssetBundle.of(context).loadString("assets/screens/${screens[n].title}-$device.json");
      Map controlMap = jsonDecode(jsonString);

      //build the new screen from the incoming json
      Screen newScreen = new Screen.fromJson(controlMap);

      //get a unique name and ID
      newScreen.name = _findUniqueName(newScreen.name);
      newScreen.screenId = _findUniqueId();

      //save the new screen
      await _save(prefs, newScreen);
      _cache.add(newScreen);
    }
  }

  Future<LinkedHashMap> getScreenList() async {
    LinkedHashMap rv = new LinkedHashMap<int, String>();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await _load(prefs);

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
    prefs.remove("$_prefsScreen$id" + "_background");
    prefs.getKeys().forEach((key) {
      if (key.contains("$id" + "_control_"))
        prefs.remove(key);
    });

    for (int i=0; i < _cache.length; i++) {
      if (_cache[i].screenId == id)
        _cache.removeAt(i);
    }

    return _cache.length;
  }

  get _tempPath async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }

  Future<int> import(File file) async {
    //get file name
    String name = path.basename(file.path);
    name = name.replaceAll(".zip", "");

    // Read the Zip file from disk.
    final bytes = file.readAsBytesSync();

    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);

    final String tempPath = await _tempPath;

    // Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File extractedPath = File(path.join(tempPath, "imported", filename))
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
      } else {
        Directory('out/' + filename)
        ..create(recursive: true);
      }
    }

    String fullPath = path.join(tempPath, "imported");
    Screen importedScreen = await _parseJson(fullPath);
    return _screenImporter(importedScreen);
  }

  Future<int> _screenImporter(Screen toImport) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _load(prefs);

    _findUniqueName(toImport.name);
    Screen newScreen = toImport;

    newScreen.screenId = _findUniqueId();
    _cache = null; //invalidate the cache

    _save(prefs, newScreen);
    return 0;
  }

  Future<Screen> _parseJson(String fullPath) async {
    File jsonFile = File(path.join(fullPath, "data.json"));
    String jsonString = await jsonFile.readAsString();

    Map controlMap = jsonDecode(jsonString);
    //build the new screen from the incoming json
    Screen screen = new Screen.fromJson(controlMap);

    if (screen.backgroundPath.isNotEmpty) {
      int index = screen.backgroundPath.lastIndexOf("/");
      screen.backgroundPath =
          fullPath + screen.backgroundPath.substring(index + 1);
    }
    screen.controls.forEach((control) {
      if (control.primaryImage.isNotEmpty) {
        int index = control.primaryImage.lastIndexOf("/");
        control.primaryImage =
            fullPath + control.primaryImage.substring(index + 1);
      }
      if (control.secondaryImage.isNotEmpty) {
        int index = control.secondaryImage.lastIndexOf("/");
        control.secondaryImage =
            fullPath + control.secondaryImage.substring(index + 1);
      }
    });

    return screen;
  }
}
