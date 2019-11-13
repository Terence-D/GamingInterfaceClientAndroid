import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screen.dart';

class Screens {
  List<Screen> _cache;
  String _prefsScreen = "screen_";
  String _prefsBackgroundSuffix = "_background";
  String _prefsBackgroundPathSuffix = "_background_path";
  int defaultBackground = 0xFF383838;

  _load (BuildContext context) async {
    if (_cache == null) {
      _cache = new List<Screen>();
    }
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
        _loadBackground(screen, context);
        _loadControls(screen, context);
        _cache.add(screen);
      }
    });
  }

  _loadBackground(Screen screen, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    int backgroundColor = prefs.getInt("${screen.screenId}$_prefsBackgroundSuffix");
    String backgroundPath = prefs.getString("${screen.screenId}$_prefsBackgroundPathSuffix");
    screen.backgroundColor = backgroundColor;
    screen.backgroundPath = backgroundPath;
  }

  _loadControls(Screen screen, BuildContext context) {

  }

  String _findUniqueName(String baseName) {

  }

  int _findUniqueId() {

  }

  _saveCache() {

s  }

  loadFromJson(String screen, String device, BuildContext context) async {
    if (_cache == null || _cache.length < 1)
      _load(context);

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
    _saveCache();
  }
}