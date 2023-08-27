import 'package:flutter/material.dart';

ThemeData darkTheme() {
  return ThemeData(
    primaryColor: Color(0xff3F51B5),
    primaryColorDark: Color(0xff2A41B3),
    errorColor: Color(0xffF44336),
    scaffoldBackgroundColor: Color(0xFF383838),
    canvasColor: Color(0xFF383838),
    //buttonColor: Color(0xff575757),
    appBarTheme: const AppBarTheme(
      color: Colors.indigo,
      iconTheme: IconThemeData(color: Colors.white),
      foregroundColor: Color(0xA1F8F8F8)
    ),
    snackBarTheme: const SnackBarThemeData(
      actionTextColor: Colors.blue,
      backgroundColor: Colors.black54,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      bodyText2: TextStyle(color: Color(0xA1F8F8F8))
    ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xff43a047),brightness: Brightness.dark,

  ),
  );
}

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,

    primaryColor: Color(0xff3F51B5),
    primaryColorDark: Color(0xff2A41B3),
    errorColor: Color(0xffF44336),
    scaffoldBackgroundColor: Color(0xffffffff),
    canvasColor: Color(0xFF383838),

    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      bodyText2: TextStyle(color: Color(0xFF383838))
    ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xff43a047)),
  );
}