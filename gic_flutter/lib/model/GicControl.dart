import 'package:flutter/material.dart';

import 'Command.dart';

class GicControl {
  static const int TYPE_BUTTON = 0;
  static const int TYPE_TEXT = 1;
  static const int TYPE_IMAGE = 2;
  static const int TYPE_SWITCH = 3;
  static const int TYPE_BUTTON_QUICK = 4;

  //this is required for the toggle button, there are 4 stages to track:
  //0 - switched off ready for mouse down
  //1 - switched off, ready for mouse up
  //2 - switched on, ready for mouse down,
  //3 - switched on, ready for mouse up
  //after 3, we reset back to 0
  int stage = 0;

  Command command = new Command();
  String text = "NONE";
  double left = 140;
  int width = 320;
  double top = 200;
  int height = 120;
  int fontColor = 0;//Colors.white;// Colors.WHITE;
  int primaryColor = -1;
  int secondaryColor = -1;
  int fontSize = 36;
  int viewType = 0;
  int primaryImageResource = 0;//R.drawable.button_blue;
  int secondaryImageResource = 0;//R.drawable.button_blue_dark;
  String primaryImage = "";
  String secondaryImage = "";
  String fontName = "";
  int fontType = 0;
  Command commandSecondary = new Command();
}