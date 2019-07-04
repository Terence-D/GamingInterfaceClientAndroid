import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.dark,

    primaryColor: Color(0xff3F51B5),
    accentColor: Color(0xff43a047),
    primaryColorDark: Color(0xff2A41B3),
    errorColor: Color(0xffF44336),
    scaffoldBackgroundColor: Color(0xFF383838),
    canvasColor: Color(0xFF383838),
    buttonColor: Color(0xff575757),

    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      body1: TextStyle(color: Color(0xA1F8F8F8))
    ),

  );
}