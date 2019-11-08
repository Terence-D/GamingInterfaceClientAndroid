import 'dart:convert';

import 'package:flutter/material.dart';

import 'Screen.dart';

class Screens {
  List<Screen> _cache;

  _load() {
    
  }

  _update() {
    
  }

  String _findUniqueName(String baseName) {

  }

  int _findUniqueId() {

  }

  loadFromJson(String screen, String device, BuildContext context) async {
    if (_cache == null || _cache.length < 1)
      _load();

    device = device.replaceAll(" ", ""); //remove spaces
    String jsonString = await DefaultAssetBundle.of(context).loadString("assets/screens/$screen-$device.json");
;//controlMap);    
    Map controlMap = jsonDecode(jsonString);

    Screen newScreen = new Screen.fromJson(controlMap);
    newScreen.name = _findUniqueName(newScreen.name);
    newScreen.screenId = _findUniqueId();
    _update();
  }
}