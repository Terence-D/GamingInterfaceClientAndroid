import 'package:flutter/material.dart';

import 'GicControl.dart';

class Screen {
  static const MAX_CONTROL_SIZE = 800;

  int screenId = -1;
  List<GicControl> controls = new List<GicControl>();
  //background
  int newControlId = -1;
  int backgroundColor;
  String backgroundPath;
  //context;
  String name;

  Screen({this.screenId, this.controls, this.backgroundColor, this.backgroundPath, this.newControlId, this.name});

  factory Screen.fromJson(Map<String, dynamic> json) {
    var list = json['controls'] as List;
    List<GicControl> jsonControls = new List<GicControl>();
    list.forEach((value) { jsonControls.add(GicControl.fromJson(value));});

    return Screen(
      screenId: json['screenId'],
      controls: jsonControls,
      backgroundColor: json['backgroundColor'],
      backgroundPath: json['backgroundPath'],
      newControlId: json['newControlId'],
      name: json['name']);
  }

  Map<String, dynamic> toJson() =>
      {
        'screenId': screenId,
        'controls': controls,
        'backgroundColor': backgroundColor,
        'backgroundPath': backgroundPath,
        'newControlId': newControlId,
        'name': name,
      };

  int getNewControlId() {
    newControlId++;
    return newControlId - 1;
  }

}
