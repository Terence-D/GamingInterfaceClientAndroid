import 'package:flutter/material.dart';

import 'package:gic_flutter/theme/theme.dart';
import 'app.dart';
import 'flavor.dart';

void main() async {
  BuildEnvironment.init(flavor: BuildFlavor.gplay);
  var myApp = GicApp();
  var myTheme =  CustomTheme(
      initialThemeKey: ThemeKeys.DARK,
      child: myApp,
    );
    WidgetsFlutterBinding.ensureInitialized();
    runApp(myTheme);
}
