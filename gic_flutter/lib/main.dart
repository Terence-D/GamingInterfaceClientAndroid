import 'package:flutter/material.dart';

import 'package:gic_flutter/screens/main/main.dart';
import 'package:gic_flutter/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  var myApp = MyApp(sharedPreferences);
    runApp(myApp);
}

class MyApp extends StatelessWidget {
  SharedPreferences _sharedPreferences;

  MyApp (SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaming Interface Client',
      theme: appTheme(),
      darkTheme: darkTheme(),
      home: MainScreen(_sharedPreferences),
    );
  }

  @override
  void initState() {

  }
}
