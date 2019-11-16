import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gic_flutter/model/screen/GicControl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screen.dart';

class Screens {
  List<Screen> _cache;
  String _prefsScreen = "screen_";
  String _prefsBackgroundSuffix = "_background";
  String _prefsBackgroundPathSuffix = "_background_path";
  String _prefsControl = "_control_";

  int defaultBackground = 0xFF383838;

  _load (SharedPreferences prefs, BuildContext context) async {
    if (_cache == null) {
      _cache = new List<Screen>();
    }
    
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
        _loadBackground(prefs, screen, context);
        _loadControls(prefs, screen, context);
        _cache.add(screen);
      }
    });
  }

  _loadBackground(SharedPreferences prefs, Screen screen, BuildContext context) {
    
    int backgroundColor = prefs.getInt("${screen.screenId}$_prefsBackgroundSuffix");
    String backgroundPath = prefs.getString("${screen.screenId}$_prefsBackgroundPathSuffix");
    screen.backgroundColor = backgroundColor;
    screen.backgroundPath = backgroundPath;
  }

  _loadControls(SharedPreferences prefs, Screen screen, BuildContext context) {
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
      if (screen.name == baseName)
        return _findUniqueName(baseName + "1");
    });
    return baseName;
  }

  int _findUniqueId({int startingId = -1}) {
    if (startingId < 0)
      startingId = _cache.length;

    _cache.forEach((screen) {
      if (screen.screenId == startingId)
        return _findUniqueId(startingId: startingId);
    });

    return startingId;
  }

  _save(SharedPreferences prefs, Screen screen) {
    prefs.setString("$_prefsScreen${screen.screenId}", screen.name);
    prefs.setInt("${screen.screenId}$_prefsBackgroundSuffix}", screen.backgroundColor);
    prefs.setString("${screen.screenId}$_prefsBackgroundPathSuffix}", screen.backgroundPath);

    //clear out the old
    prefs.getKeys().forEach((key) {
      if (key.contains("${screen.screenId}$_prefsControl"))
        prefs.remove(key);
    });

    //add the updated controls
    int i=0;
    screen.controls.forEach((control) {
      String json = jsonEncode(control.toJson());
      prefs.setString("${screen.screenId}$_prefsControl + i", json);
    });
  }

  loadFromJson(String screen, String device, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_cache == null || _cache.length < 1)
      _load(prefs, context);

    //the name will have spaces, but the asset file does not.  so turn Large Tablet into LargeTablet
    device = device.replaceAll(" ", ""); //remove spaces

    //load in the asset and decode the json
    String jsonString = await DefaultAssetBundle.of(context).loadString("assets/screens/$screen-$device.json");
    Map controlMap = jsonDecode(jsonString);

    //build the new screen from the incoming json
    Screen newScreen = new Screen.fromJson(controlMap);

    //get a unique name and ID
    newScreen.name = _findUniqueName(newScreen.name);
    newScreen.screenId = _findUniqueId();

    //save the new screen
    _save(prefs, newScreen);
    _cache.add(newScreen);
  }
}