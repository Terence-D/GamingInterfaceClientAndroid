import 'package:flutter/material.dart';
import 'package:gic_flutter/src/service_locator.dart';
import 'package:gic_flutter/src/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'app.dart';
import 'flavor.dart';

Future<void> main() async {
  BuildEnvironment.init(flavor: BuildFlavor.gplay);
  var myApp = GicApp();
  var myTheme =  CustomTheme(
      initialThemeKey: ThemeKeys.DARK,
      child: myApp,
    );
    WidgetsFlutterBinding.ensureInitialized();
    await setupLocator();
  runApp(myTheme);
}
