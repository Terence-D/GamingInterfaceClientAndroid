import 'package:flutter/material.dart';
import 'package:gic_flutter/service_locator.dart';

import 'package:gic_flutter/theme/theme.dart';
import 'app.dart';
import 'flavor.dart';

Future<void> main() async {
  BuildEnvironment.init(flavor: BuildFlavor.other);
  var myApp = GicApp();
  var myTheme =  CustomTheme(
      initialThemeKey: ThemeKeys.DARK,
      child: myApp,
    );
    WidgetsFlutterBinding.ensureInitialized();
    await setupLocator();
    runApp(myTheme);
}
