import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:gic_flutter/model/Screen.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/screens/intro/screenListWidget.dart';
import 'package:gic_flutter/screens/intro/screenSizeWidget.dart';
import 'package:gic_flutter/theme/theme.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroPresentation {
  List<PageViewModel> pages;
  List<ScreenItem> _screens = <ScreenItem>[new ScreenItem("SC"), new ScreenItem("Elite"), new ScreenItem("Truck")];
  String device = "Phone";

  loadPages(BuildContext context) async {
    Color primaryColor = CustomTheme.of(context).primaryColor;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    PageViewModel oldApi;

    int version = androidInfo.version.sdkInt;

    final PageDecoration decoration = new PageDecoration(
      dotsDecorator: DotsDecorator(
        activeColor: primaryColor,
      ));

    if (version < 19) { //KITKAT
      oldApi = PageViewModel(
        title: Intl.of(context).onboardOldAndroidTitle,
        body: Intl.of(context).onboardOldAndroidDesc,
        image: Icon(Icons.warning, size: 175.0, color: primaryColor),
        decoration: decoration,
      );
    }

    pages = [
      PageViewModel(
        title: Intl.of(context).onboardIntroTitle,
        body: Intl.of(context).onboardIntroDesc,
        image: Icon(Icons.thumb_up, size: 175.0, color: primaryColor),
        decoration: decoration,
      ),
      PageViewModel(
        title: Intl.of(context).onboardAboutTitle,
        body: Intl.of(context).onboardAboutDesc,
        image: Icon(Icons.info_outline, size: 175.0, color: primaryColor),
        decoration: decoration,
      ),
      PageViewModel(
        title: Intl.of(context).onboardServerTitle,
        body: Intl.of(context).onboardServerDesc,
        image: Icon(Icons.important_devices, size: 175.0, color: primaryColor),
        decoration: decoration,
        footer: RaisedButton(
          onPressed: () async {
            Email email = Email(
              body: "https://github.com/Terence-D/GameInputCommandServer/wiki",
              subject: Intl.of(context).onboardEmailSubject,
            );
            await FlutterEmailSender.send(email);
          },
          child: Text(Intl.of(context).onboardSendLink, style: TextStyle(color: Colors.white)),
          color: primaryColor,
        ),
      ),
      PageViewModel(
        title: Intl.of(context).onboardScreenTitle,
        decoration: decoration,
        bodyWidget: SingleChildScrollView(
          child: Column(
            children: [
              Text(Intl.of(context).onboardScreenDesc),
              Text(Intl.of(context).onboardScreenDevice),
              ScreenSizeWidget(
                  (String selected) {
                    this.device = selected;
                  }
              ),
              Text(Intl.of(context).onboardScreenList),
              ScreenListWidget(_screens),
              RaisedButton(
                onPressed: () {
                  _screens.forEach((screen) =>importScreen(device, screen, context));
                },
                child: Text(Intl.of(context).onboardImport, style: TextStyle(color: Colors.white)),
                color: primaryColor,
              )
            ],
          ),
        ) // Single child scroll view
      ),
      PageViewModel(
        title: Intl.of(context).onboardLetsGoTitle,
        body: Intl.of(context).onboardLetsGoDesc,
        image: Icon(Icons.help_outline, size: 175.0, color: primaryColor),
        decoration: decoration,
      ),
      PageViewModel(
        title: Intl.of(context).onboardSupportTitle,
        body: Intl.of(context).onboardSupportDesc,
        image: Icon(Icons.free_breakfast, size: 175.0, color: primaryColor),
        decoration: decoration,
      ),
    ];
    if (oldApi != null) {
      pages.add(oldApi);
    }
  }

  getPages() {
    return pages;
  }

  importScreen(String device, ScreenItem screen, BuildContext context) async {
    if (!screen.selected)
      return;
    device = device.replaceAll(" ", ""); //remove spaces
    String jsonString = await DefaultAssetBundle.of(context).loadString("assets/screens/${screen.title}-$device.json");
    
    Map controlMap = jsonDecode(jsonString);
    Screen newScreen = Screen.fromJson(controlMap);

    debugPrint("${newScreen.controls.length}");
  }
}
