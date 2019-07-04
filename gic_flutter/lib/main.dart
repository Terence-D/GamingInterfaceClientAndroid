import 'package:flutter/material.dart';

import 'package:gic_flutter/screens/main.dart';
import 'package:gic_flutter/theme/style.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaming Interface Client',
      theme: appTheme(),
      home: MainScreen(),
    );
  }

  @override
  void initState() {

  }
}
