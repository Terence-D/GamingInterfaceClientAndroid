import 'dart:ui';

import 'package:flutter/material.dart';

class Font {
  int version;
  Color color = Colors.blue;
  double size = 36;
  String family = "";

  Font.empty() {
    color = Colors.blue;
    size = 36;
    family = "";
  }

  Font({this.color, this.size, this.family});

  Font.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        color = Color(json['color']),
        size = json['size'],
        family = json['family'];

  Map<String, dynamic> toJson() {

    return {
        'version': 2,
        'color': color.value,
        'size': size,
        'family': family
      };
  }
}
