import 'package:flutter/material.dart';
import 'package:gic_flutter/src/service_locator.dart';
import 'package:gic_flutter/src/theme/theme.dart';
// Import `in_app_purchase_android.dart` to be able to access the
// `InAppPurchaseAndroidPlatformAddition` class.
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
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

  // Inform the plugin that this app supports pending purchases on Android.
  // An error will occur on Android if you access the plugin `instance`
  // without this call.
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
    runApp(myTheme);
}
