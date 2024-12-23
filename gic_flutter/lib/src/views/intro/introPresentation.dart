import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:gic_flutter/src/backend/models/intl/localizations.dart';
import 'package:gic_flutter/src/backend/services/screenService.dart';
import 'package:gic_flutter/src/theme/theme.dart';
import 'package:gic_flutter/src/views/intro/screenListWidget.dart';
import 'package:gic_flutter/src/views/intro/screenSizeWidget.dart';
import 'package:introduction_screen/introduction_screen.dart';

abstract class IntroViewContract {
  void onIntroLoadCompleted(List<PageViewModel> _pages);
}

class IntroPresentation {

  List<PageViewModel>? _pages;
  List<ScreenItem> _screens = <ScreenItem>[ScreenItem("SC"), ScreenItem("Elite")]; //, new ScreenItem("Truck") next time..
  String device = "Phone";
  IntroViewContract _contract;

  IntroPresentation(this._contract);

  loadPages(BuildContext context) async {
    Color primaryColor = CustomTheme.of(context).primaryColor;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PageViewModel? oldApi;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      int version = androidInfo.version.sdkInt;

      if (version < 19) { //KITKAT
        oldApi = PageViewModel(
          title: Intl.of(context)!.onboardOldAndroidTitle,
          body: Intl.of(context)!.onboardOldAndroidDesc,
          image: Icon(Icons.warning, size: 175.0, color: primaryColor),
        );
      }
    // } else if (Platform.isIOS) {
    //   IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    }

    _pages = [
      PageViewModel(
        title: Intl.of(context)!.onboardIntroTitle,
        body: Intl.of(context)!.onboardIntroDesc,
        image: Icon(Icons.thumb_up, size: 175.0, color: primaryColor),
      ),
      PageViewModel(
        title: Intl.of(context)!.onboardServerTitle,
        body: Intl.of(context)!.onboardServerDesc,
        image: Icon(Icons.important_devices, size: 175.0, color: primaryColor),
        footer: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: () async {
            Email email = Email(
              body: "https://github.com/Terence-D/GamingInterfaceCommandServer/releases",
              subject: Intl.of(context)!.onboardEmailSubject,
            );
            await FlutterEmailSender.send(email);
          },
          child: Text(Intl.of(context)!.onboardSendLink, style: TextStyle(color: Colors.white)),
        ),
      ),
      PageViewModel(
        title: Intl.of(context)!.onboardScreenTitle,
        bodyWidget: SingleChildScrollView(
          child: Column(
            children: [
              Text(Intl.of(context)!.onboardScreenDesc),
              Text(Intl.of(context)!.onboardScreenDevice),
              ScreenSizeWidget(
                  (String selected) {
                    this.device = selected;
                  }
              ),
              Text(Intl.of(context)!.onboardScreenList),
              ScreenListWidget(_screens),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () {
                  List<ScreenItem> screens = <ScreenItem>[];
                  _screens.forEach((screen) {
                    if (screen.selected) {
                      screens.add(screen);
                    }
                  });
                  _importScreen(device, screens, context);
                },
                child: Text(Intl.of(context)!.onboardImport, style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ) // Single child scroll view
      ),
    ];
    if (oldApi != null) {
      _pages!.add(oldApi);
    }

    _contract.onIntroLoadCompleted(_pages!);
  }

  /// If the user has selected screen(s) to import, this does it
  /// device - name of the device we are importing
  /// screenList - which screens to import
  /// context - context
  void _importScreen(String device, List<ScreenItem> screenList, BuildContext context) async {
    //the name will have spaces, but the asset file does not.
    // so turn Large Tablet into LargeTablet
    device = device.replaceAll(" ", ""); //remove spaces

    //import each selected screen
    ScreenService screenService = ScreenService();
    await screenService.loadScreens();

    for (int i=0; i < screenList.length; i++) {
      String assetFile = path.join("assets", "screens", "${screenList[i].title}-$device.json");
      await screenService.import(assetFile);
    }

    var snackBar = SnackBar(content: Text(Intl.of(context)!.onboardImportSuccess));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
