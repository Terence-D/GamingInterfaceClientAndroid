import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gic_flutter/model/screen/GicControl.dart';
import 'package:gic_flutter/views/intro/screenListWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screen.dart';

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
}